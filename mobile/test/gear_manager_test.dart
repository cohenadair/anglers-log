import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late GearManager gearManager;

  setUp(() {
    appManager = StubbedAppManager();

    gearManager = GearManager(appManager.app);

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.imageManager.save(
      any,
      compress: anyNamed("compress"),
    )).thenAnswer((invocation) {
      return Future.value((invocation.positionalArguments.first as List<File>?)
              ?.map((f) => f.path)
              .toList() ??
          []);
    });
  });

  testWidgets("Filtering by search: gear doesn't exist", (tester) async {
    expect(
      gearManager.matchesFilter(
          randomId(), await buildContext(tester), "stick"),
      isFalse,
    );
  });

  testWidgets("Filtering by search: no matches", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      name: "Ugly Stick Bass",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "ABC"),
      isFalse,
    );
  });

  testWidgets("Filtering by search: name", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      name: "Ugly Stick Bass",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "stick"),
      isTrue,
    );
  });

  testWidgets("Filtering by search: rod make and model", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      rodMakeModel: "Ugly Stick",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "stick"),
      isTrue,
    );
  });

  testWidgets("Filtering by search: rod serial number", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      rodSerialNumber: "ABC123",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "c12"),
      isTrue,
    );
  });

  testWidgets("Filtering by search: reel make and model", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      reelMakeModel: "Pflueger",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "lueger"),
      isTrue,
    );
  });

  testWidgets("Filtering by search: reel serial number", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      reelSerialNumber: "ABC123",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "ABC"),
      isTrue,
    );
  });

  testWidgets("Filtering by search: reel size", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      reelSize: "3000",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "3000"),
      isTrue,
    );
  });

  testWidgets("Filtering by search: line make and model", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      lineMakeModel: "FireLine Crystal",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "crystal"),
      isTrue,
    );
  });

  testWidgets("Filtering by search: line color", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      lineColor: "White",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "white"),
      isTrue,
    );
  });

  testWidgets("Filtering by search: hook make and model", (tester) async {
    var id = randomId();
    await gearManager.addOrUpdate(Gear(
      id: id,
      hookMakeModel: "Mustad Demon",
    ));
    expect(
      gearManager.matchesFilter(id, await buildContext(tester), "demon"),
      isTrue,
    );
  });

  testWidgets("Filtering by search: rod length", (tester) async {
    var id = randomId();
    var context = await buildContext(tester);
    await gearManager.addOrUpdate(Gear(
      id: id,
      rodLength: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.feet,
          value: 9,
        ),
        fractionValue: Measurement(
          unit: Unit.inches,
          value: 6,
        ),
      ),
    ));
    expect(gearManager.matchesFilter(id, context, "9 ft 6"), isTrue);
  });

  testWidgets("Filtering by search: rod action", (tester) async {
    var id = randomId();
    var context = await buildContext(tester);
    await gearManager.addOrUpdate(Gear(
      id: id,
      rodAction: RodAction.fast,
    ));
    expect(gearManager.matchesFilter(id, context, "fast"), isTrue);
  });

  testWidgets("Filtering by search: rod power", (tester) async {
    var id = randomId();
    var context = await buildContext(tester);
    await gearManager.addOrUpdate(Gear(
      id: id,
      rodPower: RodPower.heavy,
    ));
    expect(gearManager.matchesFilter(id, context, "heav"), isTrue);
  });

  testWidgets("Filtering by search: line rating", (tester) async {
    var id = randomId();
    var context = await buildContext(tester);
    await gearManager.addOrUpdate(Gear(
      id: id,
      lineRating: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.pound_test,
          value: 15,
        ),
      ),
    ));
    expect(gearManager.matchesFilter(id, context, "15"), isTrue);
    expect(gearManager.matchesFilter(id, context, "test"), isTrue);
  });

  testWidgets("Filtering by search: leader length", (tester) async {
    var id = randomId();
    var context = await buildContext(tester);
    await gearManager.addOrUpdate(Gear(
      id: id,
      leaderLength: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.feet,
          value: 20,
        ),
      ),
    ));
    expect(gearManager.matchesFilter(id, context, "20"), isTrue);
  });

  testWidgets("Filtering by search: leader rating", (tester) async {
    var id = randomId();
    var context = await buildContext(tester);
    await gearManager.addOrUpdate(Gear(
      id: id,
      leaderRating: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.x,
          value: 3,
        ),
      ),
    ));
    expect(gearManager.matchesFilter(id, context, "3X"), isTrue);
  });

  testWidgets("Filtering by search: tippet length", (tester) async {
    var id = randomId();
    var context = await buildContext(tester);
    await gearManager.addOrUpdate(Gear(
      id: id,
      tippetLength: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.inches,
          value: 36,
        ),
      ),
    ));
    expect(gearManager.matchesFilter(id, context, "36"), isTrue);
  });

  testWidgets("Filtering by search: tippet rating", (tester) async {
    var id = randomId();
    var context = await buildContext(tester);
    await gearManager.addOrUpdate(Gear(
      id: id,
      tippetRating: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.x,
          value: 5,
        ),
      ),
    ));
    expect(gearManager.matchesFilter(id, context, "5X"), isTrue);
  });

  testWidgets("Filtering by search: hook size", (tester) async {
    var id = randomId();
    var context = await buildContext(tester);
    await gearManager.addOrUpdate(Gear(
      id: id,
      hookSize: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.aught,
          value: 5,
        ),
      ),
    ));
    expect(gearManager.matchesFilter(id, context, "5O"), isTrue);
  });

  testWidgets("numberOfCatches", (tester) async {
    var gearId = randomId();
    when(appManager.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        gearIds: [gearId],
      ),
      Catch(id: randomId()),
    ]);
    expect(gearManager.numberOfCatches(gearId), 1);
  });

  testWidgets("numberOfCatchQuantities", (tester) async {
    var gearId = randomId();
    when(appManager.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        gearIds: [gearId],
        quantity: 5,
      ),
      Catch(id: randomId()),
    ]);
    expect(gearManager.numberOfCatchQuantities(gearId), 5);
  });

  testWidgets("deleteMessage single catch", (tester) async {
    var gearId = randomId();
    when(appManager.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        gearIds: [gearId],
      ),
      Catch(id: randomId()),
    ]);
    var deleteMessage = gearManager.deleteMessage(
      await buildContext(tester),
      Gear(
        id: gearId,
        name: "Test Gear",
      ),
    );
    expect(
      deleteMessage,
      "Test Gear is associated with 1 catch; are you sure you want to delete it? This cannot be undone.",
    );
  });

  testWidgets("deleteMessage multiple catches", (tester) async {
    var gearId = randomId();
    when(appManager.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        gearIds: [gearId],
      ),
      Catch(
        id: randomId(),
        gearIds: [gearId],
      ),
    ]);
    var deleteMessage = gearManager.deleteMessage(
      await buildContext(tester),
      Gear(
        id: gearId,
        name: "Test Gear",
      ),
    );
    expect(
      deleteMessage,
      "Test Gear is associated with 2 catches; are you sure you want to delete it? This cannot be undone.",
    );
  });
}
