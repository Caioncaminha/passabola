part of 'example.dart';

class UpdateMatchScoreVariablesBuilder {
  String matchId;
  int homeScore;
  int awayScore;

  final FirebaseDataConnect _dataConnect;
  UpdateMatchScoreVariablesBuilder(
    this._dataConnect, {
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
  });
  Deserializer<UpdateMatchScoreData> dataDeserializer = (dynamic json) =>
      UpdateMatchScoreData.fromJson(jsonDecode(json));
  Serializer<UpdateMatchScoreVariables> varsSerializer =
      (UpdateMatchScoreVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateMatchScoreData, UpdateMatchScoreVariables>>
  execute() {
    return ref().execute();
  }

  MutationRef<UpdateMatchScoreData, UpdateMatchScoreVariables> ref() {
    UpdateMatchScoreVariables vars = UpdateMatchScoreVariables(
      matchId: matchId,
      homeScore: homeScore,
      awayScore: awayScore,
    );
    return _dataConnect.mutation(
      "UpdateMatchScore",
      dataDeserializer,
      varsSerializer,
      vars,
    );
  }
}

class UpdateMatchScoreMatchUpdate {
  String id;
  UpdateMatchScoreMatchUpdate.fromJson(dynamic json)
    : id = json['id'] as String;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = id;
    return json;
  }

  UpdateMatchScoreMatchUpdate({required this.id});
}

class UpdateMatchScoreData {
  UpdateMatchScoreMatchUpdate? matchUpdate;
  UpdateMatchScoreData.fromJson(dynamic json)
    : matchUpdate = json['match_update'] == null
          ? null
          : UpdateMatchScoreMatchUpdate.fromJson(json['match_update']);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (matchUpdate != null) {
      json['match_update'] = matchUpdate!.toJson();
    }
    return json;
  }

  UpdateMatchScoreData({this.matchUpdate});
}

class UpdateMatchScoreVariables {
  String matchId;
  int homeScore;
  int awayScore;
  @Deprecated(
    'fromJson is deprecated for Variable classes as they are no longer required for deserialization.',
  )
  UpdateMatchScoreVariables.fromJson(Map<String, dynamic> json)
    : matchId = json['matchId'] as String,
      homeScore = json['homeScore'] as int,
      awayScore = json['awayScore'] as int;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['matchId'] = matchId;
    json['homeScore'] = homeScore;
    json['awayScore'] = awayScore;
    return json;
  }

  UpdateMatchScoreVariables({
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
  });
}
