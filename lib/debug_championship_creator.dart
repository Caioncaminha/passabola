import 'package:firebase_auth/firebase_auth.dart';
import 'data/championship_model.dart';
import 'data/championship_service.dart';

class DebugChampionshipCreator {
  static Future<void> createTestChampionship() async {
    try {
      print('DEBUG: Criando campeonato de teste...');

      final championship = Championship(
        id: '',
        title: 'Campeonato de Teste - Check-in',
        description:
            'Este é um campeonato criado para testar o sistema de check-in',
        location: 'Campo de Teste',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        startDate: DateTime.now().add(
          const Duration(days: 7),
        ), // 7 dias no futuro
        endDate: DateTime.now().add(
          const Duration(days: 14),
        ), // 14 dias no futuro
        registrationStartDate: DateTime.now().subtract(
          const Duration(days: 1),
        ), // Ontem
        registrationEndDate: DateTime.now().add(
          const Duration(days: 5),
        ), // 5 dias no futuro
        status:
            ChampionshipStatus.registrationOpen, // Status que permite check-in
        type: ChampionshipType.knockout,
        registrationType: RegistrationType.teamOnly,
        maxTeams: 8,
        minPlayersPerTeam: 7,
        maxPlayersPerTeam: 11,
        registrationFee: 50.0,
        rules: [
          'Jogos de 90 minutos',
          'Máximo 3 substituições por time',
          'Cartão vermelho = expulsão do jogo',
        ],
        prizes: [
          ChampionshipPrize(
            position: '1º',
            description: 'Troféu + R\$ 500',
            monetaryValue: 500.0,
          ),
          ChampionshipPrize(
            position: '2º',
            description: 'Medalha + R\$ 200',
            monetaryValue: 200.0,
          ),
        ],
        organizerId: FirebaseAuth.instance.currentUser?.uid ?? 'test_organizer',
        organizerName: 'Organizador de Teste',
      );

      final championshipId = await ChampionshipService.createChampionship(
        championship,
      );

      print('DEBUG: Campeonato criado com ID: $championshipId');
      print('DEBUG: Status: ${championship.status}');
      print('DEBUG: canCheckIn: ${championship.canCheckIn}');
      print('DEBUG: isRegistrationOpen: ${championship.isRegistrationOpen}');
    } catch (e) {
      print('DEBUG: Erro ao criar campeonato de teste: $e');
    }
  }

  static Future<void> createChampionshipWithStatus(
    ChampionshipStatus status,
  ) async {
    try {
      print('DEBUG: Criando campeonato com status: $status');

      final championship = Championship(
        id: '',
        title: 'Teste - $status',
        description: 'Campeonato de teste com status $status',
        location: 'Campo de Teste',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 14)),
        registrationStartDate: DateTime.now().subtract(const Duration(days: 1)),
        registrationEndDate: DateTime.now().add(const Duration(days: 5)),
        status: status,
        type: ChampionshipType.knockout,
        registrationType: RegistrationType.teamOnly,
        maxTeams: 8,
        minPlayersPerTeam: 7,
        maxPlayersPerTeam: 11,
        organizerId: FirebaseAuth.instance.currentUser?.uid ?? 'test_organizer',
        organizerName: 'Organizador de Teste',
      );

      final championshipId = await ChampionshipService.createChampionship(
        championship,
      );

      print('DEBUG: Campeonato criado com ID: $championshipId');
      print('DEBUG: Status: ${championship.status}');
      print('DEBUG: canCheckIn: ${championship.canCheckIn}');
      print('DEBUG: isRegistrationOpen: ${championship.isRegistrationOpen}');
    } catch (e) {
      print('DEBUG: Erro ao criar campeonato: $e');
    }
  }
}
