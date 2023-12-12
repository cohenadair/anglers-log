import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/multi_measurement_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
  });

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
    test(
      "Use ImagesInputController instead of ListInputController<PickedImage>",
      () {
        expect(() => ListInputController<PickedImage>(), throwsAssertionError);
      },
    );

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

  group("DateTimeInputController", () {
    testWidgets("Null input", (tester) async {
      var controller = DateTimeInputController(
        await buildContext(tester),
        value: null,
      );
      expect(controller.date, isNull);
      expect(controller.time, isNull);
      expect(controller.isMidnight, isFalse);
      expect(controller.value, isNull);
      expect(controller.hasValue, isFalse);
    });

    testWidgets("Non-null input", (tester) async {
      var controller = DateTimeInputController(
        await buildContext(tester),
        value: dateTime(2020, 1, 15, 15, 30),
      );
      expect(controller.value, dateTime(2020, 1, 15, 15, 30));
    });

    testWidgets("Set to non-null", (tester) async {
      var controller = DateTimeInputController(await buildContext(tester));
      var value = dateTime(2020, 1, 15, 15, 30);
      controller.value = value;
      expect(controller.timestamp, value.millisecondsSinceEpoch);
    });

    testWidgets("Set to null", (tester) async {
      var controller = DateTimeInputController(await buildContext(tester));
      controller.value = null;
      expect(controller.value, isNull);
    });

    testWidgets("Set time zone with a null date", (tester) async {
      var controller = DateTimeInputController(await buildContext(tester));
      controller.timeZone = "America/New_York";
      expect(controller.value, isNull);
    });

    testWidgets("Set time zone with a non-null date", (tester) async {
      var controller = DateTimeInputController(
        await buildContext(tester),
        value: dateTime(2020, 1, 15, 15, 30),
      );
      expect(controller.value!.location.name, defaultTimeZone);
      controller.timeZone = "America/Chicago";
      expect(controller.value!.location.name, "America/Chicago");
    });

    testWidgets("isMidnight returns true", (tester) async {
      var controller = DateTimeInputController(
        await buildContext(tester),
        value: dateTime(2020, 1, 15, 0, 0),
      );
      expect(controller.isMidnight, isTrue);
    });

    testWidgets("isMidnight returns false", (tester) async {
      var controller = DateTimeInputController(
        await buildContext(tester),
        value: dateTime(2020, 1, 15, 0, 30),
      );
      expect(controller.isMidnight, isFalse);
    });
  });

  group("CurrentDateTimeInputController", () {
    testWidgets("Always returns non-null values", (tester) async {
      var appManager = StubbedAppManager();
      when(appManager.timeManager.currentDateTime).thenReturn(now());
      var controller = CurrentDateTimeInputController(
        await buildContext(tester, appManager: appManager),
      );
      expect(controller.date, isNotNull);
      expect(controller.time, isNotNull);
      expect(controller.value, isNotNull);
      expect(controller.timestamp, isNotNull);
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
    testWidgets("Setting value to null", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );
      controller.mainController.intValue = 50;
      controller.fractionController.intValue = 60;

      expect(controller.value, isNotNull);
      expect(
        controller.value,
        MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 50,
          ),
        ),
      );

      controller.value = null;
      expect(controller.mainController.hasValue, isFalse);
      expect(controller.fractionController.hasValue, isFalse);
      expect(controller.isSet, isFalse);
    });

    testWidgets("Setting value updates controllers and overrides system/units",
        (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 50,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 60,
        ),
      );

      expect(controller.mainController.hasIntValue, isTrue);
      expect(controller.mainController.intValue, 50);
      expect(controller.fractionController.hasDoubleValue, isTrue);
      expect(controller.fractionController.doubleValue, 60);

      var value = controller.value;
      expect(value.system, MeasurementSystem.imperial_whole);
      expect(value.mainValue.value, 50);
      expect(value.mainValue.unit, Unit.pounds);
      expect(value.fractionValue.value, 60);
      expect(value.fractionValue.unit, Unit.ounces);
    });

    testWidgets("Setting value without a main value", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        fractionValue: Measurement(
          unit: Unit.meters,
          value: 60,
        ),
      );

      expect(controller.value.hasMainValue(), isFalse);
      expect(controller.value.hasFractionValue(), isTrue);
      expect(controller.value.fractionValue.unit, Unit.meters);
      expect(controller.value.fractionValue.value, 60);
    });

    testWidgets("Setting value without a fraction value", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          value: 60,
        ),
      );

      expect(controller.value.hasMainValue(), isTrue);
      expect(controller.value.hasFractionValue(), isFalse);
    });

    testWidgets("Setting value without a main unit", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        fractionValue: Measurement(
          value: 60,
        ),
      );

      expect(controller.value.hasMainValue(), isFalse);
      expect(controller.value.hasFractionValue(), isTrue);
      expect(controller.value.fractionValue.value, 60);
    });

    testWidgets("Setting non-imperial whole value drops fraction",
        (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );
      controller.mainController.intValue = 50;
      controller.fractionController.intValue = 60;

      expect(controller.value, isNotNull);
      expect(
        controller.value,
        MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 50,
          ),
        ),
      );
    });

    testWidgets("Setting imperial whole value keeps fraction", (tester) async {
      when(appManager.userPreferenceManager.catchWeightSystem)
          .thenReturn(MeasurementSystem.imperial_whole);

      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );
      controller.mainController.intValue = 50;
      controller.fractionController.intValue = 60;

      expect(controller.value, isNotNull);
      expect(
        controller.value,
        MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.pounds,
            value: 50,
          ),
          fractionValue: Measurement(
            unit: Unit.ounces,
            value: 60,
          ),
        ),
      );
    });

    testWidgets("Rounding", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        // Rounded to 60.0.
        mainValue: Measurement(
          unit: Unit.feet,
          value: 60.256485,
        ),
        // Not rounded.
        fractionValue: Measurement(
          unit: Unit.inches,
          value: 0.75,
        ),
      );

      expect(controller.value.mainValue.value, 60);
      expect(controller.value.fractionValue.value, 1.0);

      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        // Rounded.
        mainValue: Measurement(
          unit: Unit.inches,
          value: 10.2,
        ),
        // Not rounded.
        fractionValue: Measurement(
          value: 0.75,
        ),
      );

      expect(controller.value.mainValue.value, 10);
      expect(controller.value.fractionValue.value, 0.75);
    });

    testWidgets("isSet", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
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

    testWidgets("_system returns override", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );
      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        fractionValue: Measurement(
          unit: Unit.kilometers,
          value: 10.75,
        ),
      );
      expect(controller.value.system, MeasurementSystem.imperial_whole);
    });

    testWidgets("_system returns spec value", (tester) async {
      when(appManager.userPreferenceManager.catchWeightSystem)
          .thenReturn(MeasurementSystem.metric);

      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );

      expect(controller.value.system, MeasurementSystem.metric);
    });

    testWidgets("_system returns default", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.airHumidity(context),
      );

      expect(controller.value.system, MeasurementSystem.imperial_whole);
    });

    testWidgets("_mainUnit returns override", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );
      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.kilometers,
          value: 10.75,
        ),
      );
      expect(controller.value.mainValue.unit, Unit.kilometers);
    });

    testWidgets("_mainUnit returns metric", (tester) async {
      when(appManager.userPreferenceManager.catchWeightSystem)
          .thenReturn(MeasurementSystem.metric);

      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );

      controller.mainController.doubleValue = 10;
      expect(controller.value.mainValue.unit, Unit.kilograms);
    });

    testWidgets("_mainUnit returns imperial", (tester) async {
      when(appManager.userPreferenceManager.catchWeightSystem)
          .thenReturn(MeasurementSystem.imperial_whole);

      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );

      controller.mainController.doubleValue = 10;
      expect(controller.value.mainValue.unit, Unit.pounds);
    });

    testWidgets("_mainUnit returns first available", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.leaderRating(context),
      );

      controller.mainController.doubleValue = 10;
      expect(controller.value.mainValue.unit, Unit.pound_test);
    });

    testWidgets("_mainUnit returns selected unit", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.leaderRating(context),
      );

      controller.mainController.doubleValue = 10;
      controller.mainController.selectedUnit = Unit.x;
      expect(controller.value.mainValue.unit, Unit.x);
    });

    testWidgets("_fractionUnit returns override", (tester) async {
      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );
      controller.value = MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        fractionValue: Measurement(
          unit: Unit.inches,
          value: 10.75,
        ),
      );
      expect(controller.value.fractionValue.unit, Unit.inches);
    });

    testWidgets("_fractionUnit returns spec", (tester) async {
      when(appManager.userPreferenceManager.catchWeightSystem)
          .thenReturn(MeasurementSystem.imperial_whole);

      var context = await buildContext(tester, appManager: appManager);
      var controller = MultiMeasurementInputController(
        context: context,
        spec: MultiMeasurementInputSpec.weight(context),
      );

      controller.fractionController.doubleValue = 10;
      expect(controller.value.fractionValue.unit, Unit.ounces);
    });
  });

  group("ImagesInputController", () {
    MockFile stubFile(int hashCode, String path) {
      var result = MockFile();
      when(result.hashCode).thenReturn(hashCode);
      when(result.path).thenReturn(path);
      return result;
    }

    test("originalFiles", () {
      var controller = ImagesInputController();
      controller.value = {
        PickedImage(
          originalFile: stubFile(1, "Test"),
        ),
        PickedImage(
          originalFile: stubFile(2, "Test 2"),
        ),
        PickedImage(),
      };

      expect(controller.originalFiles.length, 2);
    });
  });
}
