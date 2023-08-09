import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/onboarding/how_to_manage_fields_page.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/stubbed_app_manager.dart';
import '../../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.anglerManager.entityExists(any)).thenReturn(false);

    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn([]);

    when(appManager.customEntityManager.entity(any)).thenReturn(null);
    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    when(appManager.subscriptionManager.isFree).thenReturn(false);

    when(appManager.speciesManager.entityExists(any)).thenReturn(false);

    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(appManager.waterClarityManager.entityExists(any)).thenReturn(false);
  });

  testWidgets("Menu hiding/showing", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => const HowToManageFieldsPage(),
        appManager: appManager,
      ),
    );
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
