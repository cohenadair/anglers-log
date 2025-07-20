import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/water_clarity_list_page.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/water_clarity_input.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.waterClarityManager.entityExists(any)).thenReturn(false);
    when(
      managers.waterClarityManager.listSortedByDisplayName(any),
    ).thenReturn([]);
  });

  testWidgets("Picker is shown", (tester) async {
    await pumpContext(tester, (_) => WaterClarityInput(IdInputController()));

    await tapAndSettle(tester, find.text("Water Clarity"));
    expect(find.byType(WaterClarityListPage), findsOneWidget);
  });
}
