import 'dart:async';

import 'package:mobile/data_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test/test.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  MockDatabase database;
  DataManager dataManager;

  setUp(() async {
    database = MockDatabase();
    dataManager = DataManager();
    await dataManager.initialize(
      database: database,
      openDatabase: () => Future.value(database),
      resetDatabase: () => Future.value(database),
    );
  });

  test("Listeners are notified when database is reset", () async {
    when(database.close()).thenAnswer((_) => Future.value());

    dataManager.stream
        .listen(expectAsync1((event) => expect(event, DataManagerEvent.reset)));
    await dataManager.reset();
  });
}
