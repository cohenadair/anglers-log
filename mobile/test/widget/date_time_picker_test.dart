import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/widget.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  group("DateTimePickerContainer", () {
    testWidgets("With helper", (tester) async {
      await tester.pumpWidget(Testable(
        (context) => DateTimePicker(
          datePicker: DatePicker(
            context,
            label: "Date Picker",
            controller: TimestampInputController(appManager.timeManager),
          ),
          timePicker: TimePicker(
            context,
            label: "Time Picker",
            controller: TimestampInputController(appManager.timeManager),
          ),
          helper: Text("A helping message"),
        ),
        appManager: appManager,
      ));

      expect(find.text("A helping message"), findsOneWidget);
      expect(find.byType(Empty), findsNothing);
    });

    testWidgets("Without helper", (tester) async {
      await tester.pumpWidget(Testable(
        (context) => DateTimePicker(
          datePicker: DatePicker(
            context,
            label: "Date Picker",
            controller: TimestampInputController(appManager.timeManager),
          ),
          timePicker: TimePicker(
            context,
            label: "Time Picker",
            controller: TimestampInputController(appManager.timeManager),
          ),
        ),
        appManager: appManager,
      ));

      expect(find.byType(Empty), findsOneWidget);
    });
  });

  group("Date and time pickers", () {
    testWidgets("Enabled", (tester) async {
      await tester.pumpWidget(Testable(
        (context) => DatePicker(
          context,
          label: "Date Picker",
          controller: TimestampInputController(appManager.timeManager),
        ),
        appManager: appManager,
      ));
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();

      // The "1" from day 1 of the current month.
      expect(find.text("1"), findsOneWidget);
    });

    testWidgets("Disabled", (tester) async {
      await tester.pumpWidget(Testable(
        (context) => DatePicker(
          context,
          label: "Date Picker",
          enabled: false,
          controller: TimestampInputController(appManager.timeManager),
        ),
        appManager: appManager,
      ));
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();

      // The "1" from day 1 of the current month.
      expect(find.text("1"), findsNothing);
    });

    testWidgets("DatePicker date picked", (tester) async {
      var changed = false;
      var controller = TimestampInputController(appManager.timeManager);
      controller.value = DateTime(2020, 1, 25).millisecondsSinceEpoch;

      await tester.pumpWidget(Testable(
        (context) => DatePicker(
          context,
          label: "Date Picker",
          onChange: (_) => changed = true,
          controller: controller,
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
      expect(controller.value, isNotNull);
      expect(controller.value, DateTime(2020, 1, 26).millisecondsSinceEpoch);
    });

    testWidgets("TimePicker time picked", (tester) async {
      var changed = false;
      var controller = TimestampInputController(appManager.timeManager);
      controller.time = TimeOfDay(hour: 5, minute: 20);

      await tester.pumpWidget(Testable(
        (context) => TimePicker(
          context,
          label: "Time Picker",
          onChange: (_) => changed = true,
          controller: controller,
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
      var center =
          tester.getCenter(find.byKey(ValueKey<String>('time-picker-dial')));
      var hour6 = Offset(center.dx, center.dy + 50.0); // 6:00
      var min48 = Offset(center.dx - 50.0, center.dy - 15); // 50 min

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

      expect(controller.time, isNotNull);
      expect(controller.time, TimeOfDay(hour: 6, minute: 50));
    });
  });
}
