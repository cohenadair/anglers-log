import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/fraction.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/widgets/chip_list.dart';
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
    when(appManager.userPreferenceManager.airPressureImperialUnit)
        .thenReturn(Unit.inch_of_mercury);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
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
    expect(controller.value.mainValue.value, 12);
  });

  testWidgets("'main' input allows decimal for metric", (tester) async {
    await pumpContext(
      tester,
      (context) {
        var spec = MultiMeasurementInputSpec.airPressure(context);
        var controller = spec.newInputController();
        controller.value = MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(unit: Unit.millibars),
        );

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
        );
      },
      appManager: appManager,
    );

    expect(
      findFirstWithText<TextInput>(tester, "Atmospheric Pressure")
          .keyboardType
          ?.decimal,
      isTrue,
    );
  });

  testWidgets("'main' input allows decimal for imperial decimal",
      (tester) async {
    await pumpContext(
      tester,
      (context) {
        var spec = MultiMeasurementInputSpec.weight(context);
        var controller = spec.newInputController();
        controller.value = MultiMeasurement(
          system: MeasurementSystem.imperial_decimal,
          mainValue: Measurement(unit: Unit.pounds),
        );

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
        );
      },
      appManager: appManager,
    );

    expect(
      findFirstWithText<TextInput>(tester, "Weight").keyboardType?.decimal,
      isTrue,
    );
  });

  testWidgets("'main' input allows decimal for inch of mercury",
      (tester) async {
    await pumpContext(
      tester,
      (context) {
        var spec = MultiMeasurementInputSpec.airPressure(context);
        var controller = spec.newInputController();
        controller.value = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.inch_of_mercury),
        );

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
        );
      },
      appManager: appManager,
    );

    expect(
      findFirstWithText<TextInput>(tester, "Atmospheric Pressure")
          .keyboardType
          ?.decimal,
      isTrue,
    );
  });

  testWidgets("'main' input doesn't allow decimals", (tester) async {
    await pumpContext(
      tester,
      (context) {
        var spec = MultiMeasurementInputSpec.weight(context);
        var controller = spec.newInputController();
        controller.value = MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(unit: Unit.pounds),
            fractionValue: Measurement(unit: Unit.ounces));

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
        );
      },
      appManager: appManager,
    );

    expect(
      findFirstWithText<TextInput>(tester, "Weight").keyboardType?.decimal,
      isFalse,
    );
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
    expect(controller.value.fractionValue.value, 8);
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
    expect(controller.value.fractionValue.value, 0.5);
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

  testWidgets("Water depth MultiMeasurementInputSpec custom title",
      (tester) async {
    var context = await buildContext(tester, appManager: appManager);
    expect(
      MultiMeasurementInputSpec.waterDepth(context, title: "Test")
          .title!(context),
      "Test",
    );
    expect(
      MultiMeasurementInputSpec.waterDepth(context).title!(context),
      "Water Depth",
    );
  });

  testWidgets("Conversion chips hidden for same system", (tester) async {
    late MultiMeasurementInputSpec spec;
    late MultiMeasurementInputController controller;
    await pumpContext(
      tester,
      (context) {
        spec = MultiMeasurementInputSpec.length(context);
        controller = spec.newInputController();
        controller.value = MultiMeasurement(
          system: spec.system?.call(context),
          mainValue: Measurement(
            unit: Unit.centimeters,
            value: 50,
          ),
        );

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
        );
      },
      appManager: appManager,
    );
    expect(find.byType(ChipList), findsNothing);
  });

  testWidgets("Conversion chips hidden for null spec system", (tester) async {
    late MultiMeasurementInputSpec spec;
    late MultiMeasurementInputController controller;
    await pumpContext(
      tester,
      (context) {
        spec = MultiMeasurementInputSpec.airHumidity(context);
        controller = spec.newInputController();
        controller.value = MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.percent,
            value: 50,
          ),
        );

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
        );
      },
      appManager: appManager,
    );
    expect(find.byType(ChipList), findsNothing);
  });

  testWidgets("Conversion chips hidden for different system and no input",
      (tester) async {
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);

    late MultiMeasurementInputSpec spec;
    late MultiMeasurementInputController controller;
    await pumpContext(
      tester,
      (context) {
        spec = MultiMeasurementInputSpec.length(context);
        controller = spec.newInputController();

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
        );
      },
      appManager: appManager,
    );
    expect(find.byType(ChipList), findsNothing);
  });

  testWidgets("Conversion metric to imperial", (tester) async {
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.imperial_whole);

    var invoked = false;
    late MultiMeasurementInputSpec spec;
    late MultiMeasurementInputController controller;
    await pumpContext(
      tester,
      (context) {
        spec = MultiMeasurementInputSpec.windSpeed(context);
        controller = spec.newInputController();
        controller.value = MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilometers_per_hour,
            value: 5,
          ),
        );

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
          onChanged: () => invoked = true,
        );
      },
      appManager: appManager,
    );

    expect(find.byType(ChipList), findsOneWidget);
    expect(find.text("Convert to 3 mph"), findsOneWidget);
    expect(find.text("Convert to 5 mph"), findsOneWidget);

    await tapAndSettle(tester, find.text("Convert to 3 mph"));
    expect(invoked, isTrue);
    expect(find.byType(ChipList), findsNothing);
  });

  testWidgets("Conversion imperial to metric", (tester) async {
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);

    var invoked = false;
    late MultiMeasurementInputSpec spec;
    late MultiMeasurementInputController controller;
    await pumpContext(
      tester,
      (context) {
        spec = MultiMeasurementInputSpec.windSpeed(context);
        controller = spec.newInputController();
        controller.value = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.miles_per_hour,
            value: 3,
          ),
        );

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
          onChanged: () => invoked = true,
        );
      },
      appManager: appManager,
    );

    expect(find.byType(ChipList), findsOneWidget);
    expect(find.text("Convert to 5 km/h"), findsOneWidget);
    expect(find.text("Convert to 3 km/h"), findsOneWidget);

    await tapAndSettle(tester, find.text("Convert to 5 km/h"));
    expect(invoked, isTrue);
    expect(find.byType(ChipList), findsNothing);
  });

  testWidgets("Conversion includes fraction value", (tester) async {
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);

    late MultiMeasurementInputSpec spec;
    late MultiMeasurementInputController controller;
    await pumpContext(
      tester,
      (context) {
        spec = MultiMeasurementInputSpec.waterDepth(context);
        controller = spec.newInputController();
        controller.value = MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 50,
          ),
        );

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
          onChanged: () {},
        );
      },
      appManager: appManager,
    );

    expect(find.byType(ChipList), findsOneWidget);
    expect(find.text("Convert to 164 ft 1 in"), findsOneWidget);
    expect(find.text("Convert to 50 ft"), findsOneWidget);
  });

  testWidgets("Conversion drops fraction value", (tester) async {
    when(appManager.userPreferenceManager.minGpsTrailDistance)
        .thenReturn(MultiMeasurement(
      system: MeasurementSystem.imperial_whole,
      mainValue: Measurement(
        unit: Unit.feet,
        value: 150,
      ),
    ));

    late MultiMeasurementInputSpec spec;
    late MultiMeasurementInputController controller;
    await pumpContext(
      tester,
      (context) {
        spec = MultiMeasurementInputSpec.minGpsTrailDistance(context);
        controller = spec.newInputController();
        controller.value = MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.meters,
            value: 50,
          ),
        );

        return MultiMeasurementInput(
          spec: spec,
          controller: controller,
          onChanged: () {},
        );
      },
      appManager: appManager,
    );

    expect(find.byType(ChipList), findsOneWidget);
    expect(find.text("Convert to 164 ft"), findsOneWidget);
    expect(find.text("Convert to 50 ft"), findsOneWidget);
  });

  testWidgets("mainValue returns null if there's no system", (tester) async {
    var input = MultiMeasurementInputSpec.airHumidity(await buildContext(
      tester,
      appManager: appManager,
    ));
    expect(input.mainUnit, isNull);
  });

  testWidgets("mainValue returns metric unit", (tester) async {
    when(appManager.userPreferenceManager.tideHeightSystem)
        .thenReturn(MeasurementSystem.metric);
    var input = MultiMeasurementInputSpec.tideHeight(await buildContext(
      tester,
      appManager: appManager,
    ));
    expect(input.mainUnit, Unit.meters);
  });

  testWidgets("mainValue returns imperial unit", (tester) async {
    when(appManager.userPreferenceManager.tideHeightSystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
    var input = MultiMeasurementInputSpec.tideHeight(await buildContext(
      tester,
      appManager: appManager,
    ));
    expect(input.mainUnit, Unit.feet);
  });

  testWidgets("Units dropdown is shown", (tester) async {
    var called = false;
    late MultiMeasurementInputController controller;
    await tester.pumpWidget(
      Testable(
        (context) {
          var spec = MultiMeasurementInputSpec.leaderRating(context);
          controller = spec.newInputController();
          controller.value = MultiMeasurement(
            mainValue: Measurement(
              unit: Unit.pound_test,
              value: 10,
            ),
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

    // Verify initial value.
    expect(find.text("10"), findsOneWidget);
    expect(find.text("lb test"), findsOneWidget);

    // Change value and units.
    await enterTextAndSettle(tester, find.byType(TextInput).first, "12");
    await tapAndSettle(tester, find.text("lb test"));
    expect(find.text("X"), findsOneWidget);

    await tapAndSettle(tester, find.text("X"));

    expect(called, isTrue);
    expect(controller.value.mainValue.value, 12);
    expect(controller.value.mainValue.unit, Unit.x);
  });
}
