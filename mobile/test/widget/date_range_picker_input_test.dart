import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/list_picker_input.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create(); // For TimeManager.
  });

  testWidgets("onPicked is called", (tester) async {
    var picked = false;
    await tester.pumpWidget(
      Testable((_) => DateRangePickerInput(onPicked: (_) => picked = true)),
    );

    // Tap row.
    expect(find.text("All dates"), findsOneWidget);
    await tester.tap(find.byType(ListPickerInput));
    await tester.pumpAndSettle();

    // New page is shown.
    expect(find.text("Last week"), findsOneWidget);
    await tester.tap(find.text("Last week"));
    await tester.pumpAndSettle();

    // Callback was called.
    expect(picked, isTrue);

    // Page was popped, value was updated.
    expect(find.text("Last week"), findsOneWidget);
    expect(find.text("All dates"), findsNothing);
  });
}
