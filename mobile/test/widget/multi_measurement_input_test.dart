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

  testWidgets("Round initial double mainValue with decimal system",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.weight(context);
          var controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.feet,
              value: 12.3,
            ),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
          );
        },
        appManager: appManager,
      ),
    );

    expect(find.text("12.3"), findsOneWidget);
  });

  testWidgets("Round initial double mainValue with whole system",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.weight(context);
          var controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.feet,
              value: 12.3,
            ),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
          );
        },
        appManager: appManager,
      ),
    );

    expect(find.text("12"), findsOneWidget);
  });

  testWidgets("Round initial double mainValue when whole", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.weight(context);
          var controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.feet,
              value: 12.0,
            ),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
          );
        },
        appManager: appManager,
      ),
    );

    expect(find.text("12"), findsOneWidget);
  });

  testWidgets("Round initial double fractionValue with whole system",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.weight(context);
          var controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            fractionValue: Measurement(
              unit: Unit.feet,
              value: 12.0,
            ),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
          );
        },
        appManager: appManager,
      ),
    );

    expect(find.text("12"), findsOneWidget);
  });

  testWidgets("Imperial 'main' text field doesn't show units for inches",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.length(context);
          var controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.inches,
              value: 12.0,
            ),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
          );
        },
        appManager: appManager,
      ),
    );

    expect(findFirst<TextInput>(tester).suffixText, isNull);
    expect(find.text("in"), findsOneWidget);
  });

  testWidgets("Imperial 'main' text field shows imperial unit", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.waterDepth(context);
          var controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(
              unit: Unit.feet,
              value: 12.0,
            ),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
          );
        },
        appManager: appManager,
      ),
    );

    expect(findFirst<TextInput>(tester).suffixText, "ft");
  });

  testWidgets("Imperial 'main' text field shows metric unit", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.waterDepth(context);
          var controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(
              unit: Unit.meters,
              value: 12.0,
            ),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
          );
        },
        appManager: appManager,
      ),
    );

    expect(findFirst<TextInput>(tester).suffixText, "m");
  });

  testWidgets("'main' text field notifies when changed", (tester) async {
    var called = false;
    late MultiMeasurementInputController controller;
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.waterDepth(context);
          controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.meters),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
            onChanged: () => called = true,
          );
        },
        appManager: appManager,
      ),
    );

    await enterTextAndSettle(tester, find.byType(TextInput), "12");

    expect(called, isTrue);
    expect(controller.value!.mainValue.value, 12);
  });

  testWidgets("Fraction text field notifies when changed", (tester) async {
    var called = false;
    late MultiMeasurementInputController controller;
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.waterDepth(context);
          controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(unit: Unit.meters),
            fractionValue: Measurement(unit: Unit.ounces),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
            onChanged: () => called = true,
          );
        },
        appManager: appManager,
      ),
    );

    await enterTextAndSettle(tester, find.byType(TextInput).first, "12");
    await enterTextAndSettle(tester, find.byType(TextInput).last, "8");

    expect(called, isTrue);
    expect(controller.value!.fractionValue.value, 8);
  });

  testWidgets("Inches selector notifies when changed", (tester) async {
    var called = false;
    late MultiMeasurementInputController controller;
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.length(context);
          controller = spec.newInputController();
          controller.value = MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(unit: Unit.inches),
          );

          return MultiMeasurementInput(
            spec: spec,
            controller: controller,
            onChanged: () => called = true,
          );
        },
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

  testWidgets("Custom title", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.length(context);
          return MultiMeasurementInput(
            spec: spec,
            controller: spec.newInputController(),
            onChanged: () {},
            title: "Custom Title",
          );
        },
        appManager: appManager,
      ),
    );

    expect(find.text("Custom Title"), findsOneWidget);
  });

  testWidgets("Spec title", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.length(context);
          return MultiMeasurementInput(
            spec: spec,
            controller: spec.newInputController(),
            onChanged: () {},
          );
        },
        appManager: appManager,
      ),
    );

    expect(find.text("Length"), findsOneWidget);
  });

  testWidgets("newInputController sets mainUnit", (tester) async {
    var context = await buildContext(tester, appManager: appManager);

    var spec = MultiMeasurementInputSpec.airHumidity(context);
    var controller = spec.newInputController();
    expect(controller.system, MeasurementSystem.imperial_whole);

    spec = MultiMeasurementInputSpec.waterTemperature(context);
    controller = spec.newInputController();
    expect(controller.system, MeasurementSystem.metric);

    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    spec = MultiMeasurementInputSpec.waterTemperature(context);
    controller = spec.newInputController();
    expect(controller.system, MeasurementSystem.imperial_whole);

    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
    spec = MultiMeasurementInputSpec.waterTemperature(context);
    controller = spec.newInputController();
    expect(controller.system, MeasurementSystem.imperial_decimal);
  });
}
