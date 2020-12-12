import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/catch_field_picker_page.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../../mock_app_manager.dart';
import '../../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockPreferencesManager: true,
    );
  });

  testWidgets("Null onNext doesn't crash", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => CatchFieldPickerPage(
          onNext: () => {},
        ),
        appManager: appManager,
      ),
    );
    await tapAndSettle(tester, find.text("NEXT"));
  });

  testWidgets("onNext invoked", (tester) async {
    var called = false;
    await tester.pumpWidget(
      Testable(
        (_) => CatchFieldPickerPage(
          onNext: () => called = true,
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.text("NEXT"));

    expect(called, isTrue);
    verify(appManager.mockPreferencesManager.catchFieldIds = any).called(1);
  });

  testWidgets("Selecting items updates state", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => CatchFieldPickerPage(
          onNext: () {},
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(PickerListItem, "Bait"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    await tapAndSettle(tester, find.text("NEXT"));

    var result =
        verify(appManager.mockPreferencesManager.catchFieldIds = captureAny);
    // 2 required + 1 selected
    expect((result.captured.first as List).length, 3);
  });

  testWidgets("Item shows correct content", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => CatchFieldPickerPage(),
        appManager: appManager,
      ),
    );

    expect(find.text("Required"), findsNWidgets(2));
    expect(find.text("Date & Time"), findsOneWidget);
    expect(find.text("Species"), findsOneWidget);
    expect(find.text("Photos"), findsOneWidget);
    expect(find.text("Bait"), findsOneWidget);
    expect(find.text("Fishing Spot"), findsOneWidget);
    expect(find.text("Coordinates of where a catch was made."), findsOneWidget);
  });
}
