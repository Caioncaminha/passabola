import 'package:flutter/material.dart';
import '../data/constants.dart';

// Uma classe simples para representar a posição de um jogador no campo.
// As coordenadas X e Y são em porcentagem (de 0.0 a 1.0).
class PlayerPosition {
  final double x; // Posição horizontal (0.0 = esquerda, 1.0 = direita)
  final double y; // Posição vertical (0.0 = topo, 1.0 = baixo)

  const PlayerPosition(this.x, this.y);
}

const List<PlayerPosition> formation433 = [
  // Goleiro
  PlayerPosition(0.5, 0.9),
  // Defensores
  PlayerPosition(0.15, 0.75),
  PlayerPosition(0.4, 0.78),
  PlayerPosition(0.6, 0.78),
  PlayerPosition(0.85, 0.75),
  // Meio-campistas
  PlayerPosition(0.25, 0.5),
  PlayerPosition(0.5, 0.55),
  PlayerPosition(0.75, 0.5),
  // Atacantes
  PlayerPosition(0.2, 0.25),
  PlayerPosition(0.5, 0.2),
  PlayerPosition(0.8, 0.25),
];

const List<PlayerPosition> formation442 = [
  // Goleiro
  PlayerPosition(0.5, 0.9),
  // Defensores
  PlayerPosition(0.15, 0.75),
  PlayerPosition(0.4, 0.78),
  PlayerPosition(0.6, 0.78),
  PlayerPosition(0.85, 0.75),
  // Meio-campistas
  PlayerPosition(0.1, 0.5),
  PlayerPosition(0.4, 0.45),
  PlayerPosition(0.6, 0.45),
  PlayerPosition(0.9, 0.5),
  // Atacantes
  PlayerPosition(0.35, 0.25),
  PlayerPosition(0.65, 0.25),
];


class JogosDetalhesPage extends StatelessWidget {
  const JogosDetalhesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KConstants.backgroundColor,
      appBar: AppBar(
        title: Text('DETALHES', style: KTextStyle.buttonText),
        backgroundColor: KConstants.secondaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(KConstants.spacingMedium),
          child: Container(
            padding: const EdgeInsets.all(KConstants.spacingSmall),
            decoration: KDecoration.cardDecoration.copyWith(
              color: KConstants.primaryColor,
              borderRadius: BorderRadius.circular(KConstants.borderRadiusExtraLarge),
            ),
            child: Column(
              children: [
                // Agora passamos a formação como um parâmetro
                _TeamFormationCard(
                  teamName: 'NOME DO TIME',
                  playerColor: Colors.red,
                  formation: formation433,
                ),
                const SizedBox(height: KConstants.spacingMedium),
                _TeamFormationCard(
                  teamName: 'NOME DO TIME',
                  playerColor: Colors.blue,
                  formation: formation442,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamFormationCard extends StatelessWidget {
  final String teamName;
  final Color playerColor;
  final List<PlayerPosition> formation;

  const _TeamFormationCard({
    required this.teamName,
    required this.playerColor,
    required this.formation,
  });

  @override
  Widget build(BuildContext context) {
    const statsPillColor = KConstants.lightGreenColor;
    const double playerDotSize = 42.0;

    return Container(
      decoration: KDecoration.cardDecoration.copyWith(
        color: KConstants.primaryColor.withOpacity(0.5),
      ),
      child: Column(
        children: [
          // Header do time
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: KConstants.spacingSmall),
            decoration: BoxDecoration(
              color: KConstants.secondaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(KConstants.borderRadiusLarge)),
            ),
            child: Text(
              teamName,
              textAlign: TextAlign.center,
              style: KTextStyle.cardTitleText.copyWith(color: KConstants.textLightColor),
            ),
          ),
          // Campo com os jogadores
          Padding(
            padding: const EdgeInsets.all(KConstants.spacingSmall),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(KConstants.borderRadiusMedium),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: LayoutBuilder( // <-- LayoutBuilder para obter o tamanho exato do campo
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Imagem de fundo do campo
                        Image.network(
                          'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQb8Zs780UdlUfzZJAK2lZV-0uBr69ZCsBW9UQ5kQBlVeVOeNbD',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        // Geramos os jogadores dinamicamente a partir da lista
                        ...formation.map((pos) {
                          return Positioned(
                            // Calculamos a posição exata baseada na porcentagem e no tamanho do campo
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
          // Footer de estatísticas
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatsPill(label: 'Faltas: -----', color: statsPillColor),
                _StatsPill(label: 'Pênalti: -----', color: statsPillColor),
                _StatsPill(label: 'Passes: -----', color: statsPillColor),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Widget auxiliar para o ponto do jogador (agora simplificado)
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
      // No futuro, trocar o Container por um CircleAvatar com a foto da jogadora
      // child: CircleAvatar(
      //   backgroundImage: NetworkImage('URL_DA_FOTO_DA_JOGADORA'),
      // ),
    );
  }
}

// Widget auxiliar para as pílulas de estatísticas (inalterado)
class _StatsPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatsPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KConstants.spacingSmall,
        vertical: KConstants.spacingExtraSmall,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text(
        label,
        style: KTextStyle.captionText.copyWith(
          color: KConstants.textLightColor,
          fontSize: 15.0,
        ),
      ),
    );
  }
}