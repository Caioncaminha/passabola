import 'package:flutter/material.dart';
import '../data/constants.dart';
import 'jogos_detalhes_page.dart';

class JogosPage extends StatefulWidget {
  const JogosPage({super.key});

  @override
  State<JogosPage> createState() => _JogosPageState();
}

class _JogosPageState extends State<JogosPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: KConstants.spacingSmall),
          // Container branco para as abas
          Container(
            color: KConstants.backgroundColor,
            padding: const EdgeInsets.symmetric(
              horizontal: KConstants.spacingMedium,
              vertical: KConstants.spacingSmall,
            ),
            child: Row(
              children: [
                _buildTabItem("Próximos jogos", 0),
                const SizedBox(width: KConstants.spacingLarge),
                _buildTabItem("Jogos finalizados", 1),
              ],
            ),
          ),
          // Lista de jogos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(KConstants.spacingMedium),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _GameCard(
                  onDetailsPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JogosDetalhesPage()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para os itens da aba
  Widget _buildTabItem(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    const activeColor = Color(0xFF708F56); 

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: isSelected
                  ? KTextStyle.navigationText.copyWith(color: activeColor, fontWeight: FontWeight.bold)
                  : KTextStyle.navigationText,
            ),
            const SizedBox(height: KConstants.spacingExtraSmall),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: isSelected ? 3 : 0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(KConstants.borderRadiusSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para o Card de Jogo
class _GameCard extends StatelessWidget {
  final VoidCallback onDetailsPressed;

  const _GameCard({required this.onDetailsPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KConstants.spacingMedium),
      margin: const EdgeInsets.only(bottom: KConstants.spacingMedium),
      decoration: KDecoration.cardDecoration.copyWith(
        color: KConstants.primaryColor,
        border: Border(bottom: BorderSide(color: KConstants.backgroundColor.withOpacity(0.5), width: 2))
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TeamInfo(
                logoUrl: 'https://media.istockphoto.com/id/1441935485/pt/vetorial/soccer-team-emblem-logo-design-vector-illustration.jpg?s=612x612&w=0&k=20&c=pwKR0uBNbrV1OX6l17XbovhJuBmlVE170zxGiOUO2nw=',
                name: 'NOME DO TIME',
                level: 'EXPERIÊNCIA',
              ),
              _ScoreInfo(score: '0 - 0', time: '00:00'),
              _TeamInfo(
                logoUrl: 'https://media.istockphoto.com/id/1441935485/pt/vetorial/soccer-team-emblem-logo-design-vector-illustration.jpg?s=612x612&w=0&k=20&c=pwKR0uBNbrV1OX6l17XbovhJuBmlVE170zxGiOUO2nw=',
                name: 'NOME DO TIME',
                level: 'EXPERIÊNCIA',
              ),
            ],
          ),
          const SizedBox(height: KConstants.spacingLarge),
          ElevatedButton(
            onPressed: onDetailsPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: KConstants.secondaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KConstants.borderRadiusLarge),
              ),
            ),
            child: Text('DETALHES', style: KTextStyle.buttonText),
          )
        ],
      ),
    );
  }
}

// Widgets auxiliares para o Card de Jogo
class _TeamInfo extends StatelessWidget {
  final String logoUrl;
  final String name;
  final String level;

  const _TeamInfo({required this.logoUrl, required this.name, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(logoUrl, height: 60),
        const SizedBox(height: KConstants.spacingSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KConstants.spacingSmall,
            vertical: KConstants.spacingExtraSmall,
          ),
          decoration: BoxDecoration(
            color: KConstants.secondaryColor,
            borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
          ),
          child: Column(
            children: [
              Text(name, style: KTextStyle.smallText.copyWith(color: KConstants.textLightColor)),
              Text(level, style: KTextStyle.captionText.copyWith(color: KConstants.textLightColor)),
            ],
          ),
        )
      ],
    );
  }
}

class _ScoreInfo extends StatelessWidget {
  final String score;
  final String time;

  const _ScoreInfo({required this.score, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(score, style: KTextStyle.extraLargeTitleText.copyWith(color: KConstants.textLightColor)),
        Text(time, style: KTextStyle.bodySecondaryText.copyWith(color: KConstants.textLightColor)),
      ],
    );
  }
}