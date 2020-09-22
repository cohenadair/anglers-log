import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

class MockAppManager extends Mock implements AppManager {}
class MockDataManager extends Mock implements DataManager {}

class TestNamedEntityManager extends NamedEntityManager<Species> {
  TestNamedEntityManager(AppManager app) : super(app);

  @override
  Species entityFromBytes(List<int> bytes) => Species.fromBuffer(bytes);

  @override
  Id id(Species species) => species.id;

  @override
  String name(Species species) => species.name;

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
    when(_dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    _entityManager = TestNamedEntityManager(_appManager);
  });

  test("Entity named and name exists", () async {
    await _entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bass");
    await _entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bluegill");
    await _entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Catfish");

    expect(_entityManager.nameExists(null), false);
    expect(_entityManager.nameExists(""), false);
    expect(_entityManager.nameExists("bass"), true);
    expect(_entityManager.nameExists("  Catfish"), true);
    expect(_entityManager.nameExists("  catfish "), true);
    expect(_entityManager.nameExists("perch"), false);
  });
}