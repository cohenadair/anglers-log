import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

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
            controller: DateTimeInputController(context)
              ..value = dateTime(2020, 1, 1),
          ),
          timePicker: TimePicker(
            context,
            label: "Time Picker",
            controller: DateTimeInputController(context)
              ..value = dateTime(2020, 1, 1, 15, 30),
          ),
          helper: const Text("A helping message"),
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
            controller: DateTimeInputController(context)
              ..value = dateTime(2020, 1, 1),
          ),
          timePicker: TimePicker(
            context,
            label: "Time Picker",
            controller: DateTimeInputController(context)
              ..value = dateTime(2020, 1, 1, 15, 30),
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
          controller: DateTimeInputController(context),
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
          controller: DateTimeInputController(context),
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
      late DateTimeInputController controller;

      await tester.pumpWidget(Testable(
        (context) {
          controller = DateTimeInputController(context);
          controller.value = dateTime(2020, 1, 25);

          return DatePicker(
            context,
            label: "Date Picker",
            onChange: (_) => changed = true,
            controller: controller,
          );
        },
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
      expect(controller.value, dateTime(2020, 1, 26));
    });

    testWidgets("DatePicker null controller value shows empty", (tester) async {
      when(appManager.timeManager.currentDateTime).thenReturn(dateTime(2020));

      late DateTimeInputController controller;
      await pumpContext(
        tester,
        (context) {
          controller = DateTimeInputController(context);
          return DatePicker(
            context,
            label: "Date",
            controller: controller,
          );
        },
      );

      // Verify the field is empty.
      expect(find.byType(Empty), findsOneWidget);

      await tapAndSettle(tester, find.byType(DatePicker));
      await tapAndSettle(tester, find.text("OK"));

      // Verify the picker defaulted to the current (non-null) date.
      expect(find.byType(DateLabel), findsOneWidget);
    });

    testWidgets("TimePicker time picked", (tester) async {
      var changed = false;
      late DateTimeInputController controller;

      await tester.pumpWidget(Testable(
        (context) {
          controller = DateTimeInputController(context);
          controller.time = const TimeOfDay(hour: 5, minute: 20);

          return TimePicker(
            context,
            label: "Time Picker",
            onChange: (_) => changed = true,
            controller: controller,
          );
        },
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
      var center = tester
          .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      var hour6 = Offset(center.dx, center.dy + 50.0); // 6:00
      var min48 = Offset(center.dx - 50.0, center.dy - 15); // 50 min

      await tester.tapAt(hour6);
      await tester.pumpAndSettle();
      await tester.tapAt(min48);
      await tester.pumpAndSettle();
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();

      // Dialog disappears and callback called.
      expect(
          find.byKey(const ValueKey<String>('time-picker-dial')), findsNothing);
      expect(changed, isTrue);
      expect(find.text("6:50 AM"), findsOneWidget);

      expect(controller.time, isNotNull);
      expect(controller.time, const TimeOfDay(hour: 6, minute: 50));
    });

    testWidgets("TimePicker null controller value shows empty", (tester) async {
      when(appManager.timeManager.currentTime)
          .thenReturn(const TimeOfDay(hour: 1, minute: 1));

      await pumpContext(
        tester,
        (context) {
          var controller = DateTimeInputController(context);
          return TimePicker(
            context,
            label: "Time",
            controller: controller,
          );
        },
      );

      // Verify the field is empty.
      expect(find.byType(Empty), findsOneWidget);

      await tapAndSettle(tester, find.byType(TimePicker));
      await tapAndSettle(tester, find.text("OK"));

      // Verify the picker defaulted to the current (non-null) time.
      expect(find.byType(TimeLabel), findsOneWidget);
    });
  });
}
