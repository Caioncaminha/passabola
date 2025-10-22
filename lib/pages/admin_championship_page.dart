import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/constants.dart';
import '../data/championship_model.dart';
import '../data/championship_service.dart';
import '../debug_championship_creator.dart';

class AdminChampionshipPage extends StatefulWidget {
  const AdminChampionshipPage({super.key});

  @override
  State<AdminChampionshipPage> createState() => _AdminChampionshipPageState();
}

class _AdminChampionshipPageState extends State<AdminChampionshipPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Championship> _championships = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChampionships();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChampionships() async {
    try {
      final championships = await ChampionshipService.getAllChampionships();
      if (mounted) {
        setState(() {
          _championships = championships;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar campeonatos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Campeonatos'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: KConstants.textLightColor,
          labelColor: KConstants.textLightColor,
          unselectedLabelColor: KConstants.textLightColor.withValues(
            alpha: 0.7,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Lista'),
            Tab(icon: Icon(Icons.add), text: 'Criar Novo'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildChampionshipsList(), _buildCreateChampionship()],
      ),
    );
  }

  Widget _buildChampionshipsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_championships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: KConstants.spacingMedium),
            Text(
              'Nenhum campeonato criado ainda',
              style: KTextStyle.titleText.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: KConstants.spacingSmall),
            Text(
              'Crie seu primeiro campeonato na aba "Criar Novo"',
              style: KTextStyle.bodyText.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChampionships,
      child: ListView.builder(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        itemCount: _championships.length,
        itemBuilder: (context, index) {
          final championship = _championships[index];
          return _buildChampionshipCard(championship);
        },
      ),
    );
  }

