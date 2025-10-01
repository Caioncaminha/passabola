import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/team_service.dart';
import '../data/team_model.dart';

class AdminTeamsPage extends StatefulWidget {
  const AdminTeamsPage({super.key});

  @override
  State<AdminTeamsPage> createState() => _AdminTeamsPageState();
}

class _AdminTeamsPageState extends State<AdminTeamsPage>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Times'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: KConstants.primaryColor.withValues(alpha: 0.1),
            child: TabBar(
              controller: TabController(
                length: 3,
                initialIndex: _selectedTabIndex,
                vsync: this,
              ),
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              tabs: const [
                Tab(text: 'Pendentes'),
                Tab(text: 'Ativos'),
                Tab(text: 'Rejeitados'),
              ],
              labelColor: KConstants.primaryColor,
              unselectedLabelColor: KConstants.textSecondaryColor,
              indicatorColor: KConstants.primaryColor,
            ),
          ),

          // Conteúdo das tabs
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildPendingTeams(),
                _buildActiveTeams(),
                _buildRejectedTeams(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTeams() {
    return StreamBuilder<List<Team>>(
      stream: TeamService.getPendingTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: KConstants.errorColor,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Text(
                  'Erro ao carregar times pendentes',
                  style: KTextStyle.heading3,
                ),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  snapshot.error.toString(),
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final teams = snapshot.data ?? [];

        if (teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pending_actions,
                  size: 64,
                  color: KConstants.textSecondaryColor,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Text(
                  'Nenhuma solicitação pendente',
                  style: KTextStyle.heading3,
                ),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  'Todas as solicitações foram processadas',
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return _buildPendingTeamCard(team);
          },
        );
      },
    );
  }

  Widget _buildActiveTeams() {
    return StreamBuilder<List<Team>>(
      stream: TeamService.getActiveTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: KConstants.errorColor,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Text(
                  'Erro ao carregar times ativos',
                  style: KTextStyle.heading3,
                ),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  snapshot.error.toString(),
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final teams = snapshot.data ?? [];

        if (teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 64,
                  color: KConstants.textSecondaryColor,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Text('Nenhum time ativo', style: KTextStyle.heading3),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  'Aprove algumas solicitações para ver times ativos aqui',
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return _buildActiveTeamCard(team);
          },
        );
      },
    );
  }

  Widget _buildRejectedTeams() {
    return StreamBuilder<List<Team>>(
      stream: TeamService.getAllTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: KConstants.errorColor,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Text(
                  'Erro ao carregar times rejeitados',
                  style: KTextStyle.heading3,
                ),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  snapshot.error.toString(),
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final teams = snapshot.data ?? [];
        final rejectedTeams = teams
            .where((team) => team.status == TeamStatus.rejected)
            .toList();

        if (rejectedTeams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cancel_outlined,
                  size: 64,
                  color: KConstants.textSecondaryColor,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Text('Nenhum time rejeitado', style: KTextStyle.heading3),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  'Todos os times foram aprovados ou ainda estão pendentes',
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          itemCount: rejectedTeams.length,
          itemBuilder: (context, index) {
            final team = rejectedTeams[index];
            return _buildRejectedTeamCard(team);
          },
        );
      },
    );
  }

  Widget _buildPendingTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: KConstants.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: team.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            team.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.group,
                                color: KConstants.warningColor,
                              );
                            },
                          ),
                        )
                      : Icon(Icons.group, color: KConstants.warningColor),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: KTextStyle.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: KConstants.spacingSmall),
                      Text(
                        'Capitão: ${team.captainName}',
                        style: KTextStyle.bodyText.copyWith(
                          color: KConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KConstants.spacingSmall,
                    vertical: KConstants.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: KConstants.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Pendente',
                    style: KTextStyle.smallText.copyWith(
                      color: KConstants.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: KConstants.spacingMedium),

            // Descrição
            Text(
              team.description,
              style: KTextStyle.bodyText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: KConstants.spacingMedium),

            // Informações adicionais
            Row(
              children: [
                _buildInfoChip(
                  Icons.people,
                  '${team.currentMembersCount}/${team.maxMembers}',
                ),
                const SizedBox(width: KConstants.spacingSmall),
                _buildInfoChip(Icons.flag, team.levelDisplayName),
                const SizedBox(width: KConstants.spacingSmall),
                _buildInfoChip(
                  Icons.calendar_today,
                  _formatDate(team.createdAt),
                ),
              ],
            ),

            const SizedBox(height: KConstants.spacingMedium),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectTeam(team),
                    icon: const Icon(Icons.close),
                    label: const Text('Rejeitar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KConstants.errorColor,
                      side: BorderSide(color: KConstants.errorColor),
                    ),
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveTeam(team),
                    icon: const Icon(Icons.check),
                    label: const Text('Aprovar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KConstants.successColor,
                      foregroundColor: Colors.white,
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

  Widget _buildActiveTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: KConstants.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: team.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            team.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.group,
                                color: KConstants.successColor,
                              );
                            },
                          ),
                        )
                      : Icon(Icons.group, color: KConstants.successColor),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: KTextStyle.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: KConstants.spacingSmall),
                      Text(
                        'Capitão: ${team.captainName}',
                        style: KTextStyle.bodyText.copyWith(
                          color: KConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KConstants.spacingSmall,
                    vertical: KConstants.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: KConstants.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Ativo',
                    style: KTextStyle.smallText.copyWith(
                      color: KConstants.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: KConstants.spacingMedium),

            // Estatísticas
            Row(
              children: [
                _buildStatChip(
                  Icons.people,
                  '${team.currentMembersCount}/${team.maxMembers}',
                ),
                const SizedBox(width: KConstants.spacingSmall),
                _buildStatChip(
                  Icons.sports_soccer,
                  '${team.gamesPlayed} jogos',
                ),
                const SizedBox(width: KConstants.spacingSmall),
                _buildStatChip(
                  Icons.emoji_events,
                  '${(team.winRate * 100).toStringAsFixed(0)}% vitórias',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: KConstants.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: team.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            team.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.group,
                                color: KConstants.errorColor,
                              );
                            },
                          ),
                        )
                      : Icon(Icons.group, color: KConstants.errorColor),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: KTextStyle.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: KConstants.spacingSmall),
                      Text(
                        'Capitão: ${team.captainName}',
                        style: KTextStyle.bodyText.copyWith(
                          color: KConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KConstants.spacingSmall,
                    vertical: KConstants.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: KConstants.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Rejeitado',
                    style: KTextStyle.smallText.copyWith(
                      color: KConstants.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: KConstants.spacingMedium),

            // Motivo da rejeição
            if (team.rejectionReason != null) ...[
              Container(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                decoration: BoxDecoration(
                  color: KConstants.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    KConstants.borderRadiusMedium,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Motivo da Rejeição:',
                      style: KTextStyle.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: KConstants.errorColor,
                      ),
                    ),
                    const SizedBox(height: KConstants.spacingSmall),
                    Text(team.rejectionReason!, style: KTextStyle.bodyText),
                  ],
                ),
              ),
              const SizedBox(height: KConstants.spacingMedium),
            ],

            // Informações adicionais
            Row(
              children: [
                _buildInfoChip(
                  Icons.people,
                  '${team.currentMembersCount}/${team.maxMembers}',
                ),
                const SizedBox(width: KConstants.spacingSmall),
                _buildInfoChip(Icons.flag, team.levelDisplayName),
                const SizedBox(width: KConstants.spacingSmall),
                _buildInfoChip(
                  Icons.calendar_today,
                  _formatDate(team.createdAt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KConstants.spacingSmall,
        vertical: KConstants.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: KConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: KConstants.primaryColor),
          const SizedBox(width: KConstants.spacingXSmall),
          Text(
            text,
            style: KTextStyle.smallText.copyWith(
              color: KConstants.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KConstants.spacingSmall,
        vertical: KConstants.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: KConstants.textSecondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: KConstants.textSecondaryColor),
          const SizedBox(width: KConstants.spacingXSmall),
          Text(
            text,
            style: KTextStyle.smallText.copyWith(
              color: KConstants.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _approveTeam(Team team) async {
    try {
      await TeamService.approveTeam(team.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Time "${team.name}" aprovado com sucesso!'),
          backgroundColor: KConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao aprovar time: $e'),
          backgroundColor: KConstants.errorColor,
        ),
      );
    }
  }

  Future<void> _rejectTeam(Team team) async {
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeitar Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o motivo da rejeição:'),
            const SizedBox(height: KConstants.spacingMedium),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo da rejeição',
                hintText: 'Ex: Nome inadequado, descrição muito curta...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: KConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.trim().isNotEmpty) {
      try {
        await TeamService.rejectTeam(team.id, reasonController.text.trim());

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Time "${team.name}" rejeitado com sucesso!'),
            backgroundColor: KConstants.errorColor,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao rejeitar time: $e'),
            backgroundColor: KConstants.errorColor,
          ),
        );
      }
    }
  }
}
