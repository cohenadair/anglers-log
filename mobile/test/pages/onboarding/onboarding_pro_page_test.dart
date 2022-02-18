import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/onboarding_pro_page.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/stubbed_app_manager.dart';
import '../../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
  });

  testWidgets("Finish button is shown when user upgrades to pro",
      (tester) async {
    var controller = StreamController.broadcast();
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    await pumpContext(
      tester,
      (_) => OnboardingProPage(onNext: () {}),
      appManager: appManager,
    );

    expect(find.text("NOT NOW"), findsOneWidget);
    expect(find.text("FINISH"), findsNothing);

    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(true);
    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text("NOT NOW"), findsNothing);
    expect(find.text("FINISH"), findsOneWidget);
  });
}
