part of 'example.dart';

class ListMatchesByDateVariablesBuilder {
  DateTime matchDate;

  final FirebaseDataConnect _dataConnect;
  ListMatchesByDateVariablesBuilder(
    this._dataConnect, {
    required this.matchDate,
  });

  // Função para desserializar os dados recebidos do backend
  ListMatchesByDateData Function(dynamic) dataDeserializer = (dynamic json) =>
      ListMatchesByDateData.fromJson(jsonDecode(json));

  // Função para serializar as variáveis antes de enviar para o backend
  String Function(ListMatchesByDateVariables) varsSerializer =
      (ListMatchesByDateVariables vars) => jsonEncode(vars.toJson());

  Future<QueryResult<ListMatchesByDateData, ListMatchesByDateVariables>>
  execute() {
    return ref().execute();
  }

  QueryRef<ListMatchesByDateData, ListMatchesByDateVariables> ref() {
    ListMatchesByDateVariables vars = ListMatchesByDateVariables(
      matchDate: matchDate,
    );
    return _dataConnect.query(
      "ListMatchesByDate",
      dataDeserializer,
      varsSerializer,
      vars,
    );
  }
}

class ListMatchesByDateMatches {
  String id;
  ListMatchesByDateMatchesHomeTeam homeTeam;
  ListMatchesByDateMatchesAwayTeam awayTeam;
  int homeScore;
  int awayScore;
  ListMatchesByDateMatches.fromJson(dynamic json)
    : id = json['id'] as String,
      homeTeam = ListMatchesByDateMatchesHomeTeam.fromJson(json['homeTeam']),
      awayTeam = ListMatchesByDateMatchesAwayTeam.fromJson(json['awayTeam']),
      homeScore = json['homeScore'] as int,
      awayScore = json['awayScore'] as int;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = id;
    json['homeTeam'] = homeTeam.toJson();
    json['awayTeam'] = awayTeam.toJson();
    json['homeScore'] = homeScore;
    json['awayScore'] = awayScore;
    return json;
  }

  ListMatchesByDateMatches({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
  });
}

class ListMatchesByDateMatchesHomeTeam {
  String name;
  ListMatchesByDateMatchesHomeTeam.fromJson(dynamic json)
    : name = json['name'] as String;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = name;
    return json;
  }

  ListMatchesByDateMatchesHomeTeam({required this.name});
}

class ListMatchesByDateMatchesAwayTeam {
  String name;
  ListMatchesByDateMatchesAwayTeam.fromJson(dynamic json)
    : name = json['name'] as String;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = name;
    return json;
  }

  ListMatchesByDateMatchesAwayTeam({required this.name});
}

class ListMatchesByDateData {
  List<ListMatchesByDateMatches> matches;
  ListMatchesByDateData.fromJson(dynamic json)
    : matches = (json['matches'] as List<dynamic>)
          .map((e) => ListMatchesByDateMatches.fromJson(e))
          .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['matches'] = matches.map((e) => e.toJson()).toList();
    return json;
  }

  ListMatchesByDateData({required this.matches});
}

class ListMatchesByDateVariables {
  DateTime matchDate;
  @Deprecated(
    'fromJson is deprecated for Variable classes as they are no longer required for deserialization.',
  )
  ListMatchesByDateVariables.fromJson(Map<String, dynamic> json)
    : matchDate = DateTime.parse(json['matchDate'] as String);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['matchDate'] = matchDate.toIso8601String();
    return json;
  }

  ListMatchesByDateVariables({required this.matchDate});
}
