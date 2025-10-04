import 'package:flutter/material.dart';
import '../data/constants.dart';

class JogadoraDashboardPage extends StatelessWidget {
  final Map<String, dynamic> playerData;

  const JogadoraDashboardPage({super.key, required this.playerData});

  @override
  Widget build(BuildContext context) {
    final player = playerData['player'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          player['name'] ?? 'Dashboard da Jogadora',
          style: KTextStyle.buttonText,
        ),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, player),
            const SizedBox(height: KConstants.spacingLarge),
            _buildStatsCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> player) {
    return Container(
      padding: const EdgeInsets.all(KConstants.spacingMedium),
      decoration: KDecoration.cardDecoration,
      child: Row(
        children: [
          player['photo'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    player['photo'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 80);
                    },
                  ),
                )
              : const Icon(Icons.person, size: 80),
          const SizedBox(width: KConstants.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name'] ?? 'Nome não disponível',
                  style: KTextStyle.largeTitleText,
                ),
                const SizedBox(height: 4),
                if (player['position'] != null)
                  Text(
                    'Posição: ${player['position']}',
                    style: KTextStyle.bodySecondaryText,
                  ),
                if (player['age'] != null)
                  Text(
                    'Idade: ${player['age']}',
                    style: KTextStyle.bodySecondaryText,
                  ),
                if (player['nationality'] != null)
                  Text(
                    'Nacionalidade: ${player['nationality']}',
                    style: KTextStyle.bodySecondaryText,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    // Placeholder de estatísticas (passes, finalizações, etc.)
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: KConstants.spacingMedium,
      mainAxisSpacing: KConstants.spacingMedium,
      children: const [
        _StatCard(title: 'Passes certos', value: '—'),
        _StatCard(title: 'Passes errados', value: '—'),
        _StatCard(title: 'Assistências', value: '—'),
        _StatCard(title: 'Finalizações', value: '—'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KConstants.spacingLarge),
      decoration: KDecoration.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: KTextStyle.extraLargeTitleText.copyWith(
              color: KConstants.primaryColor,
            ),
          ),
          const SizedBox(height: KConstants.spacingSmall),
          Text(
            title,
            style: KTextStyle.bodySecondaryText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
