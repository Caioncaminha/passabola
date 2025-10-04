import 'package:cloud_firestore/cloud_firestore.dart';

enum ChampionshipStatus {
  draft, // Rascunho
  published, // Publicado
  registrationOpen, // Inscrições abertas
  registrationClosed, // Inscrições fechadas
  ongoing, // Em andamento
  finished, // Finalizado
  cancelled, // Cancelado
}

enum ChampionshipType {
  knockout, // Eliminatória
  league, // Liga/Pontos corridos
  groups, // Grupos + eliminatória
  friendly, // Amistoso
}

enum RegistrationType {
  teamOnly, // Apenas times completos
  individualPairing, // Indivíduos para formar times
  mixed, // Ambos
}

class ChampionshipPrize {
  final String position; // '1º', '2º', '3º', etc.
  final String description;
  final double? monetaryValue;

  ChampionshipPrize({
    required this.position,
    required this.description,
    this.monetaryValue,
  });

  factory ChampionshipPrize.fromMap(Map<String, dynamic> data) {
    return ChampionshipPrize(
      position: data['position'] ?? '',
      description: data['description'] ?? '',
      monetaryValue: data['monetaryValue']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'position': position,
      'description': description,
      'monetaryValue': monetaryValue,
    };
  }
}

class ChampionshipRegistration {
  final String id;
  final String championshipId;
  final String userId;
  final String userEmail;
  final String userName;
  final String? teamId; // null se for individual
  final String? teamName;
  final DateTime registeredAt;
  final RegistrationType registrationType;
  final bool isConfirmed;
  final bool isPaid;
  final Map<String, dynamic>? additionalInfo;

  // Campos adicionais para exibição (não salvos no Firestore)
  final String? championshipTitle;
  final String? championshipDescription;
  final String? championshipLocation;
  final ChampionshipStatus? championshipStatus;

  ChampionshipRegistration({
    required this.id,
    required this.championshipId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    this.teamId,
    this.teamName,
    required this.registeredAt,
    this.registrationType = RegistrationType.teamOnly,
    this.isConfirmed = false,
    this.isPaid = false,
    this.additionalInfo,
    this.championshipTitle,
    this.championshipDescription,
    this.championshipLocation,
    this.championshipStatus,
  });

  factory ChampionshipRegistration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChampionshipRegistration(
      id: doc.id,
      championshipId: data['championshipId'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      teamId: data['teamId'],
      teamName: data['teamName'],
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      registrationType: RegistrationType.values.firstWhere(
        (e) => e.name == data['registrationType'],
        orElse: () => RegistrationType.teamOnly,
      ),
      isConfirmed: data['isConfirmed'] ?? false,
      isPaid: data['isPaid'] ?? false,
      additionalInfo: data['additionalInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'championshipId': championshipId,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'teamId': teamId,
      'teamName': teamName,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'registrationType': registrationType.name,
      'isConfirmed': isConfirmed,
      'isPaid': isPaid,
      'additionalInfo': additionalInfo,
    };
  }

  ChampionshipRegistration copyWith({
    String? id,
    String? championshipId,
    String? userId,
    String? userEmail,
    String? userName,
    String? teamId,
    String? teamName,
    DateTime? registeredAt,
    RegistrationType? registrationType,
    bool? isConfirmed,
    bool? isPaid,
    Map<String, dynamic>? additionalInfo,
    String? championshipTitle,
    String? championshipDescription,
    String? championshipLocation,
    ChampionshipStatus? championshipStatus,
  }) {
    return ChampionshipRegistration(
      id: id ?? this.id,
      championshipId: championshipId ?? this.championshipId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      registeredAt: registeredAt ?? this.registeredAt,
      registrationType: registrationType ?? this.registrationType,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      isPaid: isPaid ?? this.isPaid,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      championshipTitle: championshipTitle ?? this.championshipTitle,
      championshipDescription:
          championshipDescription ?? this.championshipDescription,
      championshipLocation: championshipLocation ?? this.championshipLocation,
      championshipStatus: championshipStatus ?? this.championshipStatus,
    );
  }
}

class Championship {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? registrationStartDate;
  final DateTime? registrationEndDate;
  final ChampionshipStatus status;
  final ChampionshipType type;
  final RegistrationType registrationType;
  final String location;
  final int maxTeams;
  final int minPlayersPerTeam;
  final int maxPlayersPerTeam;
  final double? registrationFee;
  final List<ChampionshipPrize> prizes;
  final List<String> rules;
  final String organizerId;
  final String organizerName;
  final Map<String, dynamic>? additionalInfo;

  Championship({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.endDate,
    this.registrationStartDate,
    this.registrationEndDate,
    this.status = ChampionshipStatus.draft,
    this.type = ChampionshipType.knockout,
    this.registrationType = RegistrationType.teamOnly,
    required this.location,
    this.maxTeams = 16,
    this.minPlayersPerTeam = 7,
    this.maxPlayersPerTeam = 11,
    this.registrationFee,
    this.prizes = const [],
    this.rules = const [],
    required this.organizerId,
    required this.organizerName,
    this.additionalInfo,
  });

  factory Championship.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Championship(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      registrationStartDate: data['registrationStartDate'] != null
          ? (data['registrationStartDate'] as Timestamp).toDate()
          : null,
      registrationEndDate: data['registrationEndDate'] != null
          ? (data['registrationEndDate'] as Timestamp).toDate()
          : null,
      status: ChampionshipStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ChampionshipStatus.draft,
      ),
      type: ChampionshipType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ChampionshipType.knockout,
      ),
      registrationType: RegistrationType.values.firstWhere(
        (e) => e.name == data['registrationType'],
        orElse: () => RegistrationType.teamOnly,
      ),
      location: data['location'] ?? '',
      maxTeams: data['maxTeams'] ?? 16,
      minPlayersPerTeam: data['minPlayersPerTeam'] ?? 7,
      maxPlayersPerTeam: data['maxPlayersPerTeam'] ?? 11,
      registrationFee: data['registrationFee']?.toDouble(),
      prizes:
          (data['prizes'] as List<dynamic>?)
              ?.map(
                (prize) =>
                    ChampionshipPrize.fromMap(prize as Map<String, dynamic>),
              )
              .toList() ??
          [],
      rules: List<String>.from(data['rules'] ?? []),
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      additionalInfo: data['additionalInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'registrationStartDate': registrationStartDate != null
          ? Timestamp.fromDate(registrationStartDate!)
          : null,
      'registrationEndDate': registrationEndDate != null
          ? Timestamp.fromDate(registrationEndDate!)
          : null,
      'status': status.name,
      'type': type.name,
      'registrationType': registrationType.name,
      'location': location,
      'maxTeams': maxTeams,
      'minPlayersPerTeam': minPlayersPerTeam,
      'maxPlayersPerTeam': maxPlayersPerTeam,
      'registrationFee': registrationFee,
      'prizes': prizes.map((prize) => prize.toMap()).toList(),
      'rules': rules,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'additionalInfo': additionalInfo,
    };
  }

  Championship copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationStartDate,
    DateTime? registrationEndDate,
    ChampionshipStatus? status,
    ChampionshipType? type,
    RegistrationType? registrationType,
    String? location,
    int? maxTeams,
    int? minPlayersPerTeam,
    int? maxPlayersPerTeam,
    double? registrationFee,
    List<ChampionshipPrize>? prizes,
    List<String>? rules,
    String? organizerId,
    String? organizerName,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Championship(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationStartDate:
          registrationStartDate ?? this.registrationStartDate,
      registrationEndDate: registrationEndDate ?? this.registrationEndDate,
      status: status ?? this.status,
      type: type ?? this.type,
      registrationType: registrationType ?? this.registrationType,
      location: location ?? this.location,
      maxTeams: maxTeams ?? this.maxTeams,
      minPlayersPerTeam: minPlayersPerTeam ?? this.minPlayersPerTeam,
      maxPlayersPerTeam: maxPlayersPerTeam ?? this.maxPlayersPerTeam,
      registrationFee: registrationFee ?? this.registrationFee,
      prizes: prizes ?? this.prizes,
      rules: rules ?? this.rules,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Getters úteis
  String get statusDisplayName {
    switch (status) {
      case ChampionshipStatus.draft:
        return 'Rascunho';
      case ChampionshipStatus.published:
        return 'Publicado';
      case ChampionshipStatus.registrationOpen:
        return 'Inscrições Abertas';
      case ChampionshipStatus.registrationClosed:
        return 'Inscrições Fechadas';
      case ChampionshipStatus.ongoing:
        return 'Em Andamento';
      case ChampionshipStatus.finished:
        return 'Finalizado';
      case ChampionshipStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case ChampionshipType.knockout:
        return 'Eliminatória';
      case ChampionshipType.league:
        return 'Liga';
      case ChampionshipType.groups:
        return 'Grupos + Eliminatória';
      case ChampionshipType.friendly:
        return 'Amistoso';
    }
  }

  String get registrationTypeDisplayName {
    switch (registrationType) {
      case RegistrationType.teamOnly:
        return 'Apenas Times';
      case RegistrationType.individualPairing:
        return 'Formação de Times';
      case RegistrationType.mixed:
        return 'Times + Indivíduos';
    }
  }

  bool get isRegistrationOpen {
    final now = DateTime.now();
    return status == ChampionshipStatus.registrationOpen &&
        (registrationStartDate == null ||
            now.isAfter(registrationStartDate!)) &&
        (registrationEndDate == null || now.isBefore(registrationEndDate!));
  }

  bool get canRegisterTeams {
    return registrationType == RegistrationType.teamOnly ||
        registrationType == RegistrationType.mixed;
  }

  bool get canRegisterIndividuals {
    return registrationType == RegistrationType.individualPairing ||
        registrationType == RegistrationType.mixed;
  }

  // Verifica se o check-in está permitido
  bool get canCheckIn {
    return status == ChampionshipStatus.registrationOpen ||
        status == ChampionshipStatus.registrationClosed ||
        status == ChampionshipStatus.ongoing ||
        status ==
            ChampionshipStatus.published; // Published também permite check-in
  }
}
