import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test/test.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDatabase extends Mock implements Database {}

void main() {
  MockAppManager appManager;
  MockDatabase database;
  DataManager dataManager;

  setUp(() async {
    appManager = MockAppManager();
    database = MockDatabase();
    dataManager = DataManager.get();
    await dataManager.initialize(appManager, database);
  });

  test("Search", () {
    String searchText = "Some random text that does nothing";
    String tableName = "test_table_name";
    String column = "test_column";

    dataManager.search(tableName, column, searchText);
    List args = verify(database.rawQuery(captureAny, captureAny)).captured;

    expect(args[0], "SELECT * FROM $tableName WHERE $column LIKE "
        "'%Some random text that does nothing%' OR $column LIKE '%Some%' OR"
        " $column LIKE '%random%' OR $column LIKE '%text%' OR $column LIKE "
        "'%that%' OR $column LIKE '%does%' OR $column LIKE '%nothing%'"
        " ORDER BY $column");
    expect(args[1], ["Some random text that does nothing", "Some", "random",
        "text", "that", "does", "nothing"]);
  });
}