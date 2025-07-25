import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/onboarding/catch_field_picker_page.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.userPreferenceManager.waterDepthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  testWidgets("Null onNext doesn't crash", (tester) async {
    await tester.pumpWidget(
      Testable((_) => CatchFieldPickerPage(onNext: (_) => {})),
    );
    await tapAndSettle(tester, find.text("NEXT"));
  });

  testWidgets("onNext invoked", (tester) async {
    var called = false;
    await tester.pumpWidget(
      Testable((_) => CatchFieldPickerPage(onNext: (_) => called = true)),
    );

    await tapAndSettle(tester, find.text("NEXT"));

    expect(called, isTrue);
    verify(managers.userPreferenceManager.setCatchFieldIds(any)).called(1);
  });

  testWidgets("Selecting items updates state", (tester) async {
    await tester.pumpWidget(
      Testable((_) => CatchFieldPickerPage(onNext: (_) {})),
    );

    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(PickerListItem, "Bait"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    await tapAndSettle(tester, find.text("NEXT"));

    var result = verify(
      managers.userPreferenceManager.setCatchFieldIds(captureAny),
    );
    // 22 pre-selected, minus 1 that was deselected
    expect((result.captured.first as List).length, 21);
  });

  testWidgets("Item shows correct content", (tester) async {
    await tester.pumpWidget(Testable((_) => const CatchFieldPickerPage()));

    expect(find.text("Required"), findsNWidgets(2));
    expect(find.text("Date and Time"), findsOneWidget);
    expect(find.text("Species"), findsOneWidget);
    expect(find.text("Photos"), findsOneWidget);
    expect(find.text("Bait"), findsOneWidget);
    expect(find.text("Fishing Spot"), findsOneWidget);
    expect(find.text("Coordinates of where a catch was made."), findsOneWidget);
  });
}
