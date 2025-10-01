import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/team_service.dart';
import '../data/team_model.dart';
import 'team_details_page.dart';
import 'team_create_page.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Times'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          IconButton(
            onPressed: () => _showCreateTeamDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'Criar Time',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(KConstants.spacingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar times...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: KConstants.textSecondaryColor,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(
                          Icons.clear,
                          color: KConstants.textSecondaryColor,
                        ),
                      )
                    : null,
                hintStyle: KTextStyle.inputHintText,
                labelStyle: KTextStyle.inputLabelText,
                filled: true,
                fillColor: KConstants.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    KConstants.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: KConstants.surfaceColor.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    KConstants.borderRadiusMedium,
                  ),
                  borderSide: BorderSide(
                    color: KConstants.surfaceColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    KConstants.borderRadiusMedium,
                  ),
                  borderSide: const BorderSide(
                    color: KConstants.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: KConstants.spacingMedium,
                  vertical: KConstants.spacingMedium,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Lista de times
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildTeamsList()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsList() {
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
                Text('Erro ao carregar times', style: KTextStyle.heading3),
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
                Text('Nenhum time encontrado', style: KTextStyle.heading3),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  'Seja o primeiro a criar um time!',
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: KConstants.spacingLarge),
                ElevatedButton.icon(
                  onPressed: () => _showCreateTeamDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KConstants.primaryColor,
                    foregroundColor: KConstants.textLightColor,
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
            return _buildTeamCard(team);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Team>>(
      stream: TeamService.searchTeams(_searchQuery),
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
                Text('Erro ao buscar times', style: KTextStyle.heading3),
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
                  Icons.search_off,
                  size: 64,
                  color: KConstants.textSecondaryColor,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                Text('Nenhum time encontrado', style: KTextStyle.heading3),
                const SizedBox(height: KConstants.spacingSmall),
                Text(
                  'Tente buscar com outros termos',
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
            return _buildTeamCard(team);
          },
        );
      },
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      child: InkWell(
        onTap: () => _navigateToTeamDetails(team),
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do time
              Row(
                children: [
                  // Logo do time
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: KConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        KConstants.borderRadiusSmall,
                      ),
                    ),
                    child: team.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              KConstants.borderRadiusSmall,
                            ),
                            child: Image.network(
                              team.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.group,
                                  color: KConstants.primaryColor,
                                );
                              },
                            ),
                          )
                        : Icon(Icons.group, color: KConstants.primaryColor),
                  ),
                  const SizedBox(width: KConstants.spacingMedium),

                  // Informações do time
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
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: KConstants.textSecondaryColor,
                            ),
                            const SizedBox(width: KConstants.spacingSmall),
                            Text(
                              'Capitão: ${team.captainName}',
                              style: KTextStyle.smallText.copyWith(
                                color: KConstants.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Nível do time
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KConstants.spacingSmall,
                      vertical: KConstants.spacingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(team.level).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        KConstants.borderRadiusSmall,
                      ),
                    ),
                    child: Text(
                      team.levelDisplayName,
                      style: KTextStyle.smallText.copyWith(
                        color: _getLevelColor(team.level),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: KConstants.spacingMedium),

              // Estatísticas
              Row(
                children: [
                  _buildStatItem(
                    Icons.people,
                    '${team.currentMembersCount}/${team.maxMembers}',
                    'Membros',
                  ),
                  const SizedBox(width: KConstants.spacingLarge),
                  _buildStatItem(
                    Icons.sports_soccer,
                    '${team.gamesPlayed}',
                    'Jogos',
                  ),
                  const SizedBox(width: KConstants.spacingLarge),
                  _buildStatItem(
                    Icons.emoji_events,
                    '${(team.winRate * 100).toStringAsFixed(0)}%',
                    'Vitórias',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: KConstants.textSecondaryColor),
        const SizedBox(width: KConstants.spacingXSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: KTextStyle.smallText.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              label,
              style: KTextStyle.smallText.copyWith(
                color: KConstants.textSecondaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getLevelColor(TeamLevel level) {
    switch (level) {
      case TeamLevel.beginner:
        return KConstants.successColor;
      case TeamLevel.amateur:
        return KConstants.infoColor;
      case TeamLevel.semiPro:
        return KConstants.warningColor;
      case TeamLevel.professional:
        return KConstants.primaryColor;
    }
  }

  void _navigateToTeamDetails(Team team) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TeamDetailsPage(team: team)),
    );
  }

  void _showCreateTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Time'),
        content: const Text(
          'Você pode criar apenas uma solicitação de time por vez. '
          'Sua solicitação será analisada por um administrador.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TeamCreatePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KConstants.primaryColor,
              foregroundColor: KConstants.textLightColor,
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}
