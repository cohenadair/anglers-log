import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockCatchManager catchManager;

  late AnglerManager anglerManager;

  setUp(() {
    appManager = StubbedAppManager();

    catchManager = appManager.catchManager;

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    anglerManager = AnglerManager(appManager.app);
  });

  test("Number of catches", () {
    var anglerId0 = randomId();
    var anglerId1 = randomId();
    var anglerId2 = randomId();
    var anglerId3 = randomId();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..anglerId = anglerId0,
      Catch()
        ..id = randomId()
        ..anglerId = anglerId1,
      Catch()
        ..id = randomId()
        ..anglerId = anglerId2,
      Catch()
        ..id = randomId()
        ..anglerId = anglerId0,
      Catch()
        ..id = randomId()
        ..anglerId = anglerId3,
      Catch()..id = randomId()
    ]);

    expect(anglerManager.numberOfCatches(null), 0);
    expect(anglerManager.numberOfCatches(anglerId0), 2);
    expect(anglerManager.numberOfCatches(anglerId1), 1);
    expect(anglerManager.numberOfCatches(anglerId2), 1);
    expect(anglerManager.numberOfCatches(anglerId3), 1);
  });

  group("deleteMessage", () {
    testWidgets("Singular", (tester) async {
      var angler = Angler()
        ..id = randomId()
        ..name = "Cohen";

      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..anglerId = angler.id,
      ]);

      var context = await buildContext(tester);
      expect(
        anglerManager.deleteMessage(context, angler),
        "Cohen is associated with 1 catch; are you sure you want to delete "
        "them? This cannot be undone.",
      );
    });

    testWidgets("Plural zero", (tester) async {
      var angler = Angler()
        ..id = randomId()
        ..name = "Cohen";
      when(catchManager.list()).thenReturn([]);

      var context = await buildContext(tester);
      expect(
        anglerManager.deleteMessage(context, angler),
        "Cohen is associated with 0 catches; are you sure you want to delete "
        "them? This cannot be undone.",
      );
    });

    testWidgets("Plural not zero", (tester) async {
      var angler = Angler()
        ..id = randomId()
        ..name = "Cohen";
      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..anglerId = angler.id,
        Catch()
          ..id = randomId()
          ..anglerId = angler.id,
      ]);

      var context = await buildContext(tester);
      expect(
        anglerManager.deleteMessage(context, angler),
        "Cohen is associated with 2 catches; are you sure you want to delete "
        "them? This cannot be undone.",
      );
    });
  });
}
