import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  test("Use IdInputController instead of InputController<Id>", () {
    expect(() => InputController<Id>(), throwsAssertionError);
    expect(() => InputController<Set<Id>>(), throwsAssertionError);
    expect(() => InputController<List<Id>>(), throwsAssertionError);
    expect(() => InputController<MultiMeasurement>(), throwsAssertionError);
    expect(() => InputController<NumberFilter>(), throwsAssertionError);
    expect(() => InputController<bool>(), throwsAssertionError);
  });

  group("IdInputController", () {
    test("Empty uuid sets value to null", () {
      var controller = IdInputController();
      expect(controller.value, isNull);

      controller.value = Id();
      expect(controller.value, isNull);
    });

    test("Value is set if uuid is not empty", () {
      var controller = IdInputController();
      expect(controller.value, isNull);

      var id = randomId();
      controller.value = id;
      expect(controller.value, id);
    });
  });

  group("SetInputController", () {
    test("Getter returns empty Set", () {
      expect(SetInputController<Id>().value.isEmpty, isTrue);
    });

    test("Setting null sets empty Set", () {
      var controller = SetInputController<Id>();
      controller.value = null;
      expect(SetInputController<Id>().value.isEmpty, isTrue);
    });
  });

  group("ListInputController", () {
    test("Getter returns empty List", () {
      expect(ListInputController<Id>().value.isEmpty, isTrue);
    });

    test("Setting null sets empty List", () {
      var controller = ListInputController<Id>();
      controller.value = null;
      expect(ListInputController<Id>().value.isEmpty, isTrue);
    });
  });

  group("TextInputController", () {
    test("Empty value returns null", () {
      var controller = TextInputController(
        validator: NameValidator(),
      );
      expect(controller.value, isNull);
    });

    test("Value is trimmed of trailing and leading whitespace", () {
      var controller = TextInputController(
        validator: NameValidator(),
      );
      controller.value = " Whitespace String ";
      expect(controller.value, "Whitespace String");
    });

    test("Initial value is trimmed of trailing and leading whitespace", () {
      var controller = TextInputController(
        editingController: TextEditingController(
          text: " Test with whitespace ",
        ),
        validator: NameValidator(),
      );
      expect(controller.value, "Test with whitespace");
    });

    testWidgets("Null validator", (tester) async {
      var context = await buildContext(tester);
      var controller = TextInputController();
      expect(controller.isValid(context), isTrue);
    });

    testWidgets("Non-null validator", (tester) async {
      var context = await buildContext(tester);
      var validator = MockNameValidator();
      when(validator.run(context, any)).thenReturn((context) => null);
      var controller = TextInputController(validator: validator);
      expect(controller.isValid(context), isTrue);
    });
  });

  group("TimestampInputController", () {
    test("Null input", () {
      var controller =
          TimestampInputController(StubbedAppManager().timeManager);
      expect(controller.date, isNotNull);
      expect(controller.time, isNotNull);
    });

    test("Non-null input", () {
      var controller = TimestampInputController(
        StubbedAppManager().timeManager,
        date: DateTime(2020, 1, 15),
        time: TimeOfDay(hour: 15, minute: 30),
      );
      expect(controller.value,
          DateTime(2020, 1, 15, 15, 30).millisecondsSinceEpoch);
    });

    test("Set to non-null", () {
      var controller =
          TimestampInputController(StubbedAppManager().timeManager);
      var timestamp = DateTime(2020, 1, 15, 15, 30).millisecondsSinceEpoch;
      controller.value = timestamp;
      expect(controller.value, timestamp);
    });

    test("Set to null", () {
      var controller =
          TimestampInputController(StubbedAppManager().timeManager);
      controller.value = null;
      expect(controller.value, isNotNull);
    });
  });

  group("NumberFilterInputController", () {
    test("isSet", () {
      var controller = NumberFilterInputController();

      // No value.
      controller.value = NumberFilter();
      expect(controller.isSet, isFalse);

      // No boundary.
      controller.value = NumberFilter(
        from: MultiMeasurement(mainValue: Measurement(value: 10)),
      );
      expect(controller.isSet, isFalse);

      // Boundary.
      controller.value = NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(mainValue: Measurement(value: 10)),
      );
      expect(controller.isSet, isTrue);
    });

    test("shouldAddToReport", () {
      // Not set.
      var controller = NumberFilterInputController();
      controller.value = NumberFilter();
      expect(controller.shouldAddToReport, isFalse);

      // Any boundary.
      controller.value = NumberFilter(
        boundary: NumberBoundary.number_boundary_any,
        from: MultiMeasurement(mainValue: Measurement(value: 10)),
      );
      expect(controller.shouldAddToReport, isFalse);

      // Non-any boundary.
      controller.value = NumberFilter(
        boundary: NumberBoundary.greater_than,
        from: MultiMeasurement(mainValue: Measurement(value: 10)),
      );
      expect(controller.shouldAddToReport, isTrue);
    });
  });

  group("MultiMeasurementInputController", () {
    test("Setting value to null", () {
      var controller = MultiMeasurementInputController(
        mainUnit: Unit.kilometers,
      );
      controller.mainController.intValue = 50;
      controller.fractionController.intValue = 60;

      expect(controller.value, isNotNull);
      expect(controller.value, MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.kilometers,
          value: 50,
        ),
        fractionValue: Measurement(
          value: 60,
        ),
      ));

      controller.value = null;
      expect(controller.mainController.hasValue, isFalse);
      expect(controller.fractionController.hasValue, isFalse);
      expect(controller.hasValue, isFalse);
    });

    test("Setting value updates controllers", () {
      var controller = MultiMeasurementInputController(
        mainUnit: Unit.kilometers,
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          value: 50,
        ),
        fractionValue: Measurement(
          value: 60,
        ),
      );

      expect(controller.mainController.hasIntValue, isTrue);
      expect(controller.mainController.intValue, 50);
      expect(controller.fractionController.hasDoubleValue, isTrue);
      expect(controller.fractionController.doubleValue, 60);
    });

    test("Setting value without a main value", () {
      var controller = MultiMeasurementInputController(
        mainUnit: Unit.kilometers,
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        fractionValue: Measurement(
          unit: Unit.meters,
          value: 60,
        ),
      );

      expect(controller.value, isNotNull);
      expect(controller.value!.hasMainValue(), isFalse);
      expect(controller.value!.hasFractionValue(), isTrue);
      expect(controller.value!.fractionValue.unit, Unit.meters);
      expect(controller.value!.fractionValue.value, 60);
    });

    test("Setting value without a fraction value", () {
      var controller = MultiMeasurementInputController(
        mainUnit: Unit.kilometers,
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          value: 60,
        ),
      );

      expect(controller.value, isNotNull);
      expect(controller.value!.hasMainValue(), isTrue);
      expect(controller.value!.hasFractionValue(), isFalse);
    });

    test("Setting value without a fraction unit", () {
      var controller = MultiMeasurementInputController(
        mainUnit: Unit.kilometers,
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        fractionValue: Measurement(
          value: 60,
        ),
      );

      expect(controller.value, isNotNull);
      expect(controller.value!.hasMainValue(), isFalse);
      expect(controller.value!.hasFractionValue(), isTrue);
      expect(controller.value!.fractionValue.hasUnit(), isFalse);
      expect(controller.value!.fractionValue.value, 60);
    });

    test("Setting system round values", () {
      var controller = MultiMeasurementInputController(
        mainUnit: Unit.kilometers,
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_decimal,
        mainValue: Measurement(
          value: 60.256485,
        ),
      );

      controller.system = MeasurementSystem.metric;

      expect(controller.value, isNotNull);
      expect(controller.value!.mainValue.value, 60.3);
    });

    test("Rounding", () {
      var controller = MultiMeasurementInputController(
        mainUnit: Unit.kilometers,
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        // Rounded to 60.0.
        mainValue: Measurement(
          value: 60.256485,
        ),
        // Not rounded.
        fractionValue: Measurement(
          value: 0.75,
        ),
      );

      expect(controller.value, isNotNull);
      expect(controller.value!.mainValue.value, 60);
      expect(controller.value!.fractionValue.value, 0.75);

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        // Not rounded.
        fractionValue: Measurement(
          unit: Unit.inches,
          value: 10.75,
        ),
      );

      expect(controller.value!.fractionValue.value, 10.75);

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        // Rounded to 10.8.
        fractionValue: Measurement(
          unit: Unit.kilometers,
          value: 10.75,
        ),
      );

      expect(controller.value!.fractionValue.value, 10.8);
    });

    test("isSet", () {
      var controller = MultiMeasurementInputController(
        mainUnit: Unit.kilometers,
      );
      expect(controller.isSet, isFalse);

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        fractionValue: Measurement(
          unit: Unit.kilometers,
          value: 10.75,
        ),
      );

      expect(controller.isSet, isTrue);
    });
  });
}
