part of 'example.dart';

class ListPlayersByTeamVariablesBuilder {
  String teamId;

  final FirebaseDataConnect _dataConnect;
  ListPlayersByTeamVariablesBuilder(this._dataConnect, {required this.teamId});
  Deserializer<ListPlayersByTeamData> dataDeserializer = (dynamic json) =>
      ListPlayersByTeamData.fromJson(jsonDecode(json));
  Serializer<ListPlayersByTeamVariables> varsSerializer =
      (ListPlayersByTeamVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListPlayersByTeamData, ListPlayersByTeamVariables>>
  execute() {
    return ref().execute();
  }

  QueryRef<ListPlayersByTeamData, ListPlayersByTeamVariables> ref() {
    ListPlayersByTeamVariables vars = ListPlayersByTeamVariables(
      teamId: teamId,
    );
    return _dataConnect.query(
      "ListPlayersByTeam",
      dataDeserializer,
      varsSerializer,
      vars,
    );
  }
}

class ListPlayersByTeamPlayers {
  String id;
  String displayName;
  String position;
  ListPlayersByTeamPlayers.fromJson(dynamic json)
    : id = json['id'] as String,
      displayName = json['displayName'] as String,
      position = json['position'] as String;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = id;
    json['displayName'] = displayName;
    json['position'] = position;
    return json;
  }

  ListPlayersByTeamPlayers({
    required this.id,
    required this.displayName,
    required this.position,
  });
}

class ListPlayersByTeamData {
  List<ListPlayersByTeamPlayers> players;
  ListPlayersByTeamData.fromJson(dynamic json)
    : players = (json['players'] as List<dynamic>)
          .map((e) => ListPlayersByTeamPlayers.fromJson(e))
          .toList();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['players'] = players.map((e) => e.toJson()).toList();
    return json;
  }

  ListPlayersByTeamData({required this.players});
}

class ListPlayersByTeamVariables {
  String teamId;
  @Deprecated(
    'fromJson is deprecated for Variable classes as they are no longer required for deserialization.',
  )
  ListPlayersByTeamVariables.fromJson(Map<String, dynamic> json)
    : teamId = json['teamId'] as String;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['teamId'] = teamId;
    return json;
  }

  ListPlayersByTeamVariables({required this.teamId});
}
