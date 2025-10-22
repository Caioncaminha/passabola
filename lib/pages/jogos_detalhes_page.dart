import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../models/jogo_models.dart';

class JogosDetalhesPage extends StatelessWidget {
  final Jogo jogo;
  const JogosDetalhesPage({super.key, required this.jogo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KConstants.primaryColor,
      appBar: AppBar(
        title: Text('Detalhes da Partida', style: KTextStyle.titleText.copyWith(color: KConstants.textLightColor)),
        backgroundColor: Colors.transparent,
        foregroundColor: KConstants.textLightColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          child: Column(
            children: [
              _TeamFormationCard(
                time: jogo.timeCasa,
                playerColor: KConstants.errorColor,
              ),
              const SizedBox(height: KConstants.spacingMedium),
              _TeamFormationCard(
                time: jogo.timeFora,
                playerColor: KConstants.infoColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Card de Formação com design
class _TeamFormationCard extends StatelessWidget {
  final Time time;
  final Color playerColor;

  const _TeamFormationCard({required this.time, required this.playerColor});

  @override
  Widget build(BuildContext context) {
    const double playerDotSize = 35.0;

    return Container(
      decoration: KDecoration.cardDecoration,
      child: Column(
        children: [
          // Header do time
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Image.network(time.logoUrl, height: 32, width: 32),
                const SizedBox(width: KConstants.spacingSmall),
                Text(time.nome, style: KTextStyle.cardTitleText),
              ],
            ),
          ),
                    Padding(
            padding: const EdgeInsets.all(KConstants.spacingSmall),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
              child: AspectRatio(
                aspectRatio: 2 / 2.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Image.network(
                            'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQb8Zs780UdlUfzZJAK2lZV-0uBr69ZCsBW9UQ5kQBlVeVOeNbD',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          ...time.formacao.map((pos) {
                            return Positioned(
                              top: constraints.maxHeight * pos.y - (playerDotSize / 2),
                              left: constraints.maxWidth * pos.x - (playerDotSize / 2),
                              child: _PlayerDot(color: playerColor, size: playerDotSize),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Footer de estatísticas
          Padding(
            padding: const EdgeInsets.all(KConstants.spacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(value: '0', label: 'Faltas'),
                _StatItem(value: '0', label: 'Pênaltis'),
                _StatItem(value: '0', label: 'Passes'),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Widget auxiliar para as estatísticas
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: KTextStyle.titleText),
        const SizedBox(height: KConstants.spacingExtraSmall),
        Text(label, style: KTextStyle.smallText),
      ],
    );
  }
}

// Widget do ponto do jogador
class _PlayerDot extends StatelessWidget {
  final Color color;
  final double size;

  const _PlayerDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 1)
          )
        ]
      ),
    );
  }
}