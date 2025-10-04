import 'package:flutter/material.dart';
import '../data/constants.dart';

/// Widget de exemplo demonstrando como usar as funções utilitárias de TeamUtils
class TeamUtilsExample extends StatefulWidget {
  const TeamUtilsExample({super.key});

  @override
  State<TeamUtilsExample> createState() => _TeamUtilsExampleState();
}

class _TeamUtilsExampleState extends State<TeamUtilsExample> {
  bool _isUserInTeam = false;
  String? _userTeamId;
  bool _canCreateTeam = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamStatus();
  }

  Future<void> _loadTeamStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isInTeam = await TeamUtils.isUserInTeam();
      final teamId = await TeamUtils.getUserTeamId();
      final canCreate = await TeamUtils.canUserCreateTeam();

      setState(() {
        _isUserInTeam = isInTeam;
        _userTeamId = teamId;
        _canCreateTeam = canCreate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar status do time: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status do Time', style: KTextStyle.heading3),
            const SizedBox(height: 16),

            // Status do usuário
            _buildStatusRow(
              'Usuário está em time:',
              _isUserInTeam ? 'Sim' : 'Não',
              _isUserInTeam ? KConstants.successColor : KConstants.warningColor,
            ),

            if (_userTeamId != null)
              _buildStatusRow(
                'ID do time:',
                _userTeamId!,
                KConstants.textPrimaryColor,
              ),

            _buildStatusRow(
              'Pode criar time:',
              _canCreateTeam ? 'Sim' : 'Não',
              _canCreateTeam ? KConstants.successColor : KConstants.errorColor,
            ),

            const SizedBox(height: 16),

            // Botão de criar time (só aparece se puder criar)
            if (_canCreateTeam)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Aqui você pode navegar para a página de criação de time
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navegando para criação de time...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Time'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KConstants.primaryColor,
                    foregroundColor: KConstants.textLightColor,
                  ),
                ),
              ),

            // Botão de atualizar status
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadTeamStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: KTextStyle.bodyText.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: KTextStyle.bodyText.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
