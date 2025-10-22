// --- DEFINIÇÃO ÚNICA E CENTRALIZADA DOS MODELOS ---

class PlayerPosition {
  final double x;
  final double y;
  const PlayerPosition(this.x, this.y);
}

class Time {
  final String nome;
  final String logoUrl;
  final String experiencia;
  final List<PlayerPosition> formacao;

  const Time({
    required this.nome,
    required this.logoUrl,
    required this.experiencia,
    required this.formacao,
  });
}

class Jogo {
  final Time timeCasa;
  final Time timeFora;
  final String placar;
  final String tempo;
  final bool isFinalizado;

  const Jogo({
    required this.timeCasa,
    required this.timeFora,
    required this.placar,
    required this.tempo,
    this.isFinalizado = false,
  });
}

// --- DEFINIÇÃO ÚNICA E CENTRALIZADA DAS FORMAÇÕES ---

const List<PlayerPosition> formation433 = [
  PlayerPosition(0.5, 0.9), // Goleiro
  PlayerPosition(0.15, 0.75), PlayerPosition(0.4, 0.78), PlayerPosition(0.6, 0.78), PlayerPosition(0.85, 0.75),
  PlayerPosition(0.25, 0.5), PlayerPosition(0.5, 0.55), PlayerPosition(0.75, 0.5),
  PlayerPosition(0.2, 0.25), PlayerPosition(0.5, 0.2), PlayerPosition(0.8, 0.25),
];

const List<PlayerPosition> formation442 = [
  PlayerPosition(0.5, 0.9), // Goleiro
  PlayerPosition(0.15, 0.75), PlayerPosition(0.4, 0.78), PlayerPosition(0.6, 0.78), PlayerPosition(0.85, 0.75),
  PlayerPosition(0.1, 0.5), PlayerPosition(0.4, 0.45), PlayerPosition(0.6, 0.45), PlayerPosition(0.9, 0.5),
  PlayerPosition(0.35, 0.25), PlayerPosition(0.65, 0.25),
];