import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/constants.dart';
import '../data/championship_model.dart';
import '../data/checkin_model.dart';
import '../data/checkin_service.dart';
import '../data/team_model.dart';
import '../data/team_service.dart';

class ChampionshipCheckInPage extends StatefulWidget {
  final Championship championship;

  const ChampionshipCheckInPage({super.key, required this.championship});

  @override
  State<ChampionshipCheckInPage> createState() =>
      _ChampionshipCheckInPageState();
}

class _ChampionshipCheckInPageState extends State<ChampionshipCheckInPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _hasCheckedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length:
          widget.championship.canRegisterTeams &&
              widget.championship.canRegisterIndividuals
          ? 2
          : 1,
      vsync: this,
    );
    _checkIfUserHasCheckedIn();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkIfUserHasCheckedIn() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário não autenticado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final hasCheckedIn = await CheckInService.hasUserCheckedIn(
        widget.championship.id,
        user.uid,
      );

      if (mounted) {
        setState(() {
          _hasCheckedIn = hasCheckedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao verificar check-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Check-in - ${widget.championship.title}'),
          backgroundColor: KConstants.primaryColor,
          foregroundColor: KConstants.textLightColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasCheckedIn) {
      return _buildAlreadyCheckedInView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in - ${widget.championship.title}'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        bottom: _buildTabBar(),
      ),
      body: TabBarView(controller: _tabController, children: _buildTabViews()),
    );
  }

  PreferredSizeWidget? _buildTabBar() {
    if (!widget.championship.canRegisterTeams ||
        !widget.championship.canRegisterIndividuals) {
      return null;
    }

    return TabBar(
      controller: _tabController,
      indicatorColor: KConstants.textLightColor,
      labelColor: KConstants.textLightColor,
      unselectedLabelColor: KConstants.textLightColor.withValues(alpha: 0.7),
      tabs: const [
        Tab(icon: Icon(Icons.group), text: 'Check-in Time'),
        Tab(icon: Icon(Icons.person), text: 'Check-in Individual'),
      ],
    );
  }

  List<Widget> _buildTabViews() {
    final views = <Widget>[];

    if (widget.championship.canRegisterTeams) {
      views.add(TeamCheckInTab(championship: widget.championship));
    }

    if (widget.championship.canRegisterIndividuals) {
      views.add(IndividualCheckInTab(championship: widget.championship));
    }

    return views;
  }

  Widget _buildAlreadyCheckedInView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in - ${widget.championship.title}'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(KConstants.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green[600]),
              const SizedBox(height: KConstants.spacingLarge),
              Text(
                'Check-in Realizado!',
                style: KTextStyle.largeTitleText.copyWith(
                  color: Colors.green[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KConstants.spacingMedium),
              Text(
                'Você já fez check-in neste campeonato.',
                style: KTextStyle.bodyText,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KConstants.spacingLarge),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KConstants.primaryColor,
                  foregroundColor: KConstants.textLightColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: KConstants.spacingLarge,
                    vertical: KConstants.spacingMedium,
                  ),
                ),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamCheckInTab extends StatefulWidget {
  final Championship championship;

  const TeamCheckInTab({super.key, required this.championship});

  @override
  State<TeamCheckInTab> createState() => _TeamCheckInTabState();
}

class _TeamCheckInTabState extends State<TeamCheckInTab> {
  List<Team> _userTeams = [];
  Team? _selectedTeam;
  List<PlayerCheckIn> _players = [];
  final _notesController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserTeams();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserTeams() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário não autenticado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final teamsStream = TeamService.getUserTeams(user.uid);
      final teams = await teamsStream.first;

