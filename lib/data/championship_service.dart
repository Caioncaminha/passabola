import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'championship_model.dart';
import 'team_model.dart';

class ChampionshipService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Coleções
  static const String _championshipsCollection = 'championships';
  static const String _registrationsCollection = 'championship_registrations';
  static const String _teamsCollection = 'teams';
  static const String _usersCollection = 'usuarios';

  // ========== CRUD de Campeonatos ==========

  /// Criar um novo campeonato
  static Future<String> createChampionship(Championship championship) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final docRef = await _firestore
          .collection(_championshipsCollection)
          .add(championship.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar campeonato: $e');
    }
  }

  /// Atualizar campeonato existente
  static Future<void> updateChampionship(Championship championship) async {
    try {
      await _firestore
          .collection(_championshipsCollection)
          .doc(championship.id)
          .update(
            championship.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Erro ao atualizar campeonato: $e');
    }
  }

  /// Deletar campeonato
  static Future<void> deleteChampionship(String championshipId) async {
    try {
      final batch = _firestore.batch();

      // Deletar campeonato
      batch.delete(
        _firestore.collection(_championshipsCollection).doc(championshipId),
      );

      // Deletar todas as inscrições relacionadas
      final registrations = await _firestore
          .collection(_registrationsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .get();

      for (final doc in registrations.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar campeonato: $e');
    }
  }

  /// Obter campeonato por ID
  static Future<Championship?> getChampionshipById(String id) async {
    try {
      final doc = await _firestore
          .collection(_championshipsCollection)
          .doc(id)
          .get();

      if (!doc.exists) return null;
      return Championship.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao buscar campeonato: $e');
    }
  }

  /// Listar todos os campeonatos
  static Future<List<Championship>> getAllChampionships({
    ChampionshipStatus? status,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection(_championshipsCollection)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Championship.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar campeonatos: $e');
    }
  }

  /// Listar campeonatos públicos (para usuários normais)
  static Future<List<Championship>> getPublicChampionships({
    int limit = 20,
  }) async {
    try {
      // Verificar se o usuário está autenticado
      final user = _auth.currentUser;
      if (user == null) {
        return []; // Retorna lista vazia se não estiver autenticado
      }

      // Buscar todos os campeonatos e filtrar no código para evitar problemas com whereIn
      final querySnapshot = await _firestore
          .collection(_championshipsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      // Se não há documentos, retorna lista vazia
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final publicStatuses = [
        ChampionshipStatus.published.name,
        ChampionshipStatus.registrationOpen.name,
        ChampionshipStatus.registrationClosed.name,
        ChampionshipStatus.ongoing.name,
        ChampionshipStatus.finished.name,
      ];

      final championships = <Championship>[];

      for (final doc in querySnapshot.docs) {
        try {
          final championship = Championship.fromFirestore(doc);
          if (publicStatuses.contains(championship.status.name)) {
            championships.add(championship);
            if (championships.length >= limit) break;
          }
        } catch (docError) {
          // Log do erro mas continua processando outros documentos
          print('Erro ao processar documento ${doc.id}: $docError');
          continue;
        }
      }

      return championships;
    } catch (e) {
      print('Erro detalhado ao listar campeonatos públicos: $e');
      return []; // Retorna lista vazia em caso de erro
    }
  }

  // ========== Gerenciamento de Status ==========

  /// Publicar campeonato (mudar de draft para published)
  static Future<void> publishChampionship(String championshipId) async {
    try {
      await _firestore
          .collection(_championshipsCollection)
          .doc(championshipId)
          .update({
            'status': ChampionshipStatus.published.name,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Erro ao publicar campeonato: $e');
    }
  }

  /// Abrir inscrições
  static Future<void> openRegistrations(String championshipId) async {
    try {
      await _firestore
          .collection(_championshipsCollection)
          .doc(championshipId)
          .update({
            'status': ChampionshipStatus.registrationOpen.name,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Erro ao abrir inscrições: $e');
    }
  }

  /// Fechar inscrições
  static Future<void> closeRegistrations(String championshipId) async {
    try {
      await _firestore
          .collection(_championshipsCollection)
          .doc(championshipId)
          .update({
            'status': ChampionshipStatus.registrationClosed.name,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Erro ao fechar inscrições: $e');
    }
  }

  /// Iniciar campeonato
  static Future<void> startChampionship(String championshipId) async {
    try {
      await _firestore
          .collection(_championshipsCollection)
          .doc(championshipId)
          .update({
            'status': ChampionshipStatus.ongoing.name,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
    } catch (e) {
      throw Exception('Erro ao iniciar campeonato: $e');
    }
  }

  // ========== Sistema de Inscrições ==========

  /// Inscrever time em campeonato
  static Future<String> registerTeam({
    required String championshipId,
    required String teamId,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se o campeonato existe e permite inscrição de times
      final championship = await getChampionshipById(championshipId);
      if (championship == null) {
        throw Exception('Campeonato não encontrado');
      }

      if (!championship.canRegisterTeams) {
        throw Exception('Este campeonato não permite inscrição de times');
      }

      if (!championship.isRegistrationOpen) {
        throw Exception('Inscrições não estão abertas para este campeonato');
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
        throw Exception('Apenas o capitão pode inscrever o time');
      }

      // Verificar se o time já está inscrito
      final existingRegistration = await _firestore
          .collection(_registrationsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .where('teamId', isEqualTo: teamId)
          .get();

      if (existingRegistration.docs.isNotEmpty) {
        throw Exception('Time já está inscrito neste campeonato');
      }

      // Verificar número de jogadores do time
      if (team.currentMembersCount < championship.minPlayersPerTeam) {
        throw Exception(
          'Time precisa ter pelo menos ${championship.minPlayersPerTeam} jogadores',
        );
      }

      // Criar inscrição
      final registration = ChampionshipRegistration(
        id: '',
        championshipId: championshipId,
        userId: user.uid,
        userEmail: user.email ?? '',
        userName: team.captainName,
        teamId: teamId,
        teamName: team.name,
        registeredAt: DateTime.now(),
        additionalInfo: additionalInfo,
      );

      final docRef = await _firestore
          .collection(_registrationsCollection)
          .add(registration.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao inscrever time: $e');
    }
  }

  /// Inscrever indivíduo para formação de time
  static Future<String> registerIndividual({
    required String championshipId,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se o campeonato existe e permite inscrição individual
      final championship = await getChampionshipById(championshipId);
      if (championship == null) {
        throw Exception('Campeonato não encontrado');
      }

      if (!championship.canRegisterIndividuals) {
        throw Exception('Este campeonato não permite inscrição individual');
      }

      if (!championship.isRegistrationOpen) {
        throw Exception('Inscrições não estão abertas para este campeonato');
      }

      // Verificar se o usuário já está inscrito
      final existingRegistration = await _firestore
          .collection(_registrationsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingRegistration.docs.isNotEmpty) {
        throw Exception('Você já está inscrito neste campeonato');
      }

      // Obter dados do usuário (tentar ambas as coleções)
      DocumentSnapshot? userDoc;
      try {
        userDoc = await _firestore.collection('jogadoras').doc(user.uid).get();
      } catch (e) {
        // Fallback para coleção usuarios
        userDoc = await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .get();
      }

      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      final userName = userData['nome'] ?? user.displayName ?? 'Usuário';

      print('DEBUG: Dados do usuário encontrados:');
      print('DEBUG: - userData: $userData');
      print('DEBUG: - userName: $userName');
      print('DEBUG: - user.uid: ${user.uid}');
      print('DEBUG: - user.email: ${user.email}');

      // Criar inscrição
      final registration = ChampionshipRegistration(
        id: '',
        championshipId: championshipId,
        userId: user.uid,
        userEmail: user.email ?? '',
        userName: userName,
        registeredAt: DateTime.now(),
        additionalInfo: additionalInfo,
      );

      print('DEBUG: Criando inscrição individual:');
      print('DEBUG: - championshipId: $championshipId');
      print('DEBUG: - userId: ${user.uid}');
      print('DEBUG: - userName: $userName');
      print('DEBUG: - userEmail: ${user.email}');

      final docRef = await _firestore
          .collection(_registrationsCollection)
          .add(registration.toFirestore());

      print('DEBUG: Inscrição individual criada com ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao inscrever indivíduo: $e');
    }
  }

  /// Cancelar inscrição
  static Future<void> cancelRegistration(String registrationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se a inscrição pertence ao usuário
      final registrationDoc = await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .get();

      if (!registrationDoc.exists) {
        throw Exception('Inscrição não encontrada');
      }

      final registration = ChampionshipRegistration.fromFirestore(
        registrationDoc,
      );

      if (registration.userId != user.uid) {
        throw Exception('Você não pode cancelar esta inscrição');
      }

      // Deletar inscrição
      await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao cancelar inscrição: $e');
    }
  }

  /// Listar inscrições de um campeonato
  static Future<List<ChampionshipRegistration>> getChampionshipRegistrations(
    String championshipId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_registrationsCollection)
          .where('championshipId', isEqualTo: championshipId)
          .orderBy('registeredAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => ChampionshipRegistration.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar inscrições: $e');
    }
  }

  /// Listar inscrições do usuário atual
  static Future<List<ChampionshipRegistration>> getUserRegistrations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final querySnapshot = await _firestore
          .collection(_registrationsCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('registeredAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChampionshipRegistration.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Fallback: buscar sem orderBy se o índice não estiver pronto
      if (e.toString().contains('index')) {
        print('Índice não encontrado, usando consulta alternativa...');
        try {
          final user = _auth.currentUser;
          if (user == null) throw Exception('Usuário não autenticado');

          final querySnapshot = await _firestore
              .collection(_registrationsCollection)
              .where('userId', isEqualTo: user.uid)
              .get();

          final registrations = querySnapshot.docs
              .map((doc) => ChampionshipRegistration.fromFirestore(doc))
              .toList();

          // Ordenar manualmente
          registrations.sort(
            (a, b) => b.registeredAt.compareTo(a.registeredAt),
          );
          return registrations;
        } catch (e2) {
          throw Exception('Erro ao listar suas inscrições: $e2');
        }
      }
      throw Exception('Erro ao listar suas inscrições: $e');
    }
  }

  /// Listar todas as inscrições do usuário (incluindo dados do campeonato)
  static Future<List<ChampionshipRegistration>> getUserAllRegistrations(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_registrationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('registeredAt', descending: true)
          .get();

      final registrations = <ChampionshipRegistration>[];

      for (final doc in querySnapshot.docs) {
        try {
          final registration = ChampionshipRegistration.fromFirestore(doc);

          // Buscar dados do campeonato
          final championship = await getChampionshipById(
            registration.championshipId,
          );
          if (championship != null) {
            // Adicionar dados do campeonato à inscrição
            final enrichedRegistration = registration.copyWith(
              championshipTitle: championship.title,
              championshipDescription: championship.description,
              championshipLocation: championship.location,
              championshipStatus: championship.status,
            );
            registrations.add(enrichedRegistration);
          }
        } catch (e) {
          print('Erro ao processar inscrição ${doc.id}: $e');
          continue;
        }
      }

      return registrations;
    } catch (e) {
      // Fallback: buscar sem orderBy se o índice não estiver pronto
      if (e.toString().contains('index')) {
        print('Índice não encontrado, usando consulta alternativa...');
        try {
          final querySnapshot = await _firestore
              .collection(_registrationsCollection)
              .where('userId', isEqualTo: userId)
              .get();

          final registrations = <ChampionshipRegistration>[];

          for (final doc in querySnapshot.docs) {
            try {
              final registration = ChampionshipRegistration.fromFirestore(doc);

              // Buscar dados do campeonato
              final championship = await getChampionshipById(
                registration.championshipId,
              );
              if (championship != null) {
                // Adicionar dados do campeonato à inscrição
                final enrichedRegistration = registration.copyWith(
                  championshipTitle: championship.title,
                  championshipDescription: championship.description,
                  championshipLocation: championship.location,
                  championshipStatus: championship.status,
                );
                registrations.add(enrichedRegistration);
              }
            } catch (e) {
              print('Erro ao processar inscrição ${doc.id}: $e');
              continue;
            }
          }

          // Ordenar manualmente
          registrations.sort(
            (a, b) => b.registeredAt.compareTo(a.registeredAt),
          );
          return registrations;
        } catch (e2) {
          throw Exception('Erro ao listar inscrições do usuário: $e2');
        }
      }
      throw Exception('Erro ao listar inscrições do usuário: $e');
    }
  }

  /// Listar inscrições do usuário para um campeonato específico
  static Future<List<ChampionshipRegistration>>
  getUserChampionshipRegistrations(String userId, String championshipId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_registrationsCollection)
          .where('userId', isEqualTo: userId)
          .where('championshipId', isEqualTo: championshipId)
          .get();

      return querySnapshot.docs
          .map((doc) => ChampionshipRegistration.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar inscrições do usuário: $e');
    }
  }

  /// Cancelar inscrição do usuário
  static Future<void> cancelUserRegistration(String registrationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se a inscrição existe e pertence ao usuário
      final registrationDoc = await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .get();

      if (!registrationDoc.exists) {
        throw Exception('Inscrição não encontrada');
      }

      final registration = ChampionshipRegistration.fromFirestore(
        registrationDoc,
      );
      if (registration.userId != user.uid) {
        throw Exception('Você não pode cancelar esta inscrição');
      }

      // Verificar se ainda é possível cancelar
      final championship = await getChampionshipById(
        registration.championshipId,
      );
      if (championship == null) {
        throw Exception('Campeonato não encontrado');
      }

      if (championship.status != ChampionshipStatus.registrationOpen) {
        throw Exception('Não é possível cancelar inscrição neste momento');
      }

      // Deletar inscrição
      await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao cancelar inscrição: $e');
    }
  }

  /// Confirmar inscrição (admin)
  static Future<void> confirmRegistration(String registrationId) async {
    try {
      await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .update({'isConfirmed': true});
    } catch (e) {
      throw Exception('Erro ao confirmar inscrição: $e');
    }
  }

  /// Marcar pagamento como realizado (admin)
  static Future<void> markAsPaid(String registrationId) async {
    try {
      await _firestore
          .collection(_registrationsCollection)
          .doc(registrationId)
          .update({'isPaid': true});
    } catch (e) {
      throw Exception('Erro ao marcar pagamento: $e');
    }
  }

  // ========== Estatísticas ==========

  /// Obter estatísticas de um campeonato
  static Future<Map<String, int>> getChampionshipStats(
    String championshipId,
  ) async {
    try {
      final registrations = await getChampionshipRegistrations(championshipId);

      int totalRegistrations = registrations.length;
      int teamRegistrations = registrations
          .where((r) => r.teamId != null)
          .length;
      int individualRegistrations = registrations
          .where((r) => r.teamId == null)
          .length;
      int confirmedRegistrations = registrations
          .where((r) => r.isConfirmed)
          .length;
      int paidRegistrations = registrations.where((r) => r.isPaid).length;

      return {
        'total': totalRegistrations,
        'teams': teamRegistrations,
        'individuals': individualRegistrations,
        'confirmed': confirmedRegistrations,
        'paid': paidRegistrations,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  /// Obter estatísticas gerais de campeonatos
  static Future<Map<String, int>> getGeneralStats() async {
    try {
      final championships = await getAllChampionships();

      int total = championships.length;
      int published = championships
          .where((c) => c.status == ChampionshipStatus.published)
          .length;
      int ongoing = championships
          .where((c) => c.status == ChampionshipStatus.ongoing)
          .length;
      int finished = championships
          .where((c) => c.status == ChampionshipStatus.finished)
          .length;

      return {
        'total': total,
        'published': published,
        'ongoing': ongoing,
        'finished': finished,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas gerais: $e');
    }
  }

  /// Busca todos os participantes de um campeonato (individuais e times)
  static Future<Map<String, dynamic>> getChampionshipParticipants(
    String championshipId,
  ) async {
    try {
      print('DEBUG: Buscando participantes do campeonato: $championshipId');

      // Buscar inscrições individuais
      final individualRegistrations = await FirebaseFirestore.instance
          .collection('championship_registrations')
          .where('championshipId', isEqualTo: championshipId)
          .where('registrationType', isEqualTo: 'individual')
          .get();

      // Buscar inscrições de times
      final teamRegistrations = await FirebaseFirestore.instance
          .collection('championship_registrations')
          .where('championshipId', isEqualTo: championshipId)
          .where('registrationType', isEqualTo: 'team')
          .get();

      print(
        'DEBUG: Inscrições individuais encontradas: ${individualRegistrations.docs.length}',
      );
      print(
        'DEBUG: Inscrições de times encontradas: ${teamRegistrations.docs.length}',
      );

      // Processar participantes individuais
      final individualParticipants = <Map<String, dynamic>>[];
      for (final doc in individualRegistrations.docs) {
        final data = doc.data();
        individualParticipants.add({
          'id': doc.id,
          'name': data['name'] ?? 'Nome não informado',
          'email': data['email'] ?? 'Email não informado',
          'phone': data['phone'] ?? 'Telefone não informado',
          'position': data['position'] ?? 'Posição não informada',
          'skillLevel': data['skillLevel'] ?? 'Nível não informado',
          'registeredAt': data['registeredAt']?.toDate(),
          'additionalInfo': data['additionalInfo'] ?? {},
        });
      }

      // Processar participantes de times
      final teamParticipants = <Map<String, dynamic>>[];
      for (final doc in teamRegistrations.docs) {
        final data = doc.data();
        final teamId = data['teamId'] as String?;

        if (teamId != null) {
          try {
            // Buscar dados do time
            final teamDoc = await FirebaseFirestore.instance
                .collection('teams')
                .doc(teamId)
                .get();
            if (teamDoc.exists) {
              final teamData = teamDoc.data() as Map<String, dynamic>;
              teamParticipants.add({
                'id': doc.id,
                'teamId': teamId,
                'teamName': teamData['name'] ?? 'Nome do time não informado',
                'captainName':
                    teamData['captainName'] ?? 'Capitão não informado',
                'captainEmail':
                    teamData['captainEmail'] ??
                    'Email do capitão não informado',
                'memberCount': teamData['members']?.length ?? 0,
                'registeredAt': data['registeredAt']?.toDate(),
                'additionalInfo': data['additionalInfo'] ?? {},
              });
            }
          } catch (e) {
            print('DEBUG: Erro ao buscar dados do time $teamId: $e');
            // Adicionar mesmo sem dados do time
            teamParticipants.add({
              'id': doc.id,
              'teamId': teamId,
              'teamName': 'Time (dados não disponíveis)',
              'captainName': 'Capitão não informado',
              'captainEmail': 'Email do capitão não informado',
              'memberCount': 0,
              'registeredAt': data['registeredAt']?.toDate(),
              'additionalInfo': data['additionalInfo'] ?? {},
            });
          }
        }
      }

      print(
        'DEBUG: Participantes individuais processados: ${individualParticipants.length}',
      );
      print(
        'DEBUG: Participantes de times processados: ${teamParticipants.length}',
      );

      return {
        'individualParticipants': individualParticipants,
        'teamParticipants': teamParticipants,
        'totalIndividual': individualParticipants.length,
        'totalTeams': teamParticipants.length,
        'totalParticipants':
            individualParticipants.length + teamParticipants.length,
      };
    } catch (e) {
      print('DEBUG: Erro ao buscar participantes: $e');
      throw Exception('Erro ao buscar participantes do campeonato: $e');
    }
  }
}
