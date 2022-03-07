import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/widgets/pro_overlay.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
  });

  testWidgets("State rebuilds on subscription changes", (tester) async {
    var controller = StreamController<void>.broadcast(sync: true);
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.subscriptionManager.isFree).thenReturn(true);

    await pumpContext(
      tester,
      (_) => const ProOverlay(
        proWidget: Text("Pro Widget"),
        description: "Test description.",
      ),
      appManager: appManager,
    );

    // Starts as free.
    expect(find.text("UPGRADE"), findsOneWidget);
    expect(find.text("Pro Widget"), findsNothing);

    // Upgrade to pro.
    when(appManager.subscriptionManager.isFree).thenReturn(false);
    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text("UPGRADE"), findsNothing);
    expect(find.text("Pro Widget"), findsOneWidget);

    // Downgrade back to free.
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text("UPGRADE"), findsOneWidget);
    expect(find.text("Pro Widget"), findsNothing);
  });

  testWidgets("Button opens pro page", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(true);

    await pumpContext(
      tester,
      (_) => const ProOverlay(
        proWidget: Text("Pro Widget"),
        description: "Test description.",
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("UPGRADE"));
    expect(find.byType(ProPage), findsOneWidget);
  });
}
