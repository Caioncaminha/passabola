import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkin_model.dart';
import 'championship_model.dart';
import 'team_model.dart';

class CheckInService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Coleções
  static const String _teamCheckInsCollection = 'team_checkins';
  static const String _individualCheckInsCollection = 'individual_checkins';
  static const String _generatedTeamsCollection = 'generated_teams';
  static const String _championshipsCollection = 'championships';
  static const String _teamsCollection = 'teams';
  static const String _usersCollection = 'usuarios';

  // ========== CHECK-IN DE TIMES ==========

  /// Fazer check-in de um time completo
  static Future<String> checkInTeam({
    required String championshipId,
    required String teamId,
    required List<PlayerCheckIn> players,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se o campeonato existe
      final championshipDoc = await _firestore
          .collection(_championshipsCollection)
          .doc(championshipId)
          .get();

      if (!championshipDoc.exists) {
        throw Exception('Campeonato não encontrado');
      }

      final championship = Championship.fromFirestore(championshipDoc);

      // Verificar se o campeonato permite check-in de times
      if (!championship.canRegisterTeams) {
        throw Exception('Este campeonato não permite check-in de times');
      }

      // Verificar se o time existe
      final teamDoc = await _firestore
          .collection(_teamsCollection)
          .doc(teamId)
          .get();

      if (!teamDoc.exists) {
        throw Exception('Time não encontrado');
      }

      final team = Team.fromFirestore(teamDoc);

      // Verificar se o usuário é capitão do time
      if (team.captainId != user.uid) {
        throw Exception('Apenas o capitão pode fazer check-in do time');
      }

      // Verificar se já existe check-in para este time neste campeonato
      final existingCheckIn = await _firestore
          .collection(_teamCheckInsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .where('teamId', isEqualTo: teamId)
          .get();

      if (existingCheckIn.docs.isNotEmpty) {
        throw Exception('Time já fez check-in neste campeonato');
      }

      // Verificar número mínimo de jogadores
      final presentPlayers = players.where((p) => p.isPresent).length;
      if (presentPlayers < championship.minPlayersPerTeam) {
        throw Exception(
          'Número insuficiente de jogadores presentes. '
          'Mínimo: ${championship.minPlayersPerTeam}, '
          'Presentes: $presentPlayers',
        );
      }

      // Criar check-in
      final teamCheckIn = TeamCheckIn(
        id: '',
        championshipId: championshipId,
        teamId: teamId,
        teamName: team.name,
        captainId: user.uid,
        captainName: team.captainName,
        players: players,
        checkInTime: DateTime.now(),
        status: CheckInStatus.confirmed,
        notes: notes,
      );

      final docRef = await _firestore
          .collection(_teamCheckInsCollection)
          .add(teamCheckIn.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao fazer check-in do time: $e');
    }
  }

  /// Atualizar check-in de time
  static Future<void> updateTeamCheckIn({
    required String checkInId,
    List<PlayerCheckIn>? players,
    CheckInStatus? status,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se o check-in existe e pertence ao usuário
      final checkInDoc = await _firestore
          .collection(_teamCheckInsCollection)
          .doc(checkInId)
          .get();

      if (!checkInDoc.exists) {
        throw Exception('Check-in não encontrado');
      }

      final checkIn = TeamCheckIn.fromFirestore(checkInDoc);

      if (checkIn.captainId != user.uid) {
        throw Exception('Você não pode atualizar este check-in');
      }

      // Preparar dados para atualização
      final updateData = <String, dynamic>{};

      if (players != null) {
        updateData['players'] = players.map((p) => p.toMap()).toList();
      }

      if (status != null) {
        updateData['status'] = status.name;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await _firestore
          .collection(_teamCheckInsCollection)
          .doc(checkInId)
          .update(updateData);
    } catch (e) {
      throw Exception('Erro ao atualizar check-in: $e');
    }
  }

  /// Cancelar check-in de time
  static Future<void> cancelTeamCheckIn(String checkInId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se o check-in existe e pertence ao usuário
      final checkInDoc = await _firestore
          .collection(_teamCheckInsCollection)
          .doc(checkInId)
          .get();

      if (!checkInDoc.exists) {
        throw Exception('Check-in não encontrado');
      }

      final checkIn = TeamCheckIn.fromFirestore(checkInDoc);

      if (checkIn.captainId != user.uid) {
        throw Exception('Você não pode cancelar este check-in');
      }

      await _firestore
          .collection(_teamCheckInsCollection)
          .doc(checkInId)
          .update({'status': CheckInStatus.cancelled.name});
    } catch (e) {
      throw Exception('Erro ao cancelar check-in: $e');
    }
  }

  // ========== CHECK-IN INDIVIDUAL ==========

  /// Fazer check-in individual para formação de times
  static Future<String> checkInIndividual({
    required String championshipId,
    required String preferredPosition,
    required String skillLevel,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se o campeonato existe
      final championshipDoc = await _firestore
          .collection(_championshipsCollection)
          .doc(championshipId)
          .get();

      if (!championshipDoc.exists) {
        throw Exception('Campeonato não encontrado');
      }

      final championship = Championship.fromFirestore(championshipDoc);

      // Verificar se o campeonato permite check-in individual
      if (!championship.canRegisterIndividuals) {
        throw Exception('Este campeonato não permite check-in individual');
      }

      // Verificar se já existe check-in individual para este usuário neste campeonato
      final existingCheckIn = await _firestore
          .collection(_individualCheckInsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingCheckIn.docs.isNotEmpty) {
        throw Exception('Você já fez check-in neste campeonato');
      }

      // Obter dados do usuário
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};
      final userName = userData['nome'] ?? user.displayName ?? 'Usuário';

      // Criar check-in individual
      final individualCheckIn = IndividualCheckIn(
        id: '',
        championshipId: championshipId,
        userId: user.uid,
        userName: userName,
        userEmail: user.email ?? '',
        preferredPosition: preferredPosition,
        skillLevel: skillLevel,
        checkInTime: DateTime.now(),
        status: CheckInStatus.confirmed,
        notes: notes,
      );

      final docRef = await _firestore
          .collection(_individualCheckInsCollection)
          .add(individualCheckIn.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao fazer check-in individual: $e');
    }
  }

  /// Atualizar check-in individual
  static Future<void> updateIndividualCheckIn({
    required String checkInId,
    String? preferredPosition,
    String? skillLevel,
    CheckInStatus? status,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se o check-in existe e pertence ao usuário
      final checkInDoc = await _firestore
          .collection(_individualCheckInsCollection)
          .doc(checkInId)
          .get();

      if (!checkInDoc.exists) {
        throw Exception('Check-in não encontrado');
      }

      final checkIn = IndividualCheckIn.fromFirestore(checkInDoc);

      if (checkIn.userId != user.uid) {
        throw Exception('Você não pode atualizar este check-in');
      }

      // Preparar dados para atualização
      final updateData = <String, dynamic>{};

      if (preferredPosition != null) {
        updateData['preferredPosition'] = preferredPosition;
      }

      if (skillLevel != null) {
        updateData['skillLevel'] = skillLevel;
      }

      if (status != null) {
        updateData['status'] = status.name;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      await _firestore
          .collection(_individualCheckInsCollection)
          .doc(checkInId)
          .update(updateData);
    } catch (e) {
      throw Exception('Erro ao atualizar check-in: $e');
    }
  }

  /// Cancelar check-in individual
  static Future<void> cancelIndividualCheckIn(String checkInId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se o check-in existe e pertence ao usuário
      final checkInDoc = await _firestore
          .collection(_individualCheckInsCollection)
          .doc(checkInId)
          .get();

      if (!checkInDoc.exists) {
        throw Exception('Check-in não encontrado');
      }

      final checkIn = IndividualCheckIn.fromFirestore(checkInDoc);

      if (checkIn.userId != user.uid) {
        throw Exception('Você não pode cancelar este check-in');
      }

      await _firestore
          .collection(_individualCheckInsCollection)
          .doc(checkInId)
          .update({'status': CheckInStatus.cancelled.name});
    } catch (e) {
      throw Exception('Erro ao cancelar check-in: $e');
    }
  }

  // ========== CONSULTAS ==========

  /// Listar check-ins de times de um campeonato
  static Future<List<TeamCheckIn>> getTeamCheckIns(
    String championshipId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_teamCheckInsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .orderBy('checkInTime', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => TeamCheckIn.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar check-ins de times: $e');
    }
  }

  /// Listar check-ins individuais de um campeonato
  static Future<List<IndividualCheckIn>> getIndividualCheckIns(
    String championshipId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_individualCheckInsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .orderBy('checkInTime', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => IndividualCheckIn.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar check-ins individuais: $e');
    }
  }

  /// Obter check-in de time por ID
  static Future<TeamCheckIn?> getTeamCheckInById(String checkInId) async {
    try {
      final doc = await _firestore
          .collection(_teamCheckInsCollection)
          .doc(checkInId)
          .get();

      if (!doc.exists) return null;
      return TeamCheckIn.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao buscar check-in de time: $e');
    }
  }

  /// Obter check-in individual por ID
  static Future<IndividualCheckIn?> getIndividualCheckInById(
    String checkInId,
  ) async {
    try {
      final doc = await _firestore
          .collection(_individualCheckInsCollection)
          .doc(checkInId)
          .get();

      if (!doc.exists) return null;
      return IndividualCheckIn.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao buscar check-in individual: $e');
    }
  }

  /// Verificar se um usuário já fez check-in em um campeonato
  static Future<bool> hasUserCheckedIn(
    String championshipId,
    String userId,
  ) async {
    try {
      // Verificar check-in de time
      final teamCheckIns = await _firestore
          .collection(_teamCheckInsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .where('captainId', isEqualTo: userId)
          .get();

      if (teamCheckIns.docs.isNotEmpty) return true;

      // Verificar check-in individual
      final individualCheckIns = await _firestore
          .collection(_individualCheckInsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .where('userId', isEqualTo: userId)
          .get();

      return individualCheckIns.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Erro ao verificar check-in: $e');
    }
  }

  // ========== FORMAÇÃO AUTOMÁTICA DE TIMES ==========

  /// Gerar times automaticamente a partir dos check-ins individuais
  static Future<List<GeneratedTeam>> generateTeamsFromIndividuals(
    String championshipId,
  ) async {
    try {
      // Obter todos os check-ins individuais confirmados
      final individualCheckIns = await _firestore
          .collection(_individualCheckInsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .where('status', isEqualTo: CheckInStatus.confirmed.name)
          .where('assignedTeamId', isEqualTo: null)
          .get();

      final players = individualCheckIns.docs
          .map((doc) => IndividualCheckIn.fromFirestore(doc))
          .toList();

      if (players.length < 14) {
        // Mínimo para formar 2 times
        throw Exception('Número insuficiente de jogadores para formar times');
      }

      // Algoritmo simples de balanceamento
      final teams = <GeneratedTeam>[];
      final playersPerTeam = players.length ~/ (players.length ~/ 11);

      for (int i = 0; i < players.length ~/ playersPerTeam; i++) {
        final teamPlayers = players
            .skip(i * playersPerTeam)
            .take(playersPerTeam)
            .toList();

        final team = GeneratedTeam(
          id: '',
          championshipId: championshipId,
          name: 'Time ${i + 1}',
          players: teamPlayers,
          createdAt: DateTime.now(),
          isBalanced: true,
        );

        // Salvar time gerado
        final docRef = await _firestore
            .collection(_generatedTeamsCollection)
            .add(team.toFirestore());

        // Atualizar check-ins individuais com o time atribuído
        final batch = _firestore.batch();
        for (final player in teamPlayers) {
          final playerDoc = individualCheckIns.docs.firstWhere(
            (doc) => doc.id == player.id,
          );

          batch.update(playerDoc.reference, {
            'assignedTeamId': docRef.id,
            'assignedTeamName': team.name,
          });
        }
        await batch.commit();

        teams.add(team.copyWith(id: docRef.id));
      }

      return teams;
    } catch (e) {
      throw Exception('Erro ao gerar times: $e');
    }
  }

  /// Listar times gerados de um campeonato
  static Future<List<GeneratedTeam>> getGeneratedTeams(
    String championshipId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_generatedTeamsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => GeneratedTeam.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar times gerados: $e');
    }
  }

  // ========== ESTATÍSTICAS ==========

  /// Obter estatísticas de check-in de um campeonato
  static Future<Map<String, int>> getCheckInStats(String championshipId) async {
    try {
      final teamCheckIns = await getTeamCheckIns(championshipId);
      final individualCheckIns = await getIndividualCheckIns(championshipId);

      int totalTeamCheckIns = teamCheckIns.length;
      int confirmedTeamCheckIns = teamCheckIns
          .where((c) => c.status == CheckInStatus.confirmed)
          .length;

      int totalIndividualCheckIns = individualCheckIns.length;
      int confirmedIndividualCheckIns = individualCheckIns
          .where((c) => c.status == CheckInStatus.confirmed)
          .length;

      int assignedIndividuals = individualCheckIns
          .where((c) => c.isAssigned)
          .length;

      return {
        'totalTeams': totalTeamCheckIns,
        'confirmedTeams': confirmedTeamCheckIns,
        'totalIndividuals': totalIndividualCheckIns,
        'confirmedIndividuals': confirmedIndividualCheckIns,
        'assignedIndividuals': assignedIndividuals,
        'unassignedIndividuals':
            confirmedIndividualCheckIns - assignedIndividuals,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}
