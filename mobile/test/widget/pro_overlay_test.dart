import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:mobile/widgets/pro_overlay.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(managers.lib.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
  });

  testWidgets("State rebuilds on subscription changes", (tester) async {
    var controller = StreamController<void>.broadcast(sync: true);
    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => controller.stream);
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);

    await pumpContext(
      tester,
      (_) => const ProOverlay(
        proWidget: Text("Pro Widget"),
        description: "Test description.",
      ),
      managers: managers,
    );

    // Starts as free.
    expect(find.text("UPGRADE"), findsOneWidget);
    expect(find.text("Pro Widget"), findsNothing);

    // Upgrade to pro.
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text("UPGRADE"), findsNothing);
    expect(find.text("Pro Widget"), findsOneWidget);

    // Downgrade back to free.
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text("UPGRADE"), findsOneWidget);
    expect(find.text("Pro Widget"), findsNothing);
  });

  testWidgets("Button opens pro page", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);

    await pumpContext(
      tester,
      (_) => const ProOverlay(
        proWidget: Text("Pro Widget"),
        description: "Test description.",
      ),
      managers: managers,
    );

    await tapAndSettle(tester, find.text("UPGRADE"));
    expect(find.byType(AnglersLogProPage), findsOneWidget);
  });
}
