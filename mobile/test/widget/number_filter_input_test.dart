import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/multi_measurement_input.dart';
import 'package:mobile/widgets/number_filter_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  testWidgets("Any is pre-selected", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: NumberFilterInputController(),
        ),
      ),
    );
    expect(find.text("Filter"), findsOneWidget);
    expect(find.text("Any"), findsOneWidget);
  });

  testWidgets("Picker page is shown when tapped", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: NumberFilterInputController(),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Any"));
    expect(find.text("Filter Title"), findsOneWidget);

    await tapAndSettle(tester, find.byType(BackButton));
    expect(find.text("Filter Title"), findsNothing);
  });

  testWidgets("From field is required", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: NumberFilterInputController(),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Any"));
    await tapAndSettle(tester, find.text("Greater than (>)"));

    expect(find.text("Required"), findsOneWidget);
  });

  testWidgets("To field is required", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: NumberFilterInputController(),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Any"));
    await tapAndSettle(tester, find.text("Range"));

    expect(find.text("Required"), findsNWidgets(2));
  });

  testWidgets("Initial boundary set", (tester) async {
    var controller = NumberFilterInputController();
    controller.value = NumberFilter(
      boundary: NumberBoundary.range,
      from: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 30,
        ),
      ),
      to: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 60,
        ),
      ),
    );

    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: controller,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));

    expect(
      siblingOfText(
          tester, Row, "Range", find.byIcon(Icons.radio_button_checked)),
      findsOneWidget,
    );
    expect(find.text("30"), findsOneWidget);
    expect(find.text("60"), findsOneWidget);
  });

  testWidgets("Controller updated when boundary changes", (tester) async {
    var controller = NumberFilterInputController();

    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: controller,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Less than (<)"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "Value"), "10");

    expect(controller.hasValue, isTrue);
    expect(controller.value!.boundary, NumberBoundary.less_than);
    expect(controller.value!.from.mainValue.value, 10);
  });

  testWidgets("From field label for non-range boundary", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: NumberFilterInputController(),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Less than (<)"));

    expect(find.text("Value"), findsOneWidget);
    expect(find.text("From"), findsNothing);
  });

  testWidgets("From field label for range boundary", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: NumberFilterInputController(),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Range"));

    expect(find.text("Value"), findsNothing);
    expect(find.text("From"), findsOneWidget);
    expect(find.text("To"), findsOneWidget);
  });

  testWidgets("Text fields not shown for 'any' boundary", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: NumberFilterInputController(),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    expect(find.byType(TextInput), findsNothing);
  });

  testWidgets("Normal text field shown for no units", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: NumberFilterInputController(),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Range"));

    expect(find.byType(TextInput), findsNWidgets(2));
    expect(find.byType(MultiMeasurementInput), findsNothing);
  });

  testWidgets("Normal text field updates controller on change", (tester) async {
    var controller = NumberFilterInputController();

    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: controller,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Range"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "From"), "10");
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "To"), "15");

    expect(controller.value!.from.mainValue.value, 10);
    expect(controller.value!.to.mainValue.value, 15);
  });

  testWidgets("Normal 'to' field validated when 'from' field changes",
      (tester) async {
    var controller = NumberFilterInputController();

    await tester.pumpWidget(
      Testable(
        (_) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: controller,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Range"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "From"), "10");
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "To"), "15");

    // Verify input is valid.
    expect(controller.value!.from.mainValue.value, 10);
    expect(controller.value!.to.mainValue.value, 15);

    // Enter an invalid input into the "from" field.
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "From"), "20");

    // Verify controller did not update.
    expect(controller.value!.from.mainValue.value, 10);
    expect(controller.value!.to.mainValue.value, 15);

    // Verify validation message is shown.
    expect(find.text("Must be greater than 20"), findsOneWidget);
  });

  testWidgets("Unit text field shown for units", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: NumberFilterInputController(),
          inputSpec: MultiMeasurementInputSpec.waterDepth(context),
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Range"));

    expect(find.byType(MultiMeasurementInput), findsNWidgets(2));
  });

  testWidgets("Unit text field updates controller on change", (tester) async {
    var controller = NumberFilterInputController();

    await tester.pumpWidget(
      Testable(
        (context) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: controller,
          inputSpec: MultiMeasurementInputSpec.waterDepth(context),
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Range"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "From"), "10");
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "To"), "15");

    expect(controller.value!.from.mainValue.value, 10);
    expect(controller.value!.to.mainValue.value, 15);
  });

  testWidgets("Unit 'to' field validated when 'from' field changes",
      (tester) async {
    var controller = NumberFilterInputController();

    await tester.pumpWidget(
      Testable(
        (context) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: controller,
          inputSpec: MultiMeasurementInputSpec.waterDepth(context),
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Range"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "From"), "10");
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "To"), "15");

    // Verify input is valid.
    expect(controller.value!.from.mainValue.value, 10);
    expect(controller.value!.to.mainValue.value, 15);

    // Enter an invalid input into the "from" field.
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "From"), "20");

    // Verify controller did not update.
    expect(controller.value!.from.mainValue.value, 10);
    expect(controller.value!.to.mainValue.value, 15);

    // Verify validation message is shown.
    expect(find.text("Must be greater than 20 m"), findsOneWidget);
  });

  testWidgets("Unit 'to' field validated when when changed", (tester) async {
    var controller = NumberFilterInputController();

    await tester.pumpWidget(
      Testable(
        (context) => NumberFilterInput(
          filterTitle: "Filter Title",
          title: "Filter",
          controller: controller,
          inputSpec: MultiMeasurementInputSpec.waterDepth(context),
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.text("Filter"));
    await tapAndSettle(tester, find.text("Range"));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextInput, "From"), "10");
    await enterTextAndSettle(tester, find.widgetWithText(TextInput, "To"), "5");

    // Verify validation message is shown.
    expect(find.text("Must be greater than 10 m"), findsOneWidget);
  });
}
