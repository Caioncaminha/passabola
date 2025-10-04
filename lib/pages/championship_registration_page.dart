import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/championship_model.dart';
import '../data/championship_service.dart';
import '../data/team_model.dart';
import '../data/team_service.dart';
import '../data/checkin_model.dart';
import '../data/checkin_service.dart';
import '../data/constants.dart';

class ChampionshipRegistrationPage extends StatefulWidget {
  final Championship championship;
  final RegistrationType? registrationType;

  const ChampionshipRegistrationPage({
    Key? key,
    required this.championship,
    this.registrationType,
  }) : super(key: key);

  @override
  State<ChampionshipRegistrationPage> createState() =>
      _ChampionshipRegistrationPageState();
}

class _ChampionshipRegistrationPageState
    extends State<ChampionshipRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _skillLevelController = TextEditingController();

  bool _isLoading = false;
  bool _isRegistered = false;
  RegistrationType _selectedRegistrationType = RegistrationType.teamOnly;
  Team? _selectedTeam;
  List<Team> _userTeams = [];

  // Campos para check-in
  String _selectedPosition = 'atacante';
  String _selectedSkillLevel = 'intermediate';
  List<PlayerCheckIn> _teamPlayers = [];
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRegistrationType = widget.championship.registrationType;
    _loadUserProfile();
    _loadUserTeams();
    _checkExistingRegistration();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _skillLevelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Buscar dados do usuário na coleção 'jogadoras'
      final userDoc = await FirebaseFirestore.instance
          .collection('jogadoras')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};

        // Preencher campos automaticamente
        _nameController.text = userData['name'] ?? user.displayName ?? '';
        _emailController.text = userData['email'] ?? user.email ?? '';
        _phoneController.text = userData['phone'] ?? '';

        // Mapear posição para o formato correto do dropdown
        final position = userData['position'] ?? 'Atacante';
        final positionMap = {
          'Goleiro': 'goleiro',
          'Zagueiro': 'zagueiro',
          'Lateral': 'lateral',
          'Volante': 'volante',
          'Meio-campo': 'meio-campo',
          'Atacante': 'atacante',
        };
        final mappedPosition = positionMap[position] ?? 'atacante';

        _positionController.text = mappedPosition;
        _skillLevelController.text = userData['skillLevel'] ?? 'intermediate';

        // Atualizar seleções - garantir que os valores sejam válidos para os dropdowns
        _selectedPosition = mappedPosition;

        // Mapear níveis para valores válidos do dropdown
        final skillLevel = userData['skillLevel'] ?? 'intermediate';
        if (['beginner', 'intermediate', 'advanced'].contains(skillLevel)) {
          _selectedSkillLevel = skillLevel;
        } else {
          _selectedSkillLevel = 'intermediate';
        }

        print('DEBUG: Perfil carregado automaticamente');
        print('DEBUG: Nome: ${_nameController.text}');
        print('DEBUG: Email: ${_emailController.text}');
        print('DEBUG: Telefone: ${_phoneController.text}');
        print('DEBUG: Posição: ${_selectedPosition}');
        print('DEBUG: Nível: ${_selectedSkillLevel}');
      } else {
        // Fallback para dados do Firebase Auth
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
        print('DEBUG: Usando dados do Firebase Auth como fallback');
      }
    } catch (e) {
      print('DEBUG: Erro ao carregar perfil: $e');
      // Em caso de erro, usar dados do Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      }
    }
  }

  Future<void> _loadUserTeams() async {
    if (!widget.championship.canRegisterTeams) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final teamsStream = TeamService.getUserTeams(user.uid);
      final teams = await teamsStream.first;

      if (mounted) {
        setState(() {
          _userTeams = teams
              .where((team) => team.status == TeamStatus.active)
              .toList();
        });
      }
    } catch (e) {
      print('Erro ao carregar times do usuário: $e');
    }
  }

  Future<void> _checkExistingRegistration() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final registrations =
          await ChampionshipService.getUserChampionshipRegistrations(
            user.uid,
            widget.championship.id,
          );

      if (mounted) {
        setState(() {
          _isRegistered = registrations.isNotEmpty;
        });
      }
    } catch (e) {
      print('Erro ao verificar inscrição: $e');
    }
  }

  Future<void> _quickRegister() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      print('DEBUG: Iniciando inscrição rápida...');

      // Validar se os dados básicos estão preenchidos
      if (_nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nome e email são obrigatórios para inscrição rápida',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Criar dados de inscrição com informações do perfil
      final registrationData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'position': _selectedPosition,
        'skillLevel': _selectedSkillLevel,
        'quickRegistration': true,
      };

      print('DEBUG: Dados da inscrição rápida: $registrationData');

      // Fazer inscrição individual
      final registrationId = await ChampionshipService.registerIndividual(
        championshipId: widget.championship.id,
        additionalInfo: registrationData,
      );

      print('DEBUG: Inscrição rápida criada com ID: $registrationId');

      // Fazer check-in individual automaticamente
      await CheckInService.checkInIndividual(
        championshipId: widget.championship.id,
        preferredPosition: _selectedPosition,
        skillLevel: _selectedSkillLevel,
        notes: 'Inscrição rápida - dados do perfil',
      );

      print('DEBUG: Check-in individual concluído');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrição rápida realizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('DEBUG: Erro na inscrição rápida: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na inscrição rápida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _registerForChampionship() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      print('DEBUG: Iniciando processo de inscrição...');
      print('DEBUG: - User ID: ${user.uid}');
      print('DEBUG: - User Email: ${user.email}');
      print('DEBUG: - Championship ID: ${widget.championship.id}');
      print('DEBUG: - Registration Type: $_selectedRegistrationType');

      final registration = ChampionshipRegistration(
        id: '',
        championshipId: widget.championship.id,
        userId: user.uid,
        userEmail: _emailController.text.trim(),
        userName: _nameController.text.trim(),
        registeredAt: DateTime.now(),
        registrationType: _selectedRegistrationType,
        teamId: _selectedTeam?.id,
        teamName: _selectedTeam?.name,
        isConfirmed: false,
        isPaid: false,
        additionalInfo: {
          'phone': _phoneController.text.trim(),
          'position': _positionController.text.trim(),
          'skillLevel': _skillLevelController.text.trim(),
        },
      );

      // Fazer inscrição
      if (_selectedRegistrationType == RegistrationType.teamOnly &&
          _selectedTeam != null) {
        print('DEBUG: Fazendo inscrição de time...');
        await ChampionshipService.registerTeam(
          championshipId: registration.championshipId,
          teamId: registration.teamId ?? '',
          additionalInfo: registration.additionalInfo,
        );
        print('DEBUG: Inscrição de time concluída');

        // Fazer check-in do time automaticamente
        print('DEBUG: Fazendo check-in de time...');
        await CheckInService.checkInTeam(
          championshipId: registration.championshipId,
          teamId: _selectedTeam!.id,
          players: _teamPlayers,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        print('DEBUG: Check-in de time concluído');
      } else {
        print('DEBUG: Fazendo inscrição individual...');
        await ChampionshipService.registerIndividual(
          championshipId: registration.championshipId,
          additionalInfo: registration.additionalInfo,
        );
        print('DEBUG: Inscrição individual concluída');

        // Fazer check-in individual automaticamente
        print('DEBUG: Fazendo check-in individual...');
        await CheckInService.checkInIndividual(
          championshipId: registration.championshipId,
          preferredPosition: _selectedPosition,
          skillLevel: _selectedSkillLevel,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        print('DEBUG: Check-in individual concluído');
      }

      print('DEBUG: Inscrição e check-in realizados com SUCESSO!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrição e check-in realizados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('DEBUG: ERRO durante inscrição: $e');
      print('DEBUG: Stack trace: ${StackTrace.current}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao se inscrever: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscrição no Campeonato'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isRegistered
          ? _buildAlreadyRegisteredView()
          : _buildRegistrationForm(),
    );
  }

  Widget _buildAlreadyRegisteredView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green[600]),
            const SizedBox(height: 24),
            Text(
              'Você já está inscrito neste campeonato!',
              style: KTextStyle.titleText.copyWith(
                fontSize: 20,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Acesse "Meus Campeonatos" para ver mais detalhes.',
              style: KTextStyle.bodyText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: KConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do campeonato
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.championship.title,
                      style: KTextStyle.titleText,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.championship.description,
                      style: KTextStyle.bodyText,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.championship.location,
                          style: KTextStyle.smallText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tipo de inscrição
            if (widget.championship.registrationType ==
                RegistrationType.mixed) ...[
              Text('Tipo de Inscrição', style: KTextStyle.subtitleText),
              const SizedBox(height: 8),
              RadioListTile<RegistrationType>(
                title: const Text('Como Time'),
                subtitle: const Text('Inscrever-se com um time existente'),
                value: RegistrationType.teamOnly,
                groupValue: _selectedRegistrationType,
                onChanged: (value) {
                  setState(() {
                    _selectedRegistrationType = value!;
                  });
                },
              ),
              RadioListTile<RegistrationType>(
                title: const Text('Individual'),
                subtitle: const Text('Formação automática de times'),
                value: RegistrationType.individualPairing,
                groupValue: _selectedRegistrationType,
                onChanged: (value) {
                  setState(() {
                    _selectedRegistrationType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Seleção de time (se aplicável)
            if (_selectedRegistrationType == RegistrationType.teamOnly &&
                widget.championship.canRegisterTeams) ...[
              Text('Selecionar Time', style: KTextStyle.subtitleText),
              const SizedBox(height: 8),
              if (_userTeams.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Você não possui times ativos. Crie um time primeiro.',
                          style: KTextStyle.smallText.copyWith(
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<Team?>(
                  value: _selectedTeam,
                  decoration: const InputDecoration(
                    labelText: 'Escolha seu time',
                    border: OutlineInputBorder(),
                  ),
                  items: _userTeams.map((team) {
                    return DropdownMenuItem<Team?>(
                      value: team,
                      child: Text(team.name),
                    );
                  }).toList(),
                  onChanged: (team) {
                    setState(() {
                      _selectedTeam = team;
                      // Carregar jogadores do time para check-in
                      if (team != null) {
                        _teamPlayers = team.members.map((member) {
                          return PlayerCheckIn(
                            userId: member.userId,
                            userName: member.userName,
                            userEmail: member.userEmail,
                            position: 'Jogador',
                            isPresent:
                                true, // Por padrão, todos estão presentes
                          );
                        }).toList();
                      } else {
                        _teamPlayers = [];
                      }
                    });
                  },
                  validator: (value) {
                    if (_selectedRegistrationType ==
                            RegistrationType.teamOnly &&
                        value == null) {
                      return 'Selecione um time';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
            ],

            // Campos de informações pessoais
            Row(
              children: [
                Text('Informações Pessoais', style: KTextStyle.subtitleText),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Carregado do perfil',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'E-mail é obrigatório';
                }
                if (!value.contains('@')) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Telefone é obrigatório';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _positionController.text.isEmpty
                  ? null
                  : _positionController.text,
              decoration: const InputDecoration(
                labelText: 'Posição Preferida',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_soccer),
              ),
              items: const [
                DropdownMenuItem(value: 'goleiro', child: Text('Goleiro')),
                DropdownMenuItem(value: 'zagueiro', child: Text('Zagueiro')),
                DropdownMenuItem(value: 'lateral', child: Text('Lateral')),
                DropdownMenuItem(
                  value: 'meio-campo',
                  child: Text('Meio-campo'),
                ),
                DropdownMenuItem(value: 'atacante', child: Text('Atacante')),
                DropdownMenuItem(
                  value: 'qualquer',
                  child: Text('Qualquer posição'),
                ),
              ],
              onChanged: (value) {
                _positionController.text = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecione uma posição';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _skillLevelController.text.isEmpty
                  ? null
                  : _skillLevelController.text,
              decoration: const InputDecoration(
                labelText: 'Nível de Habilidade',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.star),
              ),
              items: const [
                DropdownMenuItem(value: 'beginner', child: Text('Iniciante')),
                DropdownMenuItem(
                  value: 'intermediate',
                  child: Text('Intermediário'),
                ),
                DropdownMenuItem(value: 'advanced', child: Text('Avançado')),
              ],
              onChanged: (value) {
                _skillLevelController.text = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecione seu nível';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Seção de Check-in
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: KConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Check-in Automático',
                          style: KTextStyle.titleText.copyWith(
                            color: KConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você será automaticamente check-in ao se inscrever no campeonato.',
                      style: KTextStyle.bodyText.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campos específicos para check-in individual
                    if (_selectedRegistrationType ==
                        RegistrationType.individualPairing) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedPosition,
                        decoration: const InputDecoration(
                          labelText: 'Posição Preferida',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sports_soccer),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'goleiro',
                            child: Text('Goleiro'),
                          ),
                          DropdownMenuItem(
                            value: 'zagueiro',
                            child: Text('Zagueiro'),
                          ),
                          DropdownMenuItem(
                            value: 'lateral',
                            child: Text('Lateral'),
                          ),
                          DropdownMenuItem(
                            value: 'volante',
                            child: Text('Volante'),
                          ),
                          DropdownMenuItem(
                            value: 'meio-campo',
                            child: Text('Meio-campo'),
                          ),
                          DropdownMenuItem(
                            value: 'atacante',
                            child: Text('Atacante'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPosition = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSkillLevel,
                        decoration: const InputDecoration(
                          labelText: 'Nível de Habilidade',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.star),
                        ),
                        items: const ['beginner', 'intermediate', 'advanced']
                            .map((level) {
                              return DropdownMenuItem<String>(
                                value: level,
                                child: Text(
                                  level == 'beginner'
                                      ? 'Iniciante'
                                      : level == 'intermediate'
                                      ? 'Intermediário'
                                      : 'Avançado',
                                ),
                              );
                            })
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSkillLevel = value;
                            });
                          }
                        },
                      ),
                    ],

                    // Informações do time para check-in
                    if (_selectedRegistrationType ==
                            RegistrationType.teamOnly &&
                        _selectedTeam != null) ...[
                      Text(
                        'Jogadores do Time:',
                        style: KTextStyle.titleText.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ..._teamPlayers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value;
                        return CheckboxListTile(
                          title: Text(player.userName),
                          subtitle: Text(player.userEmail),
                          value: player.isPresent,
                          onChanged: (value) {
                            setState(() {
                              _teamPlayers[index] = player.copyWith(
                                isPresent: value ?? false,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ],

                    const SizedBox(height: 16),

                    // Campo de observações
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botões de inscrição
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _quickRegister,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Inscrição Rápida'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerForChampionship,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Inscrição Completa',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
