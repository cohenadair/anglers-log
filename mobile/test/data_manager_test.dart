import 'package:mobile/data_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test/test.dart';

class MockDatabase extends Mock implements Database {}
class MockDataListener extends Mock implements DataListener {}

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
    var listener = MockDataListener();
    when(listener.onReset).thenReturn(() {});
    dataManager.addListener(listener);
    await dataManager.reset();
    verify(listener.onReset).called(1);
  });
}