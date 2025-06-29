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

    when(managers.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
  });

  testWidgets("Finish button is shown when user upgrades to pro",
      (tester) async {
    var controller = StreamController.broadcast();
    when(managers.subscriptionManager.stream)
        .thenAnswer((_) => controller.stream);
    when(managers.subscriptionManager.isFree).thenReturn(true);
    when(managers.subscriptionManager.isPro).thenReturn(false);

    await pumpContext(
      tester,
      (_) => OnboardingProPage(onNext: (_) {}),
      managers: managers,
    );

    expect(find.text("NOT NOW"), findsOneWidget);
    expect(find.text("FINISH"), findsNothing);

    when(managers.subscriptionManager.isFree).thenReturn(false);
    when(managers.subscriptionManager.isPro).thenReturn(true);
    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text("NOT NOW"), findsNothing);
    expect(find.text("FINISH"), findsOneWidget);
  });
}
