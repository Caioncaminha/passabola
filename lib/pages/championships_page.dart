import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/championship_model.dart';
import '../data/championship_service.dart';
import 'championship_registration_page.dart';

class ChampionshipsPage extends StatefulWidget {
  const ChampionshipsPage({super.key});

  @override
  State<ChampionshipsPage> createState() => _ChampionshipsPageState();
}

class _ChampionshipsPageState extends State<ChampionshipsPage> {
  List<Championship> _championships = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChampionships();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChampionships() async {
    try {
      final championships = await ChampionshipService.getPublicChampionships();
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

  List<Championship> get _filteredChampionships {
    if (_searchQuery.isEmpty) return _championships;

    return _championships.where((championship) {
      return championship.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          championship.location.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          championship.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campeonatos'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          IconButton(
            onPressed: _loadChampionships,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(KConstants.spacingMedium),
            decoration: BoxDecoration(
              color: KConstants.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: KInputDecoration.textFieldDecoration(
                hintText: 'Pesquisar campeonatos...',
                prefixIcon: Icons.search,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Lista de campeonatos
          Expanded(child: _buildChampionshipsList()),
        ],
      ),
    );
  }

  Widget _buildChampionshipsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredChampionships = _filteredChampionships;

    if (filteredChampionships.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(KConstants.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isEmpty
                    ? Icons.emoji_events_outlined
                    : Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: KConstants.spacingMedium),
              Text(
                _searchQuery.isEmpty
                    ? 'Nenhum campeonato disponível'
                    : 'Nenhum campeonato encontrado',
                style: KTextStyle.titleText.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KConstants.spacingSmall),
              Text(
                _searchQuery.isEmpty
                    ? 'Novos campeonatos aparecerão aqui quando forem publicados'
                    : 'Tente pesquisar com outros termos',
                style: KTextStyle.bodyText.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChampionships,
      child: ListView.builder(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        itemCount: filteredChampionships.length,
        itemBuilder: (context, index) {
          final championship = filteredChampionships[index];
          return _buildChampionshipCard(championship);
        },
      ),
    );
  }

  Widget _buildChampionshipCard(Championship championship) {
    return Card(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewChampionshipDetails(championship),
        borderRadius: BorderRadius.circular(KConstants.borderRadiusSmall),
        child: Padding(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(championship.title, style: KTextStyle.titleText),
                        const SizedBox(height: KConstants.spacingExtraSmall),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: KConstants.spacingExtraSmall),
                            Expanded(
                              child: Text(
                                championship.location,
                                style: KTextStyle.bodySecondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(championship.status),
                ],
              ),
              const SizedBox(height: KConstants.spacingSmall),

              // Descrição
              Text(
                championship.description,
                style: KTextStyle.bodyText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: KConstants.spacingMedium),

              // Informações do campeonato
              Wrap(
                spacing: KConstants.spacingMedium,
                runSpacing: KConstants.spacingSmall,
                children: [
                  _buildInfoChip(
                    Icons.people,
                    'Máx: ${championship.maxTeams} times',
                  ),
                  _buildInfoChip(
                    Icons.sports_soccer,
                    championship.typeDisplayName,
                  ),
                  _buildInfoChip(
                    Icons.how_to_reg,
                    championship.registrationTypeDisplayName,
                  ),
                  if (championship.registrationFee != null)
                    _buildInfoChip(
                      Icons.attach_money,
                      'R\$ ${championship.registrationFee!.toStringAsFixed(2)}',
                      color: Colors.green[600],
                    ),
                ],
              ),

              // Datas
              if (championship.startDate != null ||
                  championship.endDate != null) ...[
                const SizedBox(height: KConstants.spacingMedium),
                Container(
                  padding: const EdgeInsets.all(KConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(
                      KConstants.borderRadiusSmall,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: KConstants.spacingSmall),
                      Expanded(
                        child: Text(
                          _formatDateRange(
                            championship.startDate,
                            championship.endDate,
                          ),
                          style: KTextStyle.smallText.copyWith(
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: KConstants.spacingMedium),

              // Botões de ação
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
                  Expanded(child: _buildRegistrationButton(championship)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ChampionshipStatus status) {
    Color color;
    String text;

    switch (status) {
      case ChampionshipStatus.published:
        color = Colors.blue;
        text = 'PUBLICADO';
        break;
      case ChampionshipStatus.registrationOpen:
        color = Colors.green;
        text = 'INSCRIÇÕES ABERTAS';
        break;
      case ChampionshipStatus.registrationClosed:
        color = Colors.orange;
        text = 'INSCRIÇÕES FECHADAS';
        break;
      case ChampionshipStatus.ongoing:
        color = Colors.purple;
        text = 'EM ANDAMENTO';
        break;
      case ChampionshipStatus.finished:
        color = Colors.teal;
        text = 'FINALIZADO';
        break;
      default:
        color = Colors.grey;
        text = status.name.toUpperCase();
    }

    return Chip(
      label: Text(
        text,
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

  Widget _buildInfoChip(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: KConstants.spacingExtraSmall),
        Text(text, style: KTextStyle.smallText.copyWith(color: color)),
      ],
    );
  }

  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return '';

    if (startDate != null && endDate != null) {
      if (startDate.day == endDate.day &&
          startDate.month == endDate.month &&
          startDate.year == endDate.year) {
        return '${startDate.day}/${startDate.month}/${startDate.year}';
      }
      return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
    }

    if (startDate != null) {
      return 'Início: ${startDate.day}/${startDate.month}/${startDate.year}';
    }

    return 'Fim: ${endDate!.day}/${endDate.month}/${endDate.year}';
  }

  void _viewChampionshipDetails(Championship championship) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChampionshipDetailsPage(championship: championship),
      ),
    );
  }

  Widget _buildRegistrationButton(Championship championship) {
    if (championship.canRegisterTeams && championship.canRegisterIndividuals) {
      // Ambos os tipos permitidos
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _goToRegistration(championship, RegistrationType.teamOnly),
              icon: const Icon(Icons.group),
              label: const Text('Inscrever Time'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KConstants.primaryColor,
                foregroundColor: KConstants.textLightColor,
              ),
            ),
          ),
          const SizedBox(height: KConstants.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _goToRegistration(
                championship,
                RegistrationType.individualPairing,
              ),
              icon: const Icon(Icons.person),
              label: const Text('Inscrever Individual'),
              style: OutlinedButton.styleFrom(
                foregroundColor: KConstants.primaryColor,
                side: BorderSide(color: KConstants.primaryColor),
              ),
            ),
          ),
        ],
      );
    } else if (championship.canRegisterTeams) {
      // Apenas times
      return ElevatedButton.icon(
        onPressed: () =>
            _goToRegistration(championship, RegistrationType.teamOnly),
        icon: const Icon(Icons.group),
        label: const Text('Inscrever Time'),
        style: ElevatedButton.styleFrom(
          backgroundColor: KConstants.primaryColor,
          foregroundColor: KConstants.textLightColor,
        ),
      );
    } else if (championship.canRegisterIndividuals) {
      // Apenas individuais
      return ElevatedButton.icon(
        onPressed: () =>
            _goToRegistration(championship, RegistrationType.individualPairing),
        icon: const Icon(Icons.person),
        label: const Text('Inscrever Individual'),
        style: ElevatedButton.styleFrom(
          backgroundColor: KConstants.primaryColor,
          foregroundColor: KConstants.textLightColor,
        ),
      );
    } else {
      // Nenhum tipo permitido
      return const SizedBox.shrink();
    }
  }

  void _goToRegistration(
    Championship championship,
    RegistrationType registrationType,
  ) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => ChampionshipRegistrationPage(
              championship: championship,
              registrationType: registrationType,
            ),
          ),
        )
        .then((_) => _loadChampionships()); // Recarregar após inscrição
  }
}

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
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do campeonato (se houver)
            if (championship.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  KConstants.borderRadiusLarge,
                ),
                child: Image.network(
                  championship.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(
                          KConstants.borderRadiusLarge,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),
            ],

            // Informações básicas
            _buildSection('Informações Gerais', [
              _buildInfoRow('Local', championship.location),
              _buildInfoRow('Tipo', championship.typeDisplayName),
              _buildInfoRow(
                'Inscrições',
                championship.registrationTypeDisplayName,
              ),
              _buildInfoRow('Status', championship.statusDisplayName),
              if (championship.registrationFee != null)
                _buildInfoRow(
                  'Taxa de Inscrição',
                  'R\$ ${championship.registrationFee!.toStringAsFixed(2)}',
                ),
            ]),

            // Configurações
            _buildSection('Configurações', [
              _buildInfoRow('Máximo de Times', '${championship.maxTeams}'),
              _buildInfoRow(
                'Jogadores por Time',
                '${championship.minPlayersPerTeam} - ${championship.maxPlayersPerTeam}',
              ),
            ]),

            // Datas
            if (championship.startDate != null ||
                championship.endDate != null ||
                championship.registrationStartDate != null ||
                championship.registrationEndDate != null)
              _buildSection('Datas', [
                if (championship.startDate != null)
                  _buildInfoRow(
                    'Início do Campeonato',
                    _formatDate(championship.startDate!),
                  ),
                if (championship.endDate != null)
                  _buildInfoRow(
                    'Fim do Campeonato',
                    _formatDate(championship.endDate!),
                  ),
                if (championship.registrationStartDate != null)
                  _buildInfoRow(
                    'Início das Inscrições',
                    _formatDate(championship.registrationStartDate!),
                  ),
                if (championship.registrationEndDate != null)
                  _buildInfoRow(
                    'Fim das Inscrições',
                    _formatDate(championship.registrationEndDate!),
                  ),
              ]),

            // Descrição
            _buildSection('Descrição', [
              Text(championship.description, style: KTextStyle.bodyText),
            ]),

            // Regras
            if (championship.rules.isNotEmpty)
              _buildSection(
                'Regras',
                championship.rules.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: KConstants.spacingSmall,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}. ',
                          style: KTextStyle.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(entry.value, style: KTextStyle.bodyText),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            // Prêmios
            if (championship.prizes.isNotEmpty)
              _buildSection(
                'Premiação',
                championship.prizes.map((prize) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: KConstants.spacingSmall,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KConstants.spacingSmall,
                            vertical: KConstants.spacingExtraSmall,
                          ),
                          decoration: BoxDecoration(
                            color: KConstants.primaryColor,
                            borderRadius: BorderRadius.circular(
                              KConstants.borderRadiusSmall,
                            ),
                          ),
                          child: Text(
                            prize.position,
                            style: KTextStyle.smallText.copyWith(
                              color: KConstants.textLightColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: KConstants.spacingSmall),
                        Expanded(
                          child: Text(
                            prize.description,
                            style: KTextStyle.bodyText,
                          ),
                        ),
                        if (prize.monetaryValue != null)
                          Text(
                            'R\$ ${prize.monetaryValue!.toStringAsFixed(2)}',
                            style: KTextStyle.bodyText.copyWith(
                              color: Colors.green[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: KConstants.spacingLarge),

            // Botão de inscrição (com check-in integrado)
            if (championship.isRegistrationOpen)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChampionshipRegistrationPage(
                          championship: championship,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.app_registration),
                  label: const Text('Inscrever-se'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KConstants.primaryColor,
                    foregroundColor: KConstants.textLightColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: KConstants.spacingMedium,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: KTextStyle.titleText.copyWith(
            color: KConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: KConstants.spacingMedium),
        ...children,
        const SizedBox(height: KConstants.spacingLarge),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: KTextStyle.bodyText.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: KTextStyle.bodyText)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
