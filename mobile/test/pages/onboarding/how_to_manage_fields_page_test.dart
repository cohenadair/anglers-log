import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/onboarding/how_to_manage_fields_page.dart';
import 'package:mockito/mockito.dart';

import '../../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.anglerManager.entityExists(any)).thenReturn(false);

    when(
      managers.baitManager.attachmentsDisplayValues(any, any),
    ).thenReturn([]);

    when(managers.customEntityManager.entity(any)).thenReturn(null);
    when(managers.customEntityManager.entityExists(any)).thenReturn(false);

    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);

    when(managers.speciesManager.entityExists(any)).thenReturn(false);

    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(
      managers.userPreferenceManager.waterDepthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(managers.waterClarityManager.entityExists(any)).thenReturn(false);
  });

  testWidgets("Menu hiding/showing", (tester) async {
    await tester.pumpWidget(Testable((_) => const HowToManageFieldsPage()));
    // One for title.
    expect(find.text("Manage Fields"), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text("Manage Fields"), findsNWidgets(2));

    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text("Manage Fields"), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text("Manage Fields"), findsNWidgets(2));
  });

  testWidgets(
    "Hide tick does not crash when nested navigator has no routes left",
    (tester) async {
      await pumpContext(tester, (_) => const HowToManageFieldsPage());

      // Opens the popup menu; the timer now expects a matching hide tick.
      await tester.pump(const Duration(milliseconds: 2000));
      expect(find.text("Manage Fields"), findsNWidgets(2));

      // Drains the embedded page's nested navigator down to zero routes,
      // reproducing the state Crashlytics events show in the field: by
      // the time the timer's hide tick runs, there's nothing left for it
      // to pop.
      var popupMenuButtonFinder = find.byWidgetPredicate(
        (widget) => widget is PopupMenuButton,
      );
      for (var i = 0; i < 3; i++) {
        Navigator.of(tester.element(popupMenuButtonFinder.first)).pop();
        await tester.pump(const Duration(milliseconds: 300));
      }

      // The timer's hide tick fires against a navigator with no routes
      // left to pop.
      await tester.pump(const Duration(milliseconds: 2000));

      expect(tester.takeException(), isNull);
    },
  );
}
