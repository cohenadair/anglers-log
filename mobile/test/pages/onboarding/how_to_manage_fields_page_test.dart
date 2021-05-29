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

    when(appManager.customEntityManager.entity(any)).thenReturn(null);

    when(appManager.userPreferenceManager.catchCustomEntityIds).thenReturn([]);
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
  });

  testWidgets("Menu hiding/showing", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => HowToManageFieldsPage(),
        appManager: appManager,
      ),
    );
    // One for title.
    expect(find.text("Manage Fields"), findsOneWidget);

    await tester.pump(Duration(milliseconds: 2000));
    expect(find.text("Manage Fields"), findsNWidgets(2));

    await tester.pump(Duration(milliseconds: 2000));
    expect(find.text("Manage Fields"), findsOneWidget);

    await tester.pump(Duration(milliseconds: 2000));
    expect(find.text("Manage Fields"), findsNWidgets(2));
  });
}
