part of 'example.dart';

class CreateTeamVariablesBuilder {
  String name;
  String leagueId;

  final FirebaseDataConnect _dataConnect;
  CreateTeamVariablesBuilder(
    this._dataConnect, {
    required this.name,
    required this.leagueId,
  });
  Deserializer<CreateTeamData> dataDeserializer = (dynamic json) =>
      CreateTeamData.fromJson(jsonDecode(json));

  Serializer<CreateTeamVariables> varsSerializer = (CreateTeamVariables vars) =>
      jsonEncode(vars.toJson());
  Future<OperationResult<CreateTeamData, CreateTeamVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateTeamData, CreateTeamVariables> ref() {
    CreateTeamVariables vars = CreateTeamVariables(
      name: name,
      leagueId: leagueId,
    );
    return _dataConnect.mutation(
      "CreateTeam",
      dataDeserializer,
      varsSerializer,
      vars,
    );
  }
}

class CreateTeamTeamInsert {
  String id;
  CreateTeamTeamInsert.fromJson(dynamic json) : id = json['id'] as String;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = id;
    return json;
  }

  CreateTeamTeamInsert({required this.id});
}

class CreateTeamData {
  CreateTeamTeamInsert teamInsert;
  CreateTeamData.fromJson(dynamic json)
    : teamInsert = CreateTeamTeamInsert.fromJson(json['team_insert']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['team_insert'] = teamInsert.toJson();
    return json;
  }

  CreateTeamData({required this.teamInsert});
}

class CreateTeamVariables {
  String name;
  String leagueId;
  @Deprecated(
    'fromJson is deprecated for Variable classes as they are no longer required for deserialization.',
  )
  CreateTeamVariables.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      leagueId = json['leagueId'] as String;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = name;
    json['leagueId'] = leagueId;
    return json;
  }

  CreateTeamVariables({required this.name, required this.leagueId});
}
