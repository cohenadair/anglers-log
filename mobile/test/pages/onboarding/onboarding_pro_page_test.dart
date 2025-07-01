import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/onboarding_pro_page.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/stubbed_managers.dart';
import '../../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
  });

  testWidgets("Finish button is shown when user upgrades to pro",
      (tester) async {
    var controller = StreamController.broadcast();
    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => controller.stream);
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    await pumpContext(
      tester,
      (_) => OnboardingProPage(onNext: (_) {}),
    );

    expect(find.text("NOT NOW"), findsOneWidget);
    expect(find.text("FINISH"), findsNothing);

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.lib.subscriptionManager.isPro).thenReturn(true);
    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text("NOT NOW"), findsNothing);
    expect(find.text("FINISH"), findsOneWidget);
  });
}
