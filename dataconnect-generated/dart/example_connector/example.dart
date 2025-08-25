library;

import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'dart:convert';

part 'create_team.dart';

part 'list_players_by_team.dart';

part 'update_match_score.dart';

part 'list_matches_by_date.dart';

class ExampleConnector {
  CreateTeamVariablesBuilder createTeam({
    required String name,
    required String leagueId,
  }) {
    return CreateTeamVariablesBuilder(
      dataConnect,
      name: name,
      leagueId: leagueId,
    );
  }

  ListPlayersByTeamVariablesBuilder listPlayersByTeam({
    required String teamId,
  }) {
    return ListPlayersByTeamVariablesBuilder(dataConnect, teamId: teamId);
  }

  UpdateMatchScoreVariablesBuilder updateMatchScore({
    required String matchId,
    required int homeScore,
    required int awayScore,
  }) {
    return UpdateMatchScoreVariablesBuilder(
      dataConnect,
      matchId: matchId,
      homeScore: homeScore,
      awayScore: awayScore,
    );
  }

  ListMatchesByDateVariablesBuilder listMatchesByDate({
    required DateTime matchDate,
  }) {
    return ListMatchesByDateVariablesBuilder(dataConnect, matchDate: matchDate);
  }

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-central1',
    'example',
    'passabola',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
      dataConnect: FirebaseDataConnect.instanceFor(
        connectorConfig: connectorConfig,
        sdkType: CallerSDKType.generated,
      ),
    );
  }

  FirebaseDataConnect dataConnect;
}
