part of 'example.dart';

class CreateTeamVariablesBuilder {
  String name;
  String leagueId;

  final FirebaseDataConnect _dataConnect;
  CreateTeamVariablesBuilder(this._dataConnect, {required  this.name,required  this.leagueId,});
  Deserializer<CreateTeamData> dataDeserializer = (dynamic json)  => CreateTeamData.fromJson(jsonDecode(json));
  Serializer<CreateTeamVariables> varsSerializer = (CreateTeamVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateTeamData, CreateTeamVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateTeamData, CreateTeamVariables> ref() {
    CreateTeamVariables vars= CreateTeamVariables(name: name,leagueId: leagueId,);
    return _dataConnect.mutation("CreateTeam", dataDeserializer, varsSerializer, vars);
  }
}

class CreateTeamTeamInsert {
  String id;
  CreateTeamTeamInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateTeamTeamInsert({
    required this.id,
  });
}

class CreateTeamData {
  CreateTeamTeamInsert team_insert;
  CreateTeamData.fromJson(dynamic json):
  
  team_insert = CreateTeamTeamInsert.fromJson(json['team_insert']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['team_insert'] = team_insert.toJson();
    return json;
  }

  CreateTeamData({
    required this.team_insert,
  });
}

class CreateTeamVariables {
  String name;
  String leagueId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateTeamVariables.fromJson(Map<String, dynamic> json):
  
  name = nativeFromJson<String>(json['name']),
  leagueId = nativeFromJson<String>(json['leagueId']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['leagueId'] = nativeToJson<String>(leagueId);
    return json;
  }

  CreateTeamVariables({
    required this.name,
    required this.leagueId,
  });
}