      if (mounted) {
        setState(() {
          _userTeams = teams;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar times: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onTeamSelected(Team team) {
    setState(() {
      _selectedTeam = team;
      _players = team.members.map((member) {
        return PlayerCheckIn(
          userId: member.userId,
          userName: member.userName,
          userEmail: member.userEmail,
          position: 'Jogador',
          isPresent: false,
        );
      }).toList();
    });
  }

  void _togglePlayerPresence(int index) {
    setState(() {
      _players[index] = _players[index].copyWith(
        isPresent: !_players[index].isPresent,
        checkInTime: _players[index].isPresent ? null : DateTime.now(),
      );
    });
  }

  Future<void> _submitCheckIn() async {
    if (_selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final presentPlayers = _players.where((p) => p.isPresent).length;
    if (presentPlayers < widget.championship.minPlayersPerTeam) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Número insuficiente de jogadores presentes. '
            'Mínimo: ${widget.championship.minPlayersPerTeam}, '
            'Presentes: $presentPlayers',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await CheckInService.checkInTeam(
        championshipId: widget.championship.id,
        teamId: _selectedTeam!.id,
        players: _players,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer check-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userTeams.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(KConstants.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: KConstants.spacingMedium),
              Text(
                'Você não é capitão de nenhum time',
                style: KTextStyle.titleText.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KConstants.spacingSmall),
              Text(
                'Apenas capitães podem fazer check-in de times',
                style: KTextStyle.bodyText.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informações do campeonato
          Card(
            child: Padding(
              padding: const EdgeInsets.all(KConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações do Campeonato',
                    style: KTextStyle.titleText,
                  ),
                  const SizedBox(height: KConstants.spacingSmall),
                  Text(
                    'Local: ${widget.championship.location}',
                    style: KTextStyle.bodyText,
                  ),
                  Text(
                    'Mínimo de jogadores: ${widget.championship.minPlayersPerTeam}',
                    style: KTextStyle.bodyText,
                  ),
                  Text(
                    'Máximo de jogadores: ${widget.championship.maxPlayersPerTeam}',
                    style: KTextStyle.bodyText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: KConstants.spacingMedium),

          // Seleção de time
          Card(
            child: Padding(
              padding: const EdgeInsets.all(KConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selecione seu Time', style: KTextStyle.titleText),
                  const SizedBox(height: KConstants.spacingMedium),
                  ...List.generate(_userTeams.length, (index) {
                    final team = _userTeams[index];
                    return RadioListTile<Team>(
                      title: Text(team.name),
                      subtitle: Text('${team.currentMembersCount} jogadores'),
                      value: team,
                      groupValue: _selectedTeam,
                      onChanged: (Team? value) {
                        if (value != null) {
                          _onTeamSelected(value);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          if (_selectedTeam != null) ...[
            const SizedBox(height: KConstants.spacingMedium),

            // Lista de jogadores
            Card(
              child: Padding(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jogadores Presentes', style: KTextStyle.titleText),
                    const SizedBox(height: KConstants.spacingMedium),
                    Text(
                      'Marque os jogadores que estão presentes:',
                      style: KTextStyle.bodySecondaryText,
                    ),
                    const SizedBox(height: KConstants.spacingMedium),
                    ...List.generate(_players.length, (index) {
                      final player = _players[index];
                      return CheckboxListTile(
                        title: Text(player.userName),
                        subtitle: Text(player.userEmail),
                        value: player.isPresent,
                        onChanged: (_) => _togglePlayerPresence(index),
                        secondary: Icon(
                          player.isPresent
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: player.isPresent ? Colors.green : Colors.grey,
                        ),
                      );
                    }),
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
                          Icon(Icons.info, color: Colors.blue[600]),
                          const SizedBox(width: KConstants.spacingSmall),
                          Expanded(
                            child: Text(
                              'Jogadores presentes: ${_players.where((p) => p.isPresent).length}/${_players.length}',
                              style: KTextStyle.bodyText.copyWith(
                                color: Colors.blue[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KConstants.spacingMedium),

            // Observações
            Card(
              child: Padding(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Observações (Opcional)', style: KTextStyle.titleText),
                    const SizedBox(height: KConstants.spacingMedium),
                    TextFormField(
                      controller: _notesController,
                      decoration: KInputDecoration.textFieldDecoration(
                        hintText: 'Adicione observações sobre o check-in...',
                        prefixIcon: Icons.note,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KConstants.spacingLarge),

            // Botão de check-in
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: KConstants.primaryColor,
                foregroundColor: KConstants.textLightColor,
                padding: const EdgeInsets.symmetric(
                  vertical: KConstants.spacingMedium,
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Fazer Check-in'),
            ),
          ],
        ],
      ),
    );
  }
}

class IndividualCheckInTab extends StatefulWidget {
  final Championship championship;

  const IndividualCheckInTab({super.key, required this.championship});

  @override
  State<IndividualCheckInTab> createState() => _IndividualCheckInTabState();
}

class _IndividualCheckInTabState extends State<IndividualCheckInTab> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPosition = 'Atacante';
  String _selectedSkillLevel = 'intermediate';
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _positions = [
    'Goleiro',
    'Zagueiro',
    'Lateral',
    'Volante',
    'Meio-campo',
    'Atacante',
  ];

  final Map<String, String> _skillLevels = {
    'beginner': 'Iniciante',
    'intermediate': 'Intermediário',
    'advanced': 'Avançado',
  };

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitCheckIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await CheckInService.checkInIndividual(
        championshipId: widget.championship.id,
        preferredPosition: _selectedPosition,
        skillLevel: _selectedSkillLevel,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in individual realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer check-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
            // Informações do campeonato
            Card(
              child: Padding(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check-in Individual', style: KTextStyle.titleText),
                    const SizedBox(height: KConstants.spacingSmall),
                    Text(
                      'Faça seu check-in individual e aguarde a formação dos times.',
                      style: KTextStyle.bodyText,
                    ),
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
                          Icon(Icons.info, color: Colors.blue[600]),
                          const SizedBox(width: KConstants.spacingSmall),
                          Expanded(
                            child: Text(
                              'Os times serão formados automaticamente com base nas posições e níveis de habilidade.',
                              style: KTextStyle.smallText.copyWith(
                                color: Colors.blue[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KConstants.spacingMedium),

            // Posição preferida
            Card(
              child: Padding(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Posição Preferida', style: KTextStyle.titleText),
                    const SizedBox(height: KConstants.spacingMedium),
                    DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      decoration: KInputDecoration.textFieldDecoration(
                        hintText: 'Selecione sua posição',
                        prefixIcon: Icons.sports_soccer,
                      ),
                      items: _positions.map((position) {
                        return DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPosition = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione uma posição';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KConstants.spacingMedium),

            // Nível de habilidade
            Card(
              child: Padding(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nível de Habilidade', style: KTextStyle.titleText),
                    const SizedBox(height: KConstants.spacingMedium),
                    DropdownButtonFormField<String>(
                      value: _selectedSkillLevel,
                      decoration: KInputDecoration.textFieldDecoration(
                        hintText: 'Selecione seu nível',
                        prefixIcon: Icons.trending_up,
                      ),
                      items: _skillLevels.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSkillLevel = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione um nível';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KConstants.spacingMedium),

            // Observações
            Card(
              child: Padding(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Observações (Opcional)', style: KTextStyle.titleText),
                    const SizedBox(height: KConstants.spacingMedium),
                    TextFormField(
                      controller: _notesController,
                      decoration: KInputDecoration.textFieldDecoration(
                        hintText: 'Adicione informações adicionais...',
                        prefixIcon: Icons.note,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KConstants.spacingLarge),

            // Botão de check-in
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: KConstants.primaryColor,
                foregroundColor: KConstants.textLightColor,
                padding: const EdgeInsets.symmetric(
                  vertical: KConstants.spacingMedium,
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Fazer Check-in Individual'),
            ),
          ],
        ),
      ),
    );
  }
}
