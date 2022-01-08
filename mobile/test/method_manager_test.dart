import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockCatchManager catchManager;

  late MethodManager methodManager;

  setUp(() {
    appManager = StubbedAppManager();

    catchManager = appManager.catchManager;

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());

    methodManager = MethodManager(appManager.app);
  });

  test("Number of catches", () {
    var methodId0 = randomId();
    var methodId1 = randomId();
    var methodId2 = randomId();
    var methodId3 = randomId();

    when(catchManager.list()).thenReturn([
      Catch()
        ..id = randomId()
        ..methodIds.addAll([methodId0, methodId2]),
      Catch()
        ..id = randomId()
        ..methodIds.add(methodId1),
      Catch()
        ..id = randomId()
        ..methodIds.add(methodId2),
      Catch()
        ..id = randomId()
        ..methodIds.addAll([methodId0, methodId1]),
      Catch()
        ..id = randomId()
        ..methodIds.add(methodId3),
      Catch()..id = randomId()
    ]);

    expect(methodManager.numberOfCatches(null), 0);
    expect(methodManager.numberOfCatches(methodId0), 2);
    expect(methodManager.numberOfCatches(methodId1), 2);
    expect(methodManager.numberOfCatches(methodId2), 2);
    expect(methodManager.numberOfCatches(methodId3), 1);
  });

  group("deleteMessage", () {
    testWidgets("Singular", (tester) async {
      var method = Method()
        ..id = randomId()
        ..name = "Casting";

      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..methodIds.add(method.id),
      ]);

      var context = await buildContext(tester);
      expect(
        methodManager.deleteMessage(context, method),
        "Casting is associated with 1 catch; are you sure you want to delete "
        "it? This cannot be undone.",
      );
    });

    testWidgets("Plural zero", (tester) async {
      var method = Method()
        ..id = randomId()
        ..name = "Casting";
      when(catchManager.list()).thenReturn([]);

      var context = await buildContext(tester);
      expect(
        methodManager.deleteMessage(context, method),
        "Casting is associated with 0 catches; are you sure you want to delete "
        "it? This cannot be undone.",
      );
    });

    testWidgets("Plural not zero", (tester) async {
      var method = Method()
        ..id = randomId()
        ..name = "Casting";
      when(catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..methodIds.add(method.id),
        Catch()
          ..id = randomId()
          ..methodIds.add(method.id),
      ]);

      var context = await buildContext(tester);
      expect(
        methodManager.deleteMessage(context, method),
        "Casting is associated with 2 catches; are you sure you want to delete "
        "it? This cannot be undone.",
      );
    });
  });
}
