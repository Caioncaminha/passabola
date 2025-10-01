import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/team_service.dart';
import '../data/team_model.dart';

class TeamDetailsPage extends StatefulWidget {
  final Team team;

  const TeamDetailsPage({super.key, required this.team});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  late Team _team;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _team = widget.team;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_team.name),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          IconButton(
            onPressed: _showInviteDialog,
            icon: const Icon(Icons.person_add),
            tooltip: 'Convidar Membro',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header do time
            _buildTeamHeader(),

            // Informações do time
            _buildTeamInfo(),

            // Estatísticas
            _buildTeamStats(),

            // Membros
            _buildTeamMembers(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KConstants.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KConstants.primaryColor,
            KConstants.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Logo do time
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: _team.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      _team.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.group, color: Colors.white, size: 50);
                      },
                    ),
                  )
                : Icon(Icons.group, color: Colors.white, size: 50),
          ),

          const SizedBox(height: KConstants.spacingMedium),

          // Nome do time
          Text(
            _team.name,
            style: KTextStyle.heading1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: KConstants.spacingSmall),

          // Nível do time
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KConstants.spacingMedium,
              vertical: KConstants.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _team.levelDisplayName,
              style: KTextStyle.bodyText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo() {
    return Container(
      padding: const EdgeInsets.all(KConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sobre o Time',
            style: KTextStyle.heading3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: KConstants.spacingMedium),

          Text(_team.description, style: KTextStyle.bodyText),

          const SizedBox(height: KConstants.spacingLarge),

          // Informações adicionais
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.person,
                  'Capitão',
                  _team.captainName,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.people,
                  'Membros',
                  '${_team.currentMembersCount}/${_team.maxMembers}',
                ),
              ),
            ],
          ),

          const SizedBox(height: KConstants.spacingMedium),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today,
                  'Criado em',
                  _formatDate(_team.createdAt),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.flag,
                  'Status',
                  _team.statusDisplayName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(KConstants.spacingMedium),
      decoration: BoxDecoration(
        color: KConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: KConstants.primaryColor, size: 24),
          const SizedBox(height: KConstants.spacingSmall),
          Text(
            label,
            style: KTextStyle.smallText.copyWith(
              color: KConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: KConstants.spacingXSmall),
          Text(
            value,
            style: KTextStyle.bodyText.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStats() {
    return Container(
      padding: const EdgeInsets.all(KConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas',
            style: KTextStyle.heading3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: KConstants.spacingMedium),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Jogos',
                  '${_team.gamesPlayed}',
                  Icons.sports_soccer,
                  KConstants.infoColor,
                ),
              ),
              const SizedBox(width: KConstants.spacingMedium),
              Expanded(
                child: _buildStatCard(
                  'Vitórias',
                  '${_team.gamesWon}',
                  Icons.emoji_events,
                  KConstants.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: KConstants.spacingMedium),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Empates',
                  '${_team.gamesDrawn}',
                  Icons.handshake,
                  KConstants.warningColor,
                ),
              ),
              const SizedBox(width: KConstants.spacingMedium),
              Expanded(
                child: _buildStatCard(
                  'Derrotas',
                  '${_team.gamesLost}',
                  Icons.sentiment_dissatisfied,
                  KConstants.errorColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: KConstants.spacingMedium),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Gols Marcados',
                  '${_team.totalGoals}',
                  Icons.sports_soccer,
                  KConstants.primaryColor,
                ),
              ),
              const SizedBox(width: KConstants.spacingMedium),
              Expanded(
                child: _buildStatCard(
                  'Gols Sofridos',
                  '${_team.totalGoalsConceded}',
                  Icons.sports_soccer,
                  KConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(KConstants.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: KConstants.spacingSmall),
          Text(
            value,
            style: KTextStyle.heading2.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: KConstants.spacingXSmall),
          Text(
            title,
            style: KTextStyle.smallText.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMembers() {
    return Container(
      padding: const EdgeInsets.all(KConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membros (${_team.currentMembersCount}/${_team.maxMembers})',
            style: KTextStyle.heading3.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: KConstants.spacingMedium),

          if (_team.members.isEmpty)
            Container(
              padding: const EdgeInsets.all(KConstants.spacingLarge),
              decoration: BoxDecoration(
                color: KConstants.textSecondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  KConstants.borderRadiusMedium,
                ),
              ),
              child: Center(
                child: Text(
                  'Nenhum membro encontrado',
                  style: KTextStyle.bodyText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _team.members.length,
              itemBuilder: (context, index) {
                final member = _team.members[index];
                return _buildMemberCard(member);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(TeamMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: KConstants.spacingSmall),
      padding: const EdgeInsets.all(KConstants.spacingMedium),
      decoration: BoxDecoration(
        color: member.role == 'captain'
            ? KConstants.primaryColor.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
        border: Border.all(
          color: member.role == 'captain'
              ? KConstants.primaryColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar do membro
          CircleAvatar(
            radius: 20,
            backgroundColor: member.role == 'captain'
                ? KConstants.primaryColor
                : Colors.grey,
            child: Text(
              member.userName.isNotEmpty
                  ? member.userName[0].toUpperCase()
                  : '?',
              style: KTextStyle.bodyText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: KConstants.spacingMedium),

          // Informações do membro
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.userName,
                      style: KTextStyle.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (member.role == 'captain') ...[
                      const SizedBox(width: KConstants.spacingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KConstants.spacingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: KConstants.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Capitão',
                          style: KTextStyle.smallText.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: KConstants.spacingXSmall),
                Text(
                  member.userEmail,
                  style: KTextStyle.smallText.copyWith(
                    color: KConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: KConstants.spacingXSmall),
                Text(
                  'Entrou em ${_formatDate(member.joinedAt)}',
                  style: KTextStyle.smallText.copyWith(
                    color: KConstants.textSecondaryColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Status do membro
          Icon(
            member.isActive ? Icons.check_circle : Icons.cancel,
            color: member.isActive
                ? KConstants.successColor
                : KConstants.errorColor,
            size: 20,
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

  void _showInviteDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convidar Membro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o email do usuário que você deseja convidar:'),
            const SizedBox(height: KConstants.spacingMedium),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'usuario@exemplo.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () => _sendInvite(emailController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: KConstants.primaryColor,
              foregroundColor: KConstants.textLightColor,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: KConstants.textLightColor,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvite(String email) async {
    if (email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um email válido'),
          backgroundColor: KConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await TeamService.inviteUserToTeam(
        teamId: _team.id,
        invitedUserEmail: email.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Convite enviado com sucesso!'),
          backgroundColor: KConstants.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar convite: $e'),
          backgroundColor: KConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
