import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("Title/value can't both be empty", (tester) async {
    await tester.pumpWidget(Testable((_) => ListPickerInput()));
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets("If title is empty, value is used as title", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => ListPickerInput(value: "Value"),
    );

    expect(find.secondaryText(context, text: "Value"), findsNothing);
    expect(find.byType(SizedBox), findsNWidgets(2));
  });

  testWidgets("Empty value renders not selected message", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => ListPickerInput(title: "Title"),
    );

    expect(find.secondaryText(context, text: "Not Selected"), findsOneWidget);
  });

  testWidgets("withSinglePickerPage shows picker", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) => ListPickerInput.withSinglePickerPage<Period>(
          context: context,
          controller: InputController<Period>(),
          title: "Title",
          pickerTitle: "Picker Title",
          valueDisplayName: "Value",
          noneItem: Period.period_none,
          itemBuilder: Periods.pickerItems,
          onPicked: (_) {},
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(ListPickerInput));

    expect(find.byType(typeOf<PickerPage<Period>>()), findsOneWidget);
  });

  testWidgets("withSinglePickerPage shows controller value", (tester) async {
    var controller = InputController<Period>();
    controller.value = Period.afternoon;

    await tester.pumpWidget(
      Testable(
        (context) => ListPickerInput.withSinglePickerPage<Period>(
          context: context,
          controller: controller,
          title: "Title",
          pickerTitle: "Picker Title",
          valueDisplayName: "Value",
          noneItem: Period.period_none,
          itemBuilder: Periods.pickerItems,
          onPicked: (_) {},
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(ListPickerInput));

    expect(find.byType(typeOf<PickerPage<Period>>()), findsOneWidget);
    expect(
      siblingOfText(tester, ListItem, "Afternoon", find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });

  testWidgets("withSinglePickerPage shows none with controller has no value", (
    tester,
  ) async {
    await tester.pumpWidget(
      Testable(
        (context) => ListPickerInput.withSinglePickerPage<Period>(
          context: context,
          controller: InputController<Period>(),
          title: "Title",
          pickerTitle: "Picker Title",
          valueDisplayName: "Value",
          noneItem: Period.period_none,
          itemBuilder: Periods.pickerItems,
          onPicked: (_) {},
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(ListPickerInput));

    expect(find.byType(typeOf<PickerPage<Period>>()), findsOneWidget);
    expect(
      siblingOfText(tester, ListItem, "None", find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });

  testWidgets("withSinglePickerPage selecting 'None' pops page", (
    tester,
  ) async {
    Period? picked;

    await tester.pumpWidget(
      Testable(
        (context) => ListPickerInput.withSinglePickerPage<Period>(
          context: context,
          controller: InputController<Period>(),
          title: "Title",
          pickerTitle: "Picker Title",
          valueDisplayName: "Value",
          noneItem: Period.period_none,
          itemBuilder: Periods.pickerItems,
          onPicked: (period) => picked = period,
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(ListPickerInput));
    await tapAndSettle(tester, find.text("None"));

    expect(picked, isNull);
  });

  testWidgets("withSinglePickerPage selecting pops page", (tester) async {
    Period? picked;

    await tester.pumpWidget(
      Testable(
        (context) => ListPickerInput.withSinglePickerPage<Period>(
          context: context,
          controller: InputController<Period>(),
          title: "Title",
          pickerTitle: "Picker Title",
          valueDisplayName: "Value",
          noneItem: Period.period_none,
          itemBuilder: Periods.pickerItems,
          onPicked: (period) => picked = period,
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(ListPickerInput));
    await tapAndSettle(tester, find.text("Afternoon"));

    expect(picked, isNotNull);
    expect(picked, Period.afternoon);
  });

  testWidgets("placeholderText is shown", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => ListPickerInput(title: "Title", placeholderText: "Placeholder"),
    );

    expect(find.secondaryText(context, text: "Not Selected"), findsNothing);
    expect(find.secondaryText(context, text: "Placeholder"), findsOneWidget);
  });
}
