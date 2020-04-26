import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mockito/mockito.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDataManager extends Mock implements DataManager {}

class TestNamedEntityManager extends NamedEntityManager<Species> {
  TestNamedEntityManager(AppManager app) : super(app);

  @override
  Species entityFromMap(Map<String, dynamic> map) => Species.fromMap(map);

  @override
  String get tableName => "species";
}

void main() {
  MockAppManager _appManager;
  MockDataManager _dataManager;
  TestNamedEntityManager _entityManager;

  setUp(() async {
    _appManager = MockAppManager();
    _dataManager = MockDataManager();
    when(_appManager.dataManager).thenReturn(_dataManager);
    when(_dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    _entityManager = TestNamedEntityManager(_appManager);
  });

  test("Name exists", () async {
    await _entityManager.addOrUpdate(Species(name: "Bass"));
    await _entityManager.addOrUpdate(Species(name: "Bluegill"));
    await _entityManager.addOrUpdate(Species(name: "Catfish"));

    expect(_entityManager.nameExists("bass"), true);
    expect(_entityManager.nameExists("  Catfish"), true);
    expect(_entityManager.nameExists("  catfish "), true);
    expect(_entityManager.nameExists("perch"), false);
  });
}