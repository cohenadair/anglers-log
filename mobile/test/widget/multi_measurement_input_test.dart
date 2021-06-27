import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/fraction.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/multi_measurement_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
  });

  testWidgets("System defaults to controller", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.metric,
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    // Enter text so units are shown.
    await enterTextAndSettle(tester, find.byType(TextInput), "10");
    expect(find.text("m"), findsOneWidget);
  });

  testWidgets("System defaults to spec", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: MultiMeasurementInputController(),
        ),
        appManager: appManager,
      ),
    );

    // Enter text so units are shown.
    await enterTextAndSettle(tester, find.byType(TextInput), "10");

    expect(find.text("m"), findsOneWidget);
  });

  testWidgets("System defaults to imperial_whole", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState(
            imperialMainUnit: Unit.feet,
            metricUnit: Unit.meters,
          ),
          controller: MultiMeasurementInputController(),
        ),
        appManager: appManager,
      ),
    );

    // Enter text so units are shown.
    await enterTextAndSettle(tester, find.byType(TextInput).first, "10");

    expect(find.text("ft"), findsOneWidget);
  });

  testWidgets("Initial values", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.pounds,
        value: 10,
      ),
      fractionValue: Measurement(
        unit: Unit.ounces,
        value: 8,
      ),
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.weight(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("10"), findsOneWidget);
    expect(find.text("8"), findsOneWidget);
    expect(find.text("lbs"), findsOneWidget);
    expect(find.text("oz"), findsOneWidget);
  });

  testWidgets("No initial values", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
    );

    var mainController = NumberInputController();
    var fractionController = NumberInputController();

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.weight(context),
          controller: controller,
          mainController: mainController,
          fractionController: fractionController,
        ),
        appManager: appManager,
      ),
    );

    expect(mainController.hasValue, isFalse);
    expect(fractionController.hasValue, isFalse);
    expect(find.text("lbs"), findsOneWidget);
    expect(find.text("oz"), findsOneWidget);
  });

  testWidgets("Round initial double mainValue with decimal system",
      (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_decimal,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 12.3,
      ),
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.weight(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("12.3"), findsOneWidget);
  });

  testWidgets("Round initial double mainValue with whole system",
      (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 12.3,
      ),
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.weight(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("12"), findsOneWidget);
  });

  testWidgets("Round initial double mainValue when whole", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 12.0,
      ),
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.weight(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("12"), findsOneWidget);
  });

  testWidgets("Round initial double fractionValue with whole system",
      (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      fractionValue: Measurement(
        unit: Unit.feet,
        value: 12.3,
      ),
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.weight(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("12"), findsOneWidget);
  });

  testWidgets("Round initial double fractionValue when whole", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      fractionValue: Measurement(
        unit: Unit.feet,
        value: 12.0,
      ),
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.weight(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("12"), findsOneWidget);
  });

  testWidgets("didUpdateWidget updates system", (tester) async {
    // Can't test didUpdateWidget behaviour in this test. It is tested in
    // number_filter_input_test.dart.
  });

  testWidgets("Imperial 'main' text field doesn't show units for inches",
      (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.inches,
        value: 12.0,
      ),
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.length(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    expect(findFirst<TextInput>(tester).suffixText, isNull);
    expect(find.text("in"), findsOneWidget);
  });

  testWidgets("Imperial 'main' text field shows imperial unit", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 12.0,
      ),
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    expect(findFirst<TextInput>(tester).suffixText, "ft");
  });

  testWidgets("Imperial 'main' text field shows metric unit", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(
        unit: Unit.meters,
        value: 12.0,
      ),
    );

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: controller,
        ),
        appManager: appManager,
      ),
    );

    expect(findFirst<TextInput>(tester).suffixText, "m");
  });

  testWidgets("'main' text field notifies when changed", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(unit: Unit.meters),
    );

    var called = false;
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: controller,
          onChanged: () => called = true,
        ),
        appManager: appManager,
      ),
    );

    await enterTextAndSettle(tester, find.byType(TextInput), "12");

    expect(called, isTrue);
    expect(controller.value!.mainValue.value, 12);
  });

  testWidgets("Fraction type 'none' doesn't show input field", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterTemperature(context),
          controller: MultiMeasurementInputController(),
        ),
        appManager: appManager,
      ),
    );

    expect(find.byType(TextInput), findsOneWidget);
  });

  testWidgets("Fraction type 'textField' shows text field", (tester) async {
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: MultiMeasurementInputController(),
        ),
        appManager: appManager,
      ),
    );

    expect(find.byType(TextInput), findsNWidgets(2));
  });

  testWidgets("Fraction type 'inches' shows selector and unit", (tester) async {
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);

    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.length(context),
          controller: MultiMeasurementInputController(),
        ),
        appManager: appManager,
      ),
    );

    expect(find.byType(TextInput), findsOneWidget);
    expect(find.byType(typeOf<DropdownButton<Fraction>>()), findsOneWidget);
  });

  testWidgets("Fraction text field notifies when changed", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(unit: Unit.pounds),
      fractionValue: Measurement(unit: Unit.ounces),
    );

    var called = false;
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: controller,
          onChanged: () => called = true,
        ),
        appManager: appManager,
      ),
    );

    await enterTextAndSettle(tester, find.byType(TextInput).first, "12");
    await enterTextAndSettle(tester, find.byType(TextInput).last, "8");

    expect(called, isTrue);
    expect(controller.value!.fractionValue.value, 8);
  });

  testWidgets("Inches selector notifies when changed", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(unit: Unit.inches),
    );

    var called = false;
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.length(context),
          controller: controller,
          onChanged: () => called = true,
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.byType(typeOf<DropdownButton<Fraction>>()));
    await tapAndSettle(
      tester,
      find.widgetWithText(typeOf<DropdownMenuItem<Fraction>>(), "\u00BD").last,
    );

    expect(called, isTrue);
    expect(find.text("\u00BD"), findsOneWidget);
    expect(controller.value!.fractionValue.value, 0.5);
  });

  testWidgets("Changing system to imperial whole", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(
        unit: Unit.meters,
        value: 10,
      ),
    );

    var called = false;
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: controller,
          onChanged: () => called = true,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("m"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.more_vert));
    await tapAndSettle(tester, find.text("Imperial"));

    expect(called, isTrue);
    expect(find.text("m"), findsNothing);
    expect(find.text("ft"), findsOneWidget);
  });

  testWidgets("Changing system to imperial decimal", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 10,
      ),
      fractionValue: Measurement(
        unit: Unit.inches,
        value: 8,
      ),
    );

    var called = false;
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: controller,
          onChanged: () => called = true,
        ),
        appManager: appManager,
      ),
    );

    expect(find.byType(TextInput), findsNWidgets(2));
    expect(find.text("in"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.more_vert));
    await tapAndSettle(tester, find.text("Imperial Decimal"));

    expect(called, isTrue);
    expect(find.text("ft"), findsOneWidget);
    expect(find.text("in"), findsNothing);
    expect(find.byType(TextInput), findsOneWidget);
  });

  testWidgets("Changing system to metric", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 10,
      ),
      fractionValue: Measurement(
        unit: Unit.inches,
        value: 8,
      ),
    );

    var called = false;
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: controller,
          onChanged: () => called = true,
        ),
        appManager: appManager,
      ),
    );

    expect(find.byType(TextInput), findsNWidgets(2));
    expect(find.text("in"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.more_vert));
    await tapAndSettle(tester, find.text("Metric"));

    expect(called, isTrue);
    expect(find.text("ft"), findsNothing);
    expect(find.text("in"), findsNothing);
    expect(find.text("m"), findsOneWidget);
    expect(find.byType(TextInput), findsOneWidget);
  });

  testWidgets("Changing to imperial whole rounds values", (tester) async {
    var controller = MultiMeasurementInputController();
    controller.value = MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(
        unit: Unit.meters,
        value: 10.6,
      ),
    );

    var called = false;
    await tester.pumpWidget(
      Testable(
        (context) => MultiMeasurementInput(
          state: MultiMeasurementInputState.waterDepth(context),
          controller: controller,
          onChanged: () => called = true,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("m"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.more_vert));
    await tapAndSettle(tester, find.text("Imperial"));

    expect(called, isTrue);
    expect(find.text("m"), findsNothing);
    expect(find.text("ft"), findsOneWidget);
    expect(find.text("11"), findsOneWidget);
  });
}
