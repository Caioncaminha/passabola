import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/constants.dart';
import '../data/team_service.dart';
import '../data/team_model.dart';

class TeamInvitesPage extends StatefulWidget {
  const TeamInvitesPage({super.key});

  @override
  State<TeamInvitesPage> createState() => _TeamInvitesPageState();
}

class _TeamInvitesPageState extends State<TeamInvitesPage> {
  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    print('TeamInvitesPage - User email: $userEmail');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Convites de Times'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),
      body: StreamBuilder<List<TeamInvite>>(
        stream: TeamService.getUserInvites(userEmail),
        builder: (context, snapshot) {
          print(
            'TeamInvitesPage - Snapshot state: ${snapshot.connectionState}',
          );
          print('TeamInvitesPage - Has error: ${snapshot.hasError}');
          if (snapshot.hasError) {
            print('TeamInvitesPage - Error: ${snapshot.error}');
          }

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
                  Text('Erro ao carregar convites', style: KTextStyle.heading3),
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

          final invites = snapshot.data ?? [];
          print('TeamInvitesPage - Invites count: ${invites.length}');

          if (invites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 64,
                    color: KConstants.textSecondaryColor,
                  ),
                  const SizedBox(height: KConstants.spacingMedium),
                  Text('Nenhum convite pendente', style: KTextStyle.heading3),
                  const SizedBox(height: KConstants.spacingSmall),
                  Text(
                    'Você não possui convites de times no momento',
                    style: KTextStyle.bodyText.copyWith(
                      color: KConstants.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(KConstants.spacingMedium),
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invite = invites[index];
              return _buildInviteCard(invite);
            },
          );
        },
      ),
    );
  }

  Widget _buildInviteCard(TeamInvite invite) {
    return Card(
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do convite
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: KConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.group_add,
                    color: KConstants.primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Convite para Time',
                        style: KTextStyle.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: KConstants.spacingSmall),
                      Text(
                        'Você foi convidado para participar de um time',
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

            // Informações do convite
            Container(
              padding: const EdgeInsets.all(KConstants.spacingMedium),
              decoration: BoxDecoration(
                color: KConstants.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(
                  KConstants.borderRadiusMedium,
                ),
                border: Border.all(
                  color: KConstants.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  _buildInviteInfo(
                    Icons.email,
                    'Email',
                    invite.invitedUserEmail,
                  ),
                  const SizedBox(height: KConstants.spacingSmall),
                  _buildInviteInfo(
                    Icons.calendar_today,
                    'Data do Convite',
                    _formatDate(invite.createdAt),
                  ),
                ],
              ),
            ),

            const SizedBox(height: KConstants.spacingMedium),

            // Informações do time
            FutureBuilder<Team?>(
              future: TeamService.getTeamById(invite.teamId),
              builder: (context, teamSnapshot) {
                if (teamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (teamSnapshot.hasError || teamSnapshot.data == null) {
                  return Container(
                    padding: const EdgeInsets.all(KConstants.spacingMedium),
                    decoration: BoxDecoration(
                      color: KConstants.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        KConstants.borderRadiusMedium,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: KConstants.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: KConstants.spacingSmall),
                        Text(
                          'Erro ao carregar informações do time',
                          style: KTextStyle.bodyText.copyWith(
                            color: KConstants.errorColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final team = teamSnapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(KConstants.spacingMedium),
                  decoration: BoxDecoration(
                    color: KConstants.infoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      KConstants.borderRadiusMedium,
                    ),
                    border: Border.all(
                      color: KConstants.infoColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações do Time',
                        style: KTextStyle.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: KConstants.infoColor,
                        ),
                      ),
                      const SizedBox(height: KConstants.spacingSmall),
                      _buildInviteInfo(Icons.group, 'Nome', team.name),
                      const SizedBox(height: KConstants.spacingSmall),
                      _buildInviteInfo(
                        Icons.person,
                        'Capitão',
                        team.captainName,
                      ),
                      const SizedBox(height: KConstants.spacingSmall),
                      _buildInviteInfo(
                        Icons.people,
                        'Membros',
                        '${team.currentMembersCount}/${team.maxMembers}',
                      ),
                      const SizedBox(height: KConstants.spacingSmall),
                      _buildInviteInfo(
                        Icons.flag,
                        'Nível',
                        team.levelDisplayName,
                      ),
                      if (team.description.isNotEmpty) ...[
                        const SizedBox(height: KConstants.spacingSmall),
                        _buildInviteInfo(
                          Icons.description,
                          'Descrição',
                          team.description,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: KConstants.spacingMedium),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectInvite(invite),
                    icon: const Icon(Icons.close),
                    label: const Text('Recusar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KConstants.errorColor,
                      side: BorderSide(color: KConstants.errorColor),
                    ),
                  ),
                ),
                const SizedBox(width: KConstants.spacingMedium),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptInvite(invite),
                    icon: const Icon(Icons.check),
                    label: const Text('Aceitar'),
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

  Widget _buildInviteInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: KConstants.textSecondaryColor),
        const SizedBox(width: KConstants.spacingSmall),
        Text(
          '$label: ',
          style: KTextStyle.smallText.copyWith(
            fontWeight: FontWeight.w600,
            color: KConstants.textSecondaryColor,
          ),
        ),
        Expanded(child: Text(value, style: KTextStyle.smallText)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} às '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _acceptInvite(TeamInvite invite) async {
    try {
      await TeamService.acceptTeamInvite(invite.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Convite aceito com sucesso!'),
          backgroundColor: KConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao aceitar convite: $e'),
          backgroundColor: KConstants.errorColor,
        ),
      );
    }
  }

  Future<void> _rejectInvite(TeamInvite invite) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recusar Convite'),
        content: const Text(
          'Tem certeza que deseja recusar este convite? '
          'Esta ação não pode ser desfeita.',
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
            child: const Text('Recusar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await TeamService.rejectTeamInvite(invite.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Convite recusado com sucesso!'),
            backgroundColor: KConstants.errorColor,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao recusar convite: $e'),
            backgroundColor: KConstants.errorColor,
          ),
        );
      }
    }
  }
}
