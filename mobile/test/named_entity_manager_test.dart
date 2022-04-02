import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
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
  late StubbedAppManager appManager;
  late MockLocalDatabaseManager dataManager;
  late TestNamedEntityManager entityManager;

  setUp(() async {
    appManager = StubbedAppManager();

    dataManager = appManager.localDatabaseManager;
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    entityManager = TestNamedEntityManager(appManager.app);
  });

  test("nameExists", () async {
    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bass");
    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bluegill");
    await entityManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Catfish");

    expect(entityManager.nameExists(""), false);
    expect(entityManager.nameExists("bass"), true);
    expect(entityManager.nameExists("  Catfish"), true);
    expect(entityManager.nameExists("  catfish "), true);
    expect(entityManager.nameExists("perch"), false);
  });

  test("named with andCondition", () async {
    var id = randomId();

    await entityManager.addOrUpdate(Species()
      ..id = id
      ..name = "Bass");

    expect(
      entityManager.named("Bass", andCondition: (species) => species.id == id),
      isNotNull,
    );
    expect(
      entityManager.named(
        "Bass",
        andCondition: (species) => species.id == randomId(),
      ),
      isNull,
    );
  });

  testWidgets("nameComparator", (tester) async {
    var species = [
      Species()
        ..id = randomId()
        ..name = "Smallmouth Bass",
      Species()
        ..id = randomId()
        ..name = "Largemouth Bass",
      Species()
        ..id = randomId()
        ..name = "Blue Catfish",
      Species()
        ..id = randomId()
        ..name = "Flathead Catfish",
    ];

    species
        .sort(entityManager.displayNameComparator(await buildContext(tester)));
    expect(species[0].name, "Blue Catfish");
    expect(species[1].name, "Flathead Catfish");
    expect(species[2].name, "Largemouth Bass");
    expect(species[3].name, "Smallmouth Bass");
  });
}
