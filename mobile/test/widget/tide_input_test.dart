import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/tide_input.dart';

import '../test_utils.dart';

void main() {
  late InputController<Tide> controller;

  setUp(() {
    controller = InputController<Tide>();
  });

  testWidgets("Tapping opens input page", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => TideInput(
          controller: controller,
          dateTime: now(),
        ),
      ),
    );

    expect(find.text("FETCH"), findsNothing);
    await tapAndSettle(tester, find.text("Tide"));
    expect(find.text("FETCH"), findsOneWidget);
  });

  testWidgets("Editing shows values", (tester) async {
    controller.value = Tide(
      type: TideType.outgoing,
      firstLowTimestamp: Int64(1626937200000),
      firstHighTimestamp: Int64(1626973200000),
    );
    await tester.pumpWidget(
      Testable(
        (_) => TideInput(
          controller: controller,
          dateTime: now(),
        ),
      ),
    );
    await tapAndSettle(tester, find.text("Tide"));

    expect(find.text("3:00 AM"), findsOneWidget);
    expect(find.text("1:00 PM"), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(Row, "Outgoing"),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
      findsOneWidget,
    );
  });

  testWidgets("Editing updates controller", (tester) async {
    controller.value = Tide(
      type: TideType.outgoing,
      firstLowTimestamp: Int64(1624348800000),
      firstHighTimestamp: Int64(1624381200000),
    );

    await tester.pumpWidget(
      Testable(
        (_) => TideInput(
          controller: controller,
          dateTime: now(),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Tide"));
    await tapAndSettle(tester, find.text("High"));

    await tapAndSettle(tester, find.text("Time of First Low Tide"));
    await tapAndSettle(tester, find.text("AM"));
    var center = tester
        .getCenter(find.byKey(const ValueKey<String>("time-picker-dial")));
    await tester.tapAt(Offset(center.dx - 10, center.dy));
    await tapAndSettle(tester, find.text("OK"));

    await tapAndSettle(tester, find.text("Time of First High Tide"));
    await tapAndSettle(tester, find.text("PM"));
    await tester.tapAt(Offset(center.dx + 10, center.dy));
    await tapAndSettle(tester, find.text("OK"));

    expect(controller.value!.type, TideType.high);
    expect(controller.value!.firstLowTimestamp.toInt(), 1624366800000);
    expect(controller.value!.firstHighTimestamp.toInt(), 1624388400000);
    expect(controller.value!.isFrozen, isFalse);
  });
}
