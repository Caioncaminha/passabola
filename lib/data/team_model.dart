import 'package:cloud_firestore/cloud_firestore.dart';

enum TeamStatus {
  pending, // Aguardando aprovação
  active, // Time ativo
  inactive, // Time inativo
  rejected, // Time rejeitado
}

enum TeamLevel {
  beginner, // Iniciante
  amateur, // Amador
  semiPro, // Semi-profissional
  professional, // Profissional
}

class TeamMember {
  final String userId;
  final String userName;
  final String userEmail;
  final String role; // 'captain', 'member'
  final DateTime joinedAt;
  final bool isActive;

  TeamMember({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.role,
    required this.joinedAt,
    this.isActive = true,
  });

  factory TeamMember.fromMap(Map<String, dynamic> data) {
    return TeamMember(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      role: data['role'] ?? 'member',
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isActive': isActive,
    };
  }
}

class TeamInvite {
  final String id;
  final String teamId;
  final String invitedUserId;
  final String invitedUserEmail;
  final String invitedByUserId;
  final DateTime createdAt;
  final bool isAccepted;
  final bool isRejected;

  TeamInvite({
    required this.id,
    required this.teamId,
    required this.invitedUserId,
    required this.invitedUserEmail,
    required this.invitedByUserId,
    required this.createdAt,
    this.isAccepted = false,
    this.isRejected = false,
  });

  factory TeamInvite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamInvite(
      id: doc.id,
      teamId: data['teamId'] ?? '',
      invitedUserId: data['invitedUserId'] ?? '',
      invitedUserEmail: data['invitedUserEmail'] ?? '',
      invitedByUserId: data['invitedByUserId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAccepted: data['isAccepted'] ?? false,
      isRejected: data['isRejected'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamId': teamId,
      'invitedUserId': invitedUserId.isEmpty ? '' : invitedUserId,
      'invitedUserEmail': invitedUserEmail,
      'invitedByUserId': invitedByUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAccepted': isAccepted,
      'isRejected': isRejected,
    };
  }
}

class Team {
  final String id;
  final String name;
  final String description;
  final String captainId;
  final String captainName;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TeamStatus status;
  final TeamLevel level;
  final List<TeamMember> members;
  final int maxMembers;
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final int gamesDrawn;
  final int totalGoals;
  final int totalGoalsConceded;
  final String? rejectionReason;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.captainId,
    required this.captainName,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.status = TeamStatus.pending,
    this.level = TeamLevel.beginner,
    this.members = const [],
    this.maxMembers = 11,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.gamesDrawn = 0,
    this.totalGoals = 0,
    this.totalGoalsConceded = 0,
    this.rejectionReason,
  });

  // Construtor para criar a partir de um DocumentSnapshot
  factory Team.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Team(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      captainId: data['captainId'] ?? '',
      captainName: data['captainName'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      status: TeamStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TeamStatus.pending,
      ),
      level: TeamLevel.values.firstWhere(
        (e) => e.name == data['level'],
        orElse: () => TeamLevel.beginner,
      ),
      members:
          (data['members'] as List<dynamic>?)
              ?.map(
                (member) => TeamMember.fromMap(member as Map<String, dynamic>),
              )
              .toList() ??
          [],
      maxMembers: data['maxMembers'] ?? 11,
      gamesPlayed: data['gamesPlayed'] ?? 0,
      gamesWon: data['gamesWon'] ?? 0,
      gamesLost: data['gamesLost'] ?? 0,
      gamesDrawn: data['gamesDrawn'] ?? 0,
      totalGoals: data['totalGoals'] ?? 0,
      totalGoalsConceded: data['totalGoalsConceded'] ?? 0,
      rejectionReason: data['rejectionReason'],
    );
  }

  // Método para converter para Map (para salvar no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'captainId': captainId,
      'captainName': captainName,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status.name,
      'level': level.name,
      'members': members.map((member) => member.toMap()).toList(),
      'maxMembers': maxMembers,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'gamesDrawn': gamesDrawn,
      'totalGoals': totalGoals,
      'totalGoalsConceded': totalGoalsConceded,
      'rejectionReason': rejectionReason,
    };
  }

  // Método para criar uma cópia com campos atualizados
  Team copyWith({
    String? id,
    String? name,
    String? description,
    String? captainId,
    String? captainName,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    TeamStatus? status,
    TeamLevel? level,
    List<TeamMember>? members,
    int? maxMembers,
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? gamesDrawn,
    int? totalGoals,
    int? totalGoalsConceded,
    String? rejectionReason,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      captainId: captainId ?? this.captainId,
      captainName: captainName ?? this.captainName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      level: level ?? this.level,
      members: members ?? this.members,
      maxMembers: maxMembers ?? this.maxMembers,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      gamesDrawn: gamesDrawn ?? this.gamesDrawn,
      totalGoals: totalGoals ?? this.totalGoals,
      totalGoalsConceded: totalGoalsConceded ?? this.totalGoalsConceded,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  // Getters úteis
  int get currentMembersCount => members.length;
  bool get isFull => currentMembersCount >= maxMembers;
  bool get hasSpace => currentMembersCount < maxMembers;

  double get winRate {
    if (gamesPlayed == 0) return 0.0;
    return gamesWon / gamesPlayed;
  }

  int get goalDifference => totalGoals - totalGoalsConceded;

  String get statusDisplayName {
    switch (status) {
      case TeamStatus.pending:
        return 'Aguardando Aprovação';
      case TeamStatus.active:
        return 'Ativo';
      case TeamStatus.inactive:
        return 'Inativo';
      case TeamStatus.rejected:
        return 'Rejeitado';
    }
  }

  String get levelDisplayName {
    switch (level) {
      case TeamLevel.beginner:
        return 'Iniciante';
      case TeamLevel.amateur:
        return 'Amador';
      case TeamLevel.semiPro:
        return 'Semi-profissional';
      case TeamLevel.professional:
        return 'Profissional';
    }
  }

  // Verificar se um usuário é membro do time
  bool isMember(String userId) {
    return members.any((member) => member.userId == userId && member.isActive);
  }

  // Verificar se um usuário é capitão
  bool isCaptain(String userId) {
    return captainId == userId;
  }

  // Obter membro por ID
  TeamMember? getMember(String userId) {
    try {
      return members.firstWhere((member) => member.userId == userId);
    } catch (e) {
      return null;
    }
  }
}
