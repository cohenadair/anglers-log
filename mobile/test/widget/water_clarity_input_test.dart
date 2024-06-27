import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/water_clarity_list_page.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/water_clarity_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.waterClarityManager.entityExists(any)).thenReturn(false);
    when(appManager.waterClarityManager.listSortedByDisplayName(any))
        .thenReturn([]);
  });

  testWidgets("Picker is shown", (tester) async {
    await pumpContext(
      tester,
      (_) => WaterClarityInput(IdInputController()),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("Water Clarity"));
    expect(find.byType(WaterClarityListPage), findsOneWidget);
  });
}
