# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### ListPlayersByTeam
#### Required Arguments
```dart
String teamId = ...;
ExampleConnector.instance.listPlayersByTeam(
  teamId: teamId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListPlayersByTeamData, ListPlayersByTeamVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listPlayersByTeam(
  teamId: teamId,
);
ListPlayersByTeamData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String teamId = ...;

final ref = ExampleConnector.instance.listPlayersByTeam(
  teamId: teamId,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListMatchesByDate
#### Required Arguments
```dart
DateTime matchDate = ...;
ExampleConnector.instance.listMatchesByDate(
  matchDate: matchDate,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListMatchesByDateData, ListMatchesByDateVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listMatchesByDate(
  matchDate: matchDate,
);
ListMatchesByDateData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
DateTime matchDate = ...;

final ref = ExampleConnector.instance.listMatchesByDate(
  matchDate: matchDate,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### CreateTeam
#### Required Arguments
```dart
String name = ...;
String leagueId = ...;
ExampleConnector.instance.createTeam(
  name: name,
  leagueId: leagueId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateTeamData, CreateTeamVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createTeam(
  name: name,
  leagueId: leagueId,
);
CreateTeamData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String name = ...;
String leagueId = ...;

final ref = ExampleConnector.instance.createTeam(
  name: name,
  leagueId: leagueId,
).ref();
ref.execute();
```


### UpdateMatchScore
#### Required Arguments
```dart
String matchId = ...;
int homeScore = ...;
int awayScore = ...;
ExampleConnector.instance.updateMatchScore(
  matchId: matchId,
  homeScore: homeScore,
  awayScore: awayScore,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateMatchScoreData, UpdateMatchScoreVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateMatchScore(
  matchId: matchId,
  homeScore: homeScore,
  awayScore: awayScore,
);
UpdateMatchScoreData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String matchId = ...;
int homeScore = ...;
int awayScore = ...;

final ref = ExampleConnector.instance.updateMatchScore(
  matchId: matchId,
  homeScore: homeScore,
  awayScore: awayScore,
).ref();
ref.execute();
```

