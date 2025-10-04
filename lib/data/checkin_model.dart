import 'package:cloud_firestore/cloud_firestore.dart';

enum CheckInType {
  team, // Check-in de time completo
  individual, // Check-in individual para team pairing
}

enum CheckInStatus {
  pending, // Aguardando confirmação
  confirmed, // Confirmado
  cancelled, // Cancelado
  noShow, // Não compareceu
}

class TeamCheckIn {
  final String id;
  final String championshipId;
  final String teamId;
  final String teamName;
  final String captainId;
  final String captainName;
  final List<PlayerCheckIn> players;
  final DateTime checkInTime;
  final CheckInStatus status;
  final String? notes;
  final Map<String, dynamic>? additionalInfo;

  TeamCheckIn({
    required this.id,
    required this.championshipId,
    required this.teamId,
    required this.teamName,
    required this.captainId,
    required this.captainName,
    required this.players,
    required this.checkInTime,
    this.status = CheckInStatus.pending,
    this.notes,
    this.additionalInfo,
  });

  factory TeamCheckIn.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamCheckIn(
      id: doc.id,
      championshipId: data['championshipId'] ?? '',
      teamId: data['teamId'] ?? '',
      teamName: data['teamName'] ?? '',
      captainId: data['captainId'] ?? '',
      captainName: data['captainName'] ?? '',
      players:
          (data['players'] as List<dynamic>?)
              ?.map(
                (player) =>
                    PlayerCheckIn.fromMap(player as Map<String, dynamic>),
              )
              .toList() ??
          [],
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
      status: CheckInStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CheckInStatus.pending,
      ),
      notes: data['notes'],
      additionalInfo: data['additionalInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'championshipId': championshipId,
      'teamId': teamId,
      'teamName': teamName,
      'captainId': captainId,
      'captainName': captainName,
      'players': players.map((player) => player.toMap()).toList(),
      'checkInTime': Timestamp.fromDate(checkInTime),
      'status': status.name,
      'notes': notes,
      'additionalInfo': additionalInfo,
    };
  }

  TeamCheckIn copyWith({
    String? id,
    String? championshipId,
    String? teamId,
    String? teamName,
    String? captainId,
    String? captainName,
    List<PlayerCheckIn>? players,
    DateTime? checkInTime,
    CheckInStatus? status,
    String? notes,
    Map<String, dynamic>? additionalInfo,
  }) {
    return TeamCheckIn(
      id: id ?? this.id,
      championshipId: championshipId ?? this.championshipId,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      captainId: captainId ?? this.captainId,
      captainName: captainName ?? this.captainName,
      players: players ?? this.players,
      checkInTime: checkInTime ?? this.checkInTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Getters úteis
  int get totalPlayers => players.length;
  int get confirmedPlayers => players.where((p) => p.isPresent).length;
  bool get isComplete => confirmedPlayers >= 7; // Mínimo para jogar

  String get statusDisplayName {
    switch (status) {
      case CheckInStatus.pending:
        return 'Aguardando';
      case CheckInStatus.confirmed:
        return 'Confirmado';
      case CheckInStatus.cancelled:
        return 'Cancelado';
      case CheckInStatus.noShow:
        return 'Não Compareceu';
    }
  }
}

class PlayerCheckIn {
  final String userId;
  final String userName;
  final String userEmail;
  final String position; // Posição do jogador
  final bool isPresent;
  final DateTime? checkInTime;
  final String? notes;

  PlayerCheckIn({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.position,
    this.isPresent = false,
    this.checkInTime,
    this.notes,
  });

  factory PlayerCheckIn.fromMap(Map<String, dynamic> data) {
    return PlayerCheckIn(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      position: data['position'] ?? '',
      isPresent: data['isPresent'] ?? false,
      checkInTime: data['checkInTime'] != null
          ? (data['checkInTime'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'position': position,
      'isPresent': isPresent,
      'checkInTime': checkInTime != null
          ? Timestamp.fromDate(checkInTime!)
          : null,
      'notes': notes,
    };
  }

  PlayerCheckIn copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    String? position,
    bool? isPresent,
    DateTime? checkInTime,
    String? notes,
  }) {
    return PlayerCheckIn(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      position: position ?? this.position,
      isPresent: isPresent ?? this.isPresent,
      checkInTime: checkInTime ?? this.checkInTime,
      notes: notes ?? this.notes,
    );
  }
}

class IndividualCheckIn {
  final String id;
  final String championshipId;
  final String userId;
  final String userName;
  final String userEmail;
  final String preferredPosition;
  final String skillLevel; // 'beginner', 'intermediate', 'advanced'
  final DateTime checkInTime;
  final CheckInStatus status;
  final String? assignedTeamId;
  final String? assignedTeamName;
  final String? notes;
  final Map<String, dynamic>? additionalInfo;

  IndividualCheckIn({
    required this.id,
    required this.championshipId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.preferredPosition,
    required this.skillLevel,
    required this.checkInTime,
    this.status = CheckInStatus.pending,
    this.assignedTeamId,
    this.assignedTeamName,
    this.notes,
    this.additionalInfo,
  });

  factory IndividualCheckIn.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IndividualCheckIn(
      id: doc.id,
      championshipId: data['championshipId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      preferredPosition: data['preferredPosition'] ?? '',
      skillLevel: data['skillLevel'] ?? 'beginner',
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
      status: CheckInStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => CheckInStatus.pending,
      ),
      assignedTeamId: data['assignedTeamId'],
      assignedTeamName: data['assignedTeamName'],
      notes: data['notes'],
      additionalInfo: data['additionalInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'championshipId': championshipId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'preferredPosition': preferredPosition,
      'skillLevel': skillLevel,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'status': status.name,
      'assignedTeamId': assignedTeamId,
      'assignedTeamName': assignedTeamName,
      'notes': notes,
      'additionalInfo': additionalInfo,
    };
  }

  IndividualCheckIn copyWith({
    String? id,
    String? championshipId,
    String? userId,
    String? userName,
    String? userEmail,
    String? preferredPosition,
    String? skillLevel,
    DateTime? checkInTime,
    CheckInStatus? status,
    String? assignedTeamId,
    String? assignedTeamName,
    String? notes,
    Map<String, dynamic>? additionalInfo,
  }) {
    return IndividualCheckIn(
      id: id ?? this.id,
      championshipId: championshipId ?? this.championshipId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      preferredPosition: preferredPosition ?? this.preferredPosition,
      skillLevel: skillLevel ?? this.skillLevel,
      checkInTime: checkInTime ?? this.checkInTime,
      status: status ?? this.status,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      assignedTeamName: assignedTeamName ?? this.assignedTeamName,
      notes: notes ?? this.notes,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Getters úteis
  bool get isAssigned => assignedTeamId != null;

  String get statusDisplayName {
    switch (status) {
      case CheckInStatus.pending:
        return 'Aguardando';
      case CheckInStatus.confirmed:
        return 'Confirmado';
      case CheckInStatus.cancelled:
        return 'Cancelado';
      case CheckInStatus.noShow:
        return 'Não Compareceu';
    }
  }

  String get skillLevelDisplayName {
    switch (skillLevel) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return 'Não informado';
    }
  }
}

// Classe para representar um time formado automaticamente
class GeneratedTeam {
  final String id;
  final String championshipId;
  final String name;
  final List<IndividualCheckIn> players;
  final DateTime createdAt;
  final bool isBalanced;
  final Map<String, int> positionCount;

  GeneratedTeam({
    required this.id,
    required this.championshipId,
    required this.name,
    required this.players,
    required this.createdAt,
    this.isBalanced = false,
    this.positionCount = const {},
  });

  factory GeneratedTeam.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GeneratedTeam(
      id: doc.id,
      championshipId: data['championshipId'] ?? '',
      name: data['name'] ?? '',
      players:
          (data['players'] as List<dynamic>?)
              ?.map(
                (player) => IndividualCheckIn.fromFirestore(
                  // Simulando um DocumentSnapshot para o IndividualCheckIn
                  // Em uma implementação real, você precisaria ajustar isso
                  player as DocumentSnapshot,
                ),
              )
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isBalanced: data['isBalanced'] ?? false,
      positionCount: Map<String, int>.from(data['positionCount'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'championshipId': championshipId,
      'name': name,
      'players': players.map((player) => player.toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isBalanced': isBalanced,
      'positionCount': positionCount,
    };
  }

  GeneratedTeam copyWith({
    String? id,
    String? championshipId,
    String? name,
    List<IndividualCheckIn>? players,
    DateTime? createdAt,
    bool? isBalanced,
    Map<String, int>? positionCount,
  }) {
    return GeneratedTeam(
      id: id ?? this.id,
      championshipId: championshipId ?? this.championshipId,
      name: name ?? this.name,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
      isBalanced: isBalanced ?? this.isBalanced,
      positionCount: positionCount ?? this.positionCount,
    );
  }

  // Getters úteis
  int get totalPlayers => players.length;
  bool get isComplete => totalPlayers >= 7;
  bool get isFull => totalPlayers >= 11;
}
