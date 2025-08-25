part of 'example.dart';

class UpdateMatchScoreVariablesBuilder {
  String matchId;
  int homeScore;
  int awayScore;

  final FirebaseDataConnect _dataConnect;
  UpdateMatchScoreVariablesBuilder(this._dataConnect, {required  this.matchId,required  this.homeScore,required  this.awayScore,});
  Deserializer<UpdateMatchScoreData> dataDeserializer = (dynamic json)  => UpdateMatchScoreData.fromJson(jsonDecode(json));
  Serializer<UpdateMatchScoreVariables> varsSerializer = (UpdateMatchScoreVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateMatchScoreData, UpdateMatchScoreVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateMatchScoreData, UpdateMatchScoreVariables> ref() {
    UpdateMatchScoreVariables vars= UpdateMatchScoreVariables(matchId: matchId,homeScore: homeScore,awayScore: awayScore,);
    return _dataConnect.mutation("UpdateMatchScore", dataDeserializer, varsSerializer, vars);
  }
}

class UpdateMatchScoreMatchUpdate {
  String id;
  UpdateMatchScoreMatchUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpdateMatchScoreMatchUpdate({
    required this.id,
  });
}

class UpdateMatchScoreData {
  UpdateMatchScoreMatchUpdate? match_update;
  UpdateMatchScoreData.fromJson(dynamic json):
  
  match_update = json['match_update'] == null ? null : UpdateMatchScoreMatchUpdate.fromJson(json['match_update']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (match_update != null) {
      json['match_update'] = match_update!.toJson();
    }
    return json;
  }

  UpdateMatchScoreData({
    this.match_update,
  });
}

class UpdateMatchScoreVariables {
  String matchId;
  int homeScore;
  int awayScore;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateMatchScoreVariables.fromJson(Map<String, dynamic> json):
  
  matchId = nativeFromJson<String>(json['matchId']),
  homeScore = nativeFromJson<int>(json['homeScore']),
  awayScore = nativeFromJson<int>(json['awayScore']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['matchId'] = nativeToJson<String>(matchId);
    json['homeScore'] = nativeToJson<int>(homeScore);
    json['awayScore'] = nativeToJson<int>(awayScore);
    return json;
  }

  UpdateMatchScoreVariables({
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
  });
}

