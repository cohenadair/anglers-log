import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

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
  MockAppManager appManager;
  MockDataManager dataManager;
  TestNamedEntityManager entityManager;

  setUp(() async {
    appManager = MockAppManager(
        mockAuthManager: true,
        mockDataManager: true,
        mockSubscriptionManager: true);

    var authStream = MockStream<void>();
    when(authStream.listen(any)).thenReturn(null);
    when(appManager.mockAuthManager.stream).thenAnswer((_) => authStream);

    dataManager = appManager.mockDataManager;
    when(appManager.dataManager).thenReturn(dataManager);
    when(dataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    var dataStream = MockStream<DataManagerEvent>();
    when(dataStream.listen(any)).thenReturn(null);
    when(dataManager.stream).thenAnswer((_) => dataStream);

    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    entityManager = TestNamedEntityManager(appManager);
  });

  test("Entity named and name exists", () async {
    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bass");
    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bluegill");
    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Catfish");

    expect(entityManager.nameExists(null), false);
    expect(entityManager.nameExists(""), false);
    expect(entityManager.nameExists("bass"), true);
    expect(entityManager.nameExists("  Catfish"), true);
    expect(entityManager.nameExists("  catfish "), true);
    expect(entityManager.nameExists("perch"), false);
  });
}
