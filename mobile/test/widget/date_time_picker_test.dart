import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/widget.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockTimeManager: true,
    );
  });

  group("DateTimePickerContainer", () {
    testWidgets("With helper", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (context) => DateTimePicker(
          datePicker: DatePicker(
            context,
            label: "Date Picker",
          ),
          timePicker: TimePicker(
            context,
            label: "Time Picker",
          ),
          helper: Text("A helping message"),
        ),
        appManager: appManager,
      ));

      expect(find.text("A helping message"), findsOneWidget);
      expect(find.byType(Empty), findsNothing);
    });

    testWidgets("Without helper", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (context) => DateTimePicker(
          datePicker: DatePicker(
            context,
            label: "Date Picker",
          ),
          timePicker: TimePicker(
            context,
            label: "Time Picker",
          ),
        ),
        appManager: appManager,
      ));

      expect(find.byType(Empty), findsOneWidget);
    });
  });

  group("Date and time pickers", () {
    testWidgets("Enabled", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (context) => DatePicker(
          context,
          label: "Date Picker",
        ),
        appManager: appManager,
      ));
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();

      // The "1" from day 1 of the current month.
      expect(find.text("1"), findsOneWidget);
    });

    testWidgets("Disabled", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (context) => DatePicker(
          context,
          label: "Date Picker",
          enabled: false,
        ),
        appManager: appManager,
      ));
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();

      // The "1" from day 1 of the current month.
      expect(find.text("1"), findsNothing);
    });

    testWidgets("DatePicker date picked", (WidgetTester tester) async {
      bool changed = false;
      await tester.pumpWidget(Testable(
        (context) => DatePicker(
          context,
          label: "Date Picker",
          onChange: (_) => changed = true,
          initialDate: DateTime(2020, 1, 25),
        ),
        appManager: appManager,
      ));

      // Date doesn't change.
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text("CANCEL"));
      await tester.pumpAndSettle();
      expect(changed, isFalse);

      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text("26"));
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();

      // Dialog disappears and callback called.
      expect(find.text("1"), findsNothing);
      expect(changed, isTrue);
      expect(find.text("Jan 26, 2020"), findsOneWidget);
    });

    testWidgets("TimePicker time picked", (WidgetTester tester) async {
      bool changed = false;
      await tester.pumpWidget(Testable(
        (context) => TimePicker(
          context,
          label: "Time Picker",
          onChange: (_) => changed = true,
          initialTime: TimeOfDay(hour: 5, minute: 20),
        ),
        appManager: appManager,
      ));

      expect(find.text("5:20 AM"), findsOneWidget);

      // Time doesn't change.
      await tester.tap(find.byType(TimePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text("CANCEL"));
      await tester.pumpAndSettle();
      expect(changed, isFalse);

      await tester.tap(find.byType(TimePicker));
      await tester.pumpAndSettle();

      // Click time based on center clock, since actual Text widgets aren't
      // used.
      Offset center =
          tester.getCenter(find.byKey(ValueKey<String>('time-picker-dial')));
      Offset hour6 = Offset(center.dx, center.dy + 50.0); // 6:00
      Offset min48 = Offset(center.dx - 50.0, center.dy - 15); // 50 min

      await tester.tapAt(hour6);
      await tester.pumpAndSettle();
      await tester.tapAt(min48);
      await tester.pumpAndSettle();
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();

      // Dialog disappears and callback called.
      expect(find.byKey(ValueKey<String>('time-picker-dial')), findsNothing);
      expect(changed, isTrue);
      expect(find.text("6:50 AM"), findsOneWidget);
    });
  });
}
