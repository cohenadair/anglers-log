import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/onboarding/how_to_manage_fields_page.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/stubbed_managers.dart';
import '../../test_utils.dart';

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
}
