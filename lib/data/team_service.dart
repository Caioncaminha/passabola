import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'team_model.dart';

class TeamService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'teams';
  static const String _invitesCollection = 'team_invites';

  /// Criar uma nova solicitação de time
  static Future<String> createTeamRequest({
    required String name,
    required String description,
    String? imageUrl,
    TeamLevel level = TeamLevel.beginner,
    int maxMembers = 11,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Verificar se o usuário já tem uma solicitação pendente
      final existingRequest = await _firestore
          .collection(_collection)
          .where('captainId', isEqualTo: user.uid)
          .where('status', isEqualTo: TeamStatus.pending.name)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('Você já possui uma solicitação de time pendente');
      }

      final now = DateTime.now();
      final team = Team(
        id: '', // Será definido pelo Firestore
        name: name,
        description: description,
        captainId: user.uid,
        captainName: user.displayName ?? 'Capitão',
        imageUrl: imageUrl,
        createdAt: now,
        updatedAt: now,
        status: TeamStatus.pending,
        level: level,
        maxMembers: maxMembers,
        members: [
          TeamMember(
            userId: user.uid,
            userName: user.displayName ?? 'Capitão',
            userEmail: user.email ?? '',
            role: 'captain',
            joinedAt: now,
          ),
        ],
      );

      final docRef = await _firestore
          .collection(_collection)
          .add(team.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar solicitação de time: $e');
    }
  }

  /// Obter todos os times ativos
  static Stream<List<Team>> getActiveTeams() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: TeamStatus.active.name)
        .snapshots()
        .map((snapshot) {
          final teams = snapshot.docs
              .map((doc) => Team.fromFirestore(doc))
              .toList();

          // Ordenar por data de criação (mais recente primeiro)
          teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return teams;
        });
  }

  /// Obter todos os times (incluindo pendentes) - apenas para admins
  static Stream<List<Team>> getAllTeams() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final teams = snapshot.docs
          .map((doc) => Team.fromFirestore(doc))
          .toList();

      // Ordenar por data de criação (mais recente primeiro)
      teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return teams;
    });
  }

  /// Obter times pendentes de aprovação
  static Stream<List<Team>> getPendingTeams() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: TeamStatus.pending.name)
        .snapshots()
        .map((snapshot) {
          final teams = snapshot.docs
              .map((doc) => Team.fromFirestore(doc))
              .toList();

          // Ordenar por data de criação (mais recente primeiro)
          teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return teams;
        });
  }

  /// Obter um time específico por ID
  static Future<Team?> getTeamById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Team.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar time: $e');
    }
  }

  /// Obter times de um usuário
  static Stream<List<Team>> getUserTeams(String userId) {
    return _firestore
        .collection(_collection)
        .where('members', arrayContains: {'userId': userId, 'isActive': true})
        .snapshots()
        .map((snapshot) {
          final teams = snapshot.docs
              .map((doc) => Team.fromFirestore(doc))
              .toList();

          // Ordenar por data de criação (mais recente primeiro)
          teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return teams;
        });
  }

  /// Aprovar um time
  static Future<void> approveTeam(String teamId) async {
    try {
      await _firestore.collection(_collection).doc(teamId).update({
        'status': TeamStatus.active.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao aprovar time: $e');
    }
  }

  /// Rejeitar um time
  static Future<void> rejectTeam(String teamId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(teamId).update({
        'status': TeamStatus.rejected.name,
        'rejectionReason': reason,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao rejeitar time: $e');
    }
  }

  /// Atualizar um time
  static Future<void> updateTeam({
    required String id,
    String? name,
    String? description,
    String? imageUrl,
    TeamLevel? level,
    int? maxMembers,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final team = await getTeamById(id);
      if (team == null) throw Exception('Time não encontrado');

      if (!team.isCaptain(user.uid)) {
        throw Exception('Apenas o capitão pode editar o time');
      }

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (level != null) updateData['level'] = level.name;
      if (maxMembers != null) updateData['maxMembers'] = maxMembers;

      await _firestore.collection(_collection).doc(id).update(updateData);
    } catch (e) {
      throw Exception('Erro ao atualizar time: $e');
    }
  }

  /// Excluir um time
  static Future<void> deleteTeam(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final team = await getTeamById(id);
      if (team == null) throw Exception('Time não encontrado');

      if (!team.isCaptain(user.uid)) {
        throw Exception('Apenas o capitão pode excluir o time');
      }

      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir time: $e');
    }
  }

  /// Convidar usuário para o time
  static Future<void> inviteUserToTeam({
    required String teamId,
    required String invitedUserEmail,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final team = await getTeamById(teamId);
      if (team == null) throw Exception('Time não encontrado');

      if (!team.isCaptain(user.uid)) {
        throw Exception('Apenas o capitão pode convidar usuários');
      }

      if (team.isFull) {
        throw Exception('Time está lotado');
      }

      // Verificar se já existe um convite pendente para este usuário
      final existingInvite = await _firestore
          .collection(_invitesCollection)
          .where('teamId', isEqualTo: teamId)
          .where('invitedUserEmail', isEqualTo: invitedUserEmail)
          .where('isAccepted', isEqualTo: false)
          .where('isRejected', isEqualTo: false)
          .get();

      if (existingInvite.docs.isNotEmpty) {
        throw Exception('Já existe um convite pendente para este usuário');
      }

      final invite = TeamInvite(
        id: '',
        teamId: teamId,
        invitedUserId: '', // Será preenchido quando o usuário aceitar
        invitedUserEmail: invitedUserEmail,
        invitedByUserId: user.uid,
        createdAt: DateTime.now(),
      );

      await _firestore.collection(_invitesCollection).add(invite.toFirestore());
    } catch (e) {
      throw Exception('Erro ao convidar usuário: $e');
    }
  }

  /// Obter convites pendentes de um usuário
  static Stream<List<TeamInvite>> getUserInvites(String userEmail) {
    try {
      print('TeamService - Getting invites for email: $userEmail');
      return _firestore.collection(_invitesCollection).snapshots().map((
        snapshot,
      ) {
        print('TeamService - Snapshot has ${snapshot.docs.length} docs');

        final invites = snapshot.docs
            .map((doc) {
              try {
                return TeamInvite.fromFirestore(doc);
              } catch (e) {
                print('TeamService - Error parsing invite ${doc.id}: $e');
                return null;
              }
            })
            .where((invite) => invite != null)
            .cast<TeamInvite>()
            .where(
              (invite) =>
                  invite.invitedUserEmail == userEmail &&
                  !invite.isAccepted &&
                  !invite.isRejected,
            )
            .toList();

        print('TeamService - Filtered invites: ${invites.length}');

        // Ordenar por data de criação (mais recente primeiro)
        invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return invites;
      });
    } catch (e) {
      print('TeamService - Error getting user invites: $e');
      // Retornar stream vazio em caso de erro
      return Stream.value(<TeamInvite>[]);
    }
  }

  /// Aceitar convite para time
  static Future<void> acceptTeamInvite(String inviteId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      print('TeamService - Accepting invite: $inviteId');
      print('TeamService - User email: ${user.email}');

      final inviteDoc = await _firestore
          .collection(_invitesCollection)
          .doc(inviteId)
          .get();

      if (!inviteDoc.exists) {
        throw Exception('Convite não encontrado');
      }

      final invite = TeamInvite.fromFirestore(inviteDoc);
      print('TeamService - Invite email: ${invite.invitedUserEmail}');

      if (invite.invitedUserEmail != user.email) {
        throw Exception('Este convite não é para você');
      }

      final team = await getTeamById(invite.teamId);
      if (team == null) throw Exception('Time não encontrado');

      if (team.isFull) {
        throw Exception('Time está lotado');
      }

      if (team.isMember(user.uid)) {
        throw Exception('Você já é membro deste time');
      }

      // Atualizar convite como aceito
      print('TeamService - Updating invite to accepted');
      print('TeamService - User UID: ${user.uid}');
      print('TeamService - User email: ${user.email}');

      try {
        await _firestore.collection(_invitesCollection).doc(inviteId).update({
          'isAccepted': true,
          'invitedUserId': user.uid,
        });
        print('TeamService - Invite updated successfully');
      } catch (e) {
        print('TeamService - Error updating invite: $e');
        throw Exception('Erro ao atualizar convite: $e');
      }

      // Adicionar usuário ao time
      final newMember = TeamMember(
        userId: user.uid,
        userName: user.displayName ?? 'Membro',
        userEmail: user.email ?? '',
        role: 'member',
        joinedAt: DateTime.now(),
      );

      print('TeamService - Adding member to team: ${invite.teamId}');
      print('TeamService - New member: ${newMember.toMap()}');

      try {
        await _firestore.collection(_collection).doc(invite.teamId).update({
          'members': FieldValue.arrayUnion([newMember.toMap()]),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
        print('TeamService - Member added to team successfully');
      } catch (e) {
        print('TeamService - Error adding member to team: $e');
        throw Exception('Erro ao adicionar membro ao time: $e');
      }
    } catch (e) {
      throw Exception('Erro ao aceitar convite: $e');
    }
  }

  /// Rejeitar convite para time
  static Future<void> rejectTeamInvite(String inviteId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      print('TeamService - Rejecting invite: $inviteId');
      print('TeamService - User email: ${user.email}');

      final inviteDoc = await _firestore
          .collection(_invitesCollection)
          .doc(inviteId)
          .get();

      if (!inviteDoc.exists) {
        throw Exception('Convite não encontrado');
      }

      final invite = TeamInvite.fromFirestore(inviteDoc);
      print('TeamService - Invite email: ${invite.invitedUserEmail}');

      if (invite.invitedUserEmail != user.email) {
        throw Exception('Este convite não é para você');
      }

      print('TeamService - Updating invite to rejected');
      await _firestore.collection(_invitesCollection).doc(inviteId).update({
        'isRejected': true,
      });
      print('TeamService - Invite rejected successfully');
    } catch (e) {
      throw Exception('Erro ao rejeitar convite: $e');
    }
  }

  /// Remover membro do time
  static Future<void> removeMemberFromTeam({
    required String teamId,
    required String memberId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final team = await getTeamById(teamId);
      if (team == null) throw Exception('Time não encontrado');

      if (!team.isCaptain(user.uid)) {
        throw Exception('Apenas o capitão pode remover membros');
      }

      if (team.captainId == memberId) {
        throw Exception('O capitão não pode ser removido do time');
      }

      final member = team.getMember(memberId);
      if (member == null) {
        throw Exception('Membro não encontrado no time');
      }

      // Marcar membro como inativo
      final updatedMembers = team.members.map((m) {
        if (m.userId == memberId) {
          return TeamMember(
            userId: m.userId,
            userName: m.userName,
            userEmail: m.userEmail,
            role: m.role,
            joinedAt: m.joinedAt,
            isActive: false,
          );
        }
        return m;
      }).toList();

      await _firestore.collection(_collection).doc(teamId).update({
        'members': updatedMembers.map((m) => m.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao remover membro: $e');
    }
  }

  /// Buscar times por nome
  static Stream<List<Team>> searchTeams(String query) {
    if (query.isEmpty) {
      return getActiveTeams();
    }

    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: TeamStatus.active.name)
        .snapshots()
        .map((snapshot) {
          final teams = snapshot.docs
              .map((doc) => Team.fromFirestore(doc))
              .toList();

          // Filtrar localmente por nome ou descrição
          final filteredTeams = teams.where((team) {
            final searchQuery = query.toLowerCase();
            return team.name.toLowerCase().contains(searchQuery) ||
                team.description.toLowerCase().contains(searchQuery);
          }).toList();

          // Ordenar por data de criação (mais recente primeiro)
          filteredTeams.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return filteredTeams;
        });
  }

  /// Obter estatísticas dos times
  static Future<Map<String, int>> getTeamStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final teams = snapshot.docs
          .map((doc) => Team.fromFirestore(doc))
          .toList();

      return {
        'total': teams.length,
        'active': teams.where((t) => t.status == TeamStatus.active).length,
        'pending': teams.where((t) => t.status == TeamStatus.pending).length,
        'rejected': teams.where((t) => t.status == TeamStatus.rejected).length,
        'totalMembers': teams.fold(
          0,
          (total, team) => total + team.currentMembersCount,
        ),
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}
