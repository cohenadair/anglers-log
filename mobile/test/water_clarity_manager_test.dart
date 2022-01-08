import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockCatchManager catchManager;

  late WaterClarityManager waterClarityManager;

  setUp(() {
    appManager = StubbedAppManager();

    catchManager = appManager.catchManager;

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    waterClarityManager = WaterClarityManager(appManager.app);
  });

  test("Number of catches", () {
    var waterClarityId0 = randomId();
    var waterClarityId1 = randomId();
    var waterClarityId2 = randomId();
    var waterClarityId3 = randomId();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..waterClarityId = waterClarityId0,
      Catch()
        ..id = randomId()
        ..waterClarityId = waterClarityId1,
      Catch()
        ..id = randomId()
        ..waterClarityId = waterClarityId2,
      Catch()
        ..id = randomId()
        ..waterClarityId = waterClarityId0,
      Catch()
        ..id = randomId()
        ..waterClarityId = waterClarityId3,
      Catch()..id = randomId()
    ]);

    expect(waterClarityManager.numberOfCatches(null), 0);
    expect(waterClarityManager.numberOfCatches(waterClarityId0), 2);
    expect(waterClarityManager.numberOfCatches(waterClarityId1), 1);
    expect(waterClarityManager.numberOfCatches(waterClarityId2), 1);
    expect(waterClarityManager.numberOfCatches(waterClarityId3), 1);
  });

  group("deleteMessage", () {
    testWidgets("Singular", (tester) async {
      var angler = WaterClarity()
        ..id = randomId()
        ..name = "Clear";

      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..waterClarityId = angler.id,
      ]);

      var context = await buildContext(tester);
      expect(
        waterClarityManager.deleteMessage(context, angler),
        "Clear is associated with 1 catch; are you sure you want to delete "
        "it? This cannot be undone.",
      );
    });

    testWidgets("Plural zero", (tester) async {
      var angler = WaterClarity()
        ..id = randomId()
        ..name = "Clear";
      when(catchManager.list()).thenReturn([]);

      var context = await buildContext(tester);
      expect(
        waterClarityManager.deleteMessage(context, angler),
        "Clear is associated with 0 catches; are you sure you want to delete "
        "it? This cannot be undone.",
      );
    });

    testWidgets("Plural not zero", (tester) async {
      var angler = WaterClarity()
        ..id = randomId()
        ..name = "Clear";
      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..waterClarityId = angler.id,
        Catch()
          ..id = randomId()
          ..waterClarityId = angler.id,
      ]);

      var context = await buildContext(tester);
      expect(
        waterClarityManager.deleteMessage(context, angler),
        "Clear is associated with 2 catches; are you sure you want to delete "
        "it? This cannot be undone.",
      );
    });
  });
}