  Widget _buildChampionshipCard(Championship championship) {
    return Card(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(championship.title, style: KTextStyle.titleText),
                      const SizedBox(height: KConstants.spacingExtraSmall),
                      Text(
                        championship.location,
                        style: KTextStyle.bodySecondaryText,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(championship.status),
              ],
            ),
            const SizedBox(height: KConstants.spacingSmall),
            Text(
              championship.description,
              style: KTextStyle.bodyText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: KConstants.spacingMedium),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: KConstants.spacingExtraSmall),
                Text(
                  'Máx: ${championship.maxTeams} times',
                  style: KTextStyle.smallText,
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Icon(Icons.sports_soccer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: KConstants.spacingExtraSmall),
                Text(championship.typeDisplayName, style: KTextStyle.smallText),
                const Spacer(),
                if (championship.registrationFee != null) ...[
                  Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
                  Text(
                    'R\$ ${championship.registrationFee!.toStringAsFixed(2)}',
                    style: KTextStyle.smallText.copyWith(
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: KConstants.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewChampionshipDetails(championship),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver Detalhes'),
                  ),
                ),
                const SizedBox(width: KConstants.spacingSmall),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewParticipants(championship),
                    icon: const Icon(Icons.people),
                    label: const Text('Participantes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: KConstants.spacingSmall),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editChampionship(championship),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KConstants.primaryColor,
                      foregroundColor: KConstants.textLightColor,
                    ),
                  ),
                ),
              ],
            ),

            // Botão de deletar
            const SizedBox(height: KConstants.spacingSmall),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _deleteChampionship(championship),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Deletar Campeonato',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),

            // Botões de gerenciamento de status
            if (championship.status == ChampionshipStatus.published ||
                championship.status == ChampionshipStatus.draft) ...[
              const SizedBox(height: KConstants.spacingSmall),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openRegistrations(championship),
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Abrir Inscrições'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (championship.status == ChampionshipStatus.registrationOpen) ...[
              const SizedBox(height: KConstants.spacingSmall),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _closeRegistrations(championship),
                      icon: const Icon(Icons.lock),
                      label: const Text('Fechar Inscrições'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (championship.status ==
                ChampionshipStatus.registrationClosed) ...[
              const SizedBox(height: KConstants.spacingSmall),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startChampionship(championship),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar Campeonato'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Debug info
            const SizedBox(height: KConstants.spacingSmall),
            Container(
              padding: const EdgeInsets.all(KConstants.spacingSmall),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(
                  KConstants.borderRadiusSmall,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEBUG INFO:',
                    style: KTextStyle.smallText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Status: ${championship.status}',
                    style: KTextStyle.smallText,
                  ),
                  Text(
                    'canCheckIn: ${championship.canCheckIn}',
                    style: KTextStyle.smallText,
                  ),
                  Text(
                    'isRegistrationOpen: ${championship.isRegistrationOpen}',
                    style: KTextStyle.smallText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ChampionshipStatus status) {
    Color color;
    switch (status) {
      case ChampionshipStatus.draft:
        color = Colors.grey;
        break;
      case ChampionshipStatus.published:
        color = Colors.blue;
        break;
      case ChampionshipStatus.registrationOpen:
        color = Colors.green;
        break;
      case ChampionshipStatus.registrationClosed:
        color = Colors.orange;
        break;
      case ChampionshipStatus.ongoing:
        color = Colors.purple;
        break;
      case ChampionshipStatus.finished:
        color = Colors.teal;
        break;
      case ChampionshipStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCreateChampionship() {
    return const ChampionshipCreateForm();
  }

  void _viewChampionshipDetails(Championship championship) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChampionshipDetailsPage(championship: championship),
      ),
    );
  }

  void _viewParticipants(Championship championship) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ChampionshipParticipantsPage(championship: championship),
      ),
    );
  }

  void _editChampionship(Championship championship) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ChampionshipEditPage(championship: championship),
          ),
        )
        .then((_) => _loadChampionships());
  }

  Future<void> _openRegistrations(Championship championship) async {
    try {
      await ChampionshipService.openRegistrations(championship.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrições abertas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadChampionships();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir inscrições: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _closeRegistrations(Championship championship) async {
    try {
      await ChampionshipService.closeRegistrations(championship.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrições fechadas com sucesso!'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadChampionships();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fechar inscrições: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startChampionship(Championship championship) async {
    try {
      await ChampionshipService.startChampionship(championship.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campeonato iniciado com sucesso!'),
            backgroundColor: Colors.blue,
          ),
        );
        _loadChampionships();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar campeonato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteChampionship(Championship championship) async {
    // Mostrar diálogo de confirmação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja deletar o campeonato "${championship.title}"?\n\n'
          'Esta ação não pode ser desfeita e irá deletar:\n'
          '• Todas as inscrições relacionadas\n'
          '• Todos os check-ins\n'
          '• Todos os dados do campeonato',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ChampionshipService.deleteChampionship(championship.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Campeonato "${championship.title}" deletado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadChampionships();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar campeonato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ChampionshipCreateForm extends StatefulWidget {
  const ChampionshipCreateForm({super.key});

  @override
  State<ChampionshipCreateForm> createState() => _ChampionshipCreateFormState();
}

class _ChampionshipCreateFormState extends State<ChampionshipCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxTeamsController = TextEditingController(text: '16');
  final _minPlayersController = TextEditingController(text: '7');
  final _maxPlayersController = TextEditingController(text: '11');
  final _registrationFeeController = TextEditingController();

  ChampionshipType _selectedType = ChampionshipType.knockout;
  RegistrationType _selectedRegistrationType = RegistrationType.teamOnly;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _registrationStartDate;
  DateTime? _registrationEndDate;

  final List<String> _rules = [];
  final List<ChampionshipPrize> _prizes = [];
  final _ruleController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxTeamsController.dispose();
    _minPlayersController.dispose();
    _maxPlayersController.dispose();
    _registrationFeeController.dispose();
    _ruleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(KConstants.spacingMedium),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Criar Novo Campeonato', style: KTextStyle.largeTitleText),
            const SizedBox(height: KConstants.spacingLarge),

            // Informações básicas
            _buildSectionTitle('Informações Básicas'),
            const SizedBox(height: KConstants.spacingMedium),

            TextFormField(
              controller: _titleController,
              decoration: KInputDecoration.textFieldDecoration(
                hintText: 'Nome do campeonato',
                prefixIcon: Icons.emoji_events,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: KConstants.spacingMedium),

            TextFormField(
              controller: _descriptionController,
              decoration: KInputDecoration.textFieldDecoration(
                hintText: 'Descrição do campeonato',
                prefixIcon: Icons.description,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Descrição é obrigatória';
                }
                return null;
              },
            ),
            const SizedBox(height: KConstants.spacingMedium),

            TextFormField(
              controller: _locationController,
              decoration: KInputDecoration.textFieldDecoration(
                hintText: 'Local do campeonato',
                prefixIcon: Icons.location_on,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Local é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: KConstants.spacingLarge),

            // Configurações
            _buildSectionTitle('Configurações'),
            const SizedBox(height: KConstants.spacingMedium),

            DropdownButtonFormField<ChampionshipType>(
              value: _selectedType,
              decoration: KInputDecoration.textFieldDecoration(
                hintText: 'Tipo de campeonato',
                prefixIcon: Icons.sports_soccer,
              ),
              items: ChampionshipType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: KConstants.spacingMedium),

            DropdownButtonFormField<RegistrationType>(
              value: _selectedRegistrationType,
              decoration: KInputDecoration.textFieldDecoration(
                hintText: 'Tipo de inscrição',
                prefixIcon: Icons.how_to_reg,
              ),
              items: RegistrationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getRegistrationTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRegistrationType = value!;
                });
              },
            ),
            const SizedBox(height: KConstants.spacingMedium),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxTeamsController,
                    decoration: KInputDecoration.textFieldDecoration(
                      hintText: 'Máx. times',
                      prefixIcon: Icons.people,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 2) {
                        return 'Mín. 2 times';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: TextFormField(
                    controller: _minPlayersController,
                    decoration: KInputDecoration.textFieldDecoration(
                      hintText: 'Mín. jogadores',
                      prefixIcon: Icons.person,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 1) {
                        return 'Mín. 1';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: TextFormField(
                    controller: _maxPlayersController,
                    decoration: KInputDecoration.textFieldDecoration(
                      hintText: 'Máx. jogadores',
                      prefixIcon: Icons.person,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obrigatório';
                      }
                      final num = int.tryParse(value);
                      final minNum = int.tryParse(_minPlayersController.text);
                      if (num == null || num < 1) {
                        return 'Mín. 1';
                      }
                      if (minNum != null && num < minNum) {
                        return 'Maior que mín.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: KConstants.spacingMedium),

            TextFormField(
              controller: _registrationFeeController,
              decoration: KInputDecoration.textFieldDecoration(
                hintText: 'Taxa de inscrição (opcional)',
                prefixIcon: Icons.attach_money,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: KConstants.spacingLarge),

            // Datas
            _buildSectionTitle('Datas'),
            const SizedBox(height: KConstants.spacingMedium),

            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Data de Início',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: _buildDateField(
                    'Data de Fim',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KConstants.spacingMedium),

            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Início das Inscrições',
                    _registrationStartDate,
                    (date) => setState(() => _registrationStartDate = date),
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: _buildDateField(
                    'Fim das Inscrições',
                    _registrationEndDate,
                    (date) => setState(() => _registrationEndDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KConstants.spacingLarge),

            // Regras
            _buildSectionTitle('Regras'),
            const SizedBox(height: KConstants.spacingMedium),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ruleController,
                    decoration: KInputDecoration.textFieldDecoration(
                      hintText: 'Digite uma regra',
                      prefixIcon: Icons.rule,
                    ),
                  ),
                ),
                const SizedBox(width: KConstants.spacingSmall),
                IconButton(
                  onPressed: _addRule,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: KConstants.primaryColor,
                    foregroundColor: KConstants.textLightColor,
                  ),
                ),
              ],
            ),

            if (_rules.isNotEmpty) ...[
              const SizedBox(height: KConstants.spacingMedium),
              ...List.generate(_rules.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: KConstants.spacingSmall,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(
                            KConstants.spacingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(
                              KConstants.borderRadiusSmall,
                            ),
                          ),
                          child: Text('${index + 1}. ${_rules[index]}'),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeRule(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: KConstants.spacingLarge),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isCreating ? null : _saveDraft,
                    child: _isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar Rascunho'),
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createAndPublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KConstants.primaryColor,
                      foregroundColor: KConstants.textLightColor,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Criar e Publicar'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: KConstants.spacingLarge),

            // Botões de debug
            _buildSectionTitle('Debug - Criar Campeonatos de Teste'),
            const SizedBox(height: KConstants.spacingMedium),

            Wrap(
              spacing: KConstants.spacingSmall,
              runSpacing: KConstants.spacingSmall,
              children: [
                ElevatedButton(
                  onPressed: _isCreating
                      ? null
                      : () async {
                          await DebugChampionshipCreator.createChampionshipWithStatus(
                            ChampionshipStatus.registrationOpen,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Campeonato de teste criado!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Criar - Inscrições Abertas'),
                ),
                ElevatedButton(
                  onPressed: _isCreating
                      ? null
                      : () async {
                          await DebugChampionshipCreator.createChampionshipWithStatus(
                            ChampionshipStatus.registrationClosed,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Campeonato de teste criado!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Criar - Inscrições Fechadas'),
                ),
                ElevatedButton(
                  onPressed: _isCreating
                      ? null
                      : () async {
                          await DebugChampionshipCreator.createChampionshipWithStatus(
                            ChampionshipStatus.ongoing,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Campeonato de teste criado!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Criar - Em Andamento'),
                ),
                ElevatedButton(
                  onPressed: _isCreating
                      ? null
                      : () async {
                          await DebugChampionshipCreator.createTestChampionship();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Campeonato de teste criado!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text('Criar - Teste Completo'),
                ),
                ElevatedButton(
                  onPressed: _isCreating
                      ? null
                      : () async {
                          await _testRegistration();
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Testar Inscrição'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: KTextStyle.titleText.copyWith(
        color: KConstants.primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: KInputDecoration.textFieldDecoration(
          hintText: label,
          prefixIcon: Icons.calendar_today,
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
              : 'Selecionar data',
          style: selectedDate != null
              ? KTextStyle.bodyText
              : KTextStyle.bodySecondaryText,
        ),
      ),
    );
  }

  void _addRule() {
    if (_ruleController.text.trim().isNotEmpty) {
      setState(() {
        _rules.add(_ruleController.text.trim());
        _ruleController.clear();
      });
    }
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    await _createChampionship(ChampionshipStatus.draft);
  }

  Future<void> _createAndPublish() async {
    if (!_formKey.currentState!.validate()) return;
    await _createChampionship(ChampionshipStatus.published);
  }

  Future<void> _createChampionship(ChampionshipStatus status) async {
    setState(() => _isCreating = true);

    try {
      final championship = Championship(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        startDate: _startDate,
        endDate: _endDate,
        registrationStartDate: _registrationStartDate,
        registrationEndDate: _registrationEndDate,
        status: status,
        type: _selectedType,
        registrationType: _selectedRegistrationType,
        maxTeams: int.parse(_maxTeamsController.text),
        minPlayersPerTeam: int.parse(_minPlayersController.text),
        maxPlayersPerTeam: int.parse(_maxPlayersController.text),
        registrationFee: _registrationFeeController.text.isNotEmpty
            ? double.parse(_registrationFeeController.text)
            : null,
        rules: _rules,
        prizes: _prizes,
        organizerId: FirebaseAuth.instance.currentUser?.uid ?? '',
        organizerName:
            FirebaseAuth.instance.currentUser?.displayName ?? 'Admin',
      );

      await ChampionshipService.createChampionship(championship);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == ChampionshipStatus.draft
                  ? 'Campeonato salvo como rascunho!'
                  : 'Campeonato criado e publicado!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Limpar formulário
        _formKey.currentState!.reset();
        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _registrationFeeController.clear();
        _ruleController.clear();
        setState(() {
          _rules.clear();
          _prizes.clear();
          _startDate = null;
          _endDate = null;
          _registrationStartDate = null;
          _registrationEndDate = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar campeonato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  String _getTypeDisplayName(ChampionshipType type) {
    switch (type) {
      case ChampionshipType.knockout:
        return 'Eliminatória';
      case ChampionshipType.league:
        return 'Liga';
      case ChampionshipType.groups:
        return 'Grupos + Eliminatória';
      case ChampionshipType.friendly:
        return 'Amistoso';
    }
  }

  String _getRegistrationTypeDisplayName(RegistrationType type) {
    switch (type) {
      case RegistrationType.teamOnly:
        return 'Apenas Times';
      case RegistrationType.individualPairing:
        return 'Formação de Times';
      case RegistrationType.mixed:
        return 'Times + Indivíduos';
    }
  }

  Future<void> _testRegistration() async {
    try {
      print('DEBUG: Testando inscrição...');

      // Buscar um campeonato para testar
      final championships = await ChampionshipService.getAllChampionships();
      if (championships.isEmpty) {
        print('DEBUG: Nenhum campeonato encontrado para teste');
        return;
      }

      final championship = championships.first;
      print('DEBUG: Testando inscrição no campeonato: ${championship.title}');

      // Tentar fazer inscrição individual
      final registrationId = await ChampionshipService.registerIndividual(
        championshipId: championship.id,
        additionalInfo: {'test': true},
      );

      print('DEBUG: Inscrição de teste criada com ID: $registrationId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inscrição de teste criada! ID: $registrationId'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Erro no teste de inscrição: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no teste: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Placeholder para páginas de detalhes e edição
class ChampionshipDetailsPage extends StatelessWidget {
  final Championship championship;

  const ChampionshipDetailsPage({super.key, required this.championship});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(championship.title),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),
      body: const Center(child: Text('Página de detalhes será implementada')),
    );
  }
}

class ChampionshipEditPage extends StatelessWidget {
  final Championship championship;

  const ChampionshipEditPage({super.key, required this.championship});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${championship.title}'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),
      body: const Center(child: Text('Página de edição será implementada')),
    );
  }
}

class ChampionshipParticipantsPage extends StatefulWidget {
  final Championship championship;

  const ChampionshipParticipantsPage({super.key, required this.championship});

  @override
  State<ChampionshipParticipantsPage> createState() =>
      _ChampionshipParticipantsPageState();
}

class _ChampionshipParticipantsPageState
    extends State<ChampionshipParticipantsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _participantsData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadParticipants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipants() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await ChampionshipService.getChampionshipParticipants(
        widget.championship.id,
      );

      if (mounted) {
        setState(() {
          _participantsData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participantes - ${widget.championship.title}'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: KConstants.textLightColor,
          labelColor: KConstants.textLightColor,
          unselectedLabelColor: KConstants.textLightColor.withValues(
            alpha: 0.7,
          ),
          tabs: [
            Tab(
              icon: const Icon(Icons.person),
              text:
                  'Individuais (${_participantsData?['totalIndividual'] ?? 0})',
            ),
            Tab(
              icon: const Icon(Icons.group),
              text: 'Times (${_participantsData?['totalTeams'] ?? 0})',
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadParticipants,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar participantes',
              style: KTextStyle.titleText.copyWith(color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: KTextStyle.bodyText.copyWith(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadParticipants,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_participantsData == null) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildIndividualParticipants(), _buildTeamParticipants()],
    );
  }

  Widget _buildIndividualParticipants() {
    final participants =
        _participantsData!['individualParticipants'] as List<dynamic>;

    if (participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum participante individual',
              style: KTextStyle.titleText.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Ainda não há inscrições individuais para este campeonato',
              style: KTextStyle.bodyText.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: KConstants.primaryColor,
                      child: Text(
                        participant['name'][0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant['name'],
                            style: KTextStyle.titleText,
                          ),
                          Text(
                            participant['email'],
                            style: KTextStyle.bodySecondaryText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(Icons.phone, participant['phone']),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.sports_soccer,
                      participant['position'],
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.star,
                      _getSkillLevelText(participant['skillLevel']),
                    ),
                  ],
                ),
                if (participant['registeredAt'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Inscrito em: ${_formatDate(participant['registeredAt'])}',
                    style: KTextStyle.smallText.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamParticipants() {
    final participants =
        _participantsData!['teamParticipants'] as List<dynamic>;

    if (participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum time participando',
              style: KTextStyle.titleText.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Ainda não há times inscritos para este campeonato',
              style: KTextStyle.bodyText.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.group, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant['teamName'],
                            style: KTextStyle.titleText,
                          ),
                          Text(
                            'Capitão: ${participant['captainName']}',
                            style: KTextStyle.bodySecondaryText,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${participant['memberCount']} membros',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(Icons.email, participant['captainEmail']),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.people,
                      '${participant['memberCount']} jogadores',
                    ),
                  ],
                ),
                if (participant['registeredAt'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Inscrito em: ${_formatDate(participant['registeredAt'])}',
                    style: KTextStyle.smallText.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ],
      ),
    );
  }

  String _getSkillLevelText(String skillLevel) {
    switch (skillLevel) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return skillLevel;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
