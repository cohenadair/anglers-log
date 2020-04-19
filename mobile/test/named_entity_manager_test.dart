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
  MockAppManager appManager;
  MockDataManager dataManager;
  TestNamedEntityManager entityManager;

  setUp(() async {
    appManager = MockAppManager();
    dataManager = MockDataManager();
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    entityManager = TestNamedEntityManager(appManager);
  });

  test("Name exists", () async {
    await entityManager.addOrUpdate(Species(name: "Bass"));
    await entityManager.addOrUpdate(Species(name: "Bluegill"));
    await entityManager.addOrUpdate(Species(name: "Catfish"));

    expect(entityManager.nameExists("bass"), true);
    expect(entityManager.nameExists("  Catfish"), true);
    expect(entityManager.nameExists("  catfish "), true);
    expect(entityManager.nameExists("perch"), false);
  });
}