import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_gear_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/gear_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/multi_measurement_input.dart';
import 'package:mobile/widgets/safe_image.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.userPreferenceManager.gearFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.userPreferenceManager.rodLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.leaderLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.tippetLengthSystem)
        .thenReturn(MeasurementSystem.metric);

    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);
  });

  Padding findPaddingOfTextInput(WidgetTester tester, String text) {
    return tester.widget<Padding>(find.byWidgetPredicate((widget) =>
        widget is Padding &&
        widget.child is TextInput &&
        (widget.child as TextInput).label == text));
  }

  Padding findPaddingOfMultiMeasurementInput(
    WidgetTester tester,
    BuildContext context,
    String text,
  ) {
    return tester.widget<Padding>(find.byWidgetPredicate((widget) =>
        widget is Padding &&
        widget.child is MultiMeasurementInput &&
        (widget.child as MultiMeasurementInput).spec.title!(context) == text));
  }

  Padding findPaddingOfListPickerInput(WidgetTester tester, String text) {
    return tester.widget<Padding>(find.byWidgetPredicate((widget) =>
        widget is Padding &&
        widget.child is ListPickerInput &&
        (widget.child as ListPickerInput).title == text));
  }

  testWidgets("Name is required for new gear", (tester) async {
    await pumpContext(
      tester,
      (context) => const SaveGearPage(),
      appManager: appManager,
    );

    var input = findFirstWithText<TextInput>(tester, "Name");
    expect(input.controller?.error?.isNotEmpty, isTrue);
    expect(find.text("Required"), findsOneWidget);
  });

  testWidgets("Name is required error not shown when editing", (tester) async {
    await pumpContext(
      tester,
      (context) => SaveGearPage.edit(Gear(
        id: randomId(),
        name: "Test",
      )),
      appManager: appManager,
    );

    var input = findFirstWithText<TextInput>(tester, "Name");
    expect(input.controller?.error, isNull);
    expect(find.text("Required"), findsNothing);
  });

  testWidgets("Editing title", (tester) async {
    await pumpContext(
      tester,
      (context) => SaveGearPage.edit(Gear(
        id: randomId(),
        name: "Test",
      )),
      appManager: appManager,
    );
    expect(find.text("Edit Gear"), findsOneWidget);
    expect(find.text("New Gear"), findsNothing);
  });

  testWidgets("New title", (tester) async {
    await pumpContext(
      tester,
      (context) => const SaveGearPage(),
      appManager: appManager,
    );
    expect(find.text("Edit Gear"), findsNothing);
    expect(find.text("New Gear"), findsOneWidget);
  });

  testWidgets("Editing with all fields set", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");

    var gear = Gear(
      id: randomId(),
      name: "Bass Rod",
      imageName: "flutter_logo.png",
      rodMakeModel: "Ugly Stick",
      rodSerialNumber: "ABC123",
      rodLength: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 9,
        ),
      ),
      rodAction: RodAction.fast,
      rodPower: RodPower.light,
      reelMakeModel: "Pflueger",
      reelSerialNumber: "123ABC",
      reelSize: "3000",
      lineMakeModel: "FireLine Crystal",
      lineRating: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pound_test,
          value: 8,
        ),
      ),
      lineColor: "Mono",
      leaderLength: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.feet,
          value: 15,
        ),
      ),
      leaderRating: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pound_test,
          value: 15,
        ),
      ),
      tippetLength: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.inches,
          value: 24,
        ),
      ),
      tippetRating: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.x,
          value: 2,
        ),
      ),
      hookMakeModel: "Mustad Demon",
      hookSize: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.hashtag,
          value: 6,
        ),
      ),
    );

    await pumpContext(
      tester,
      (context) => SaveGearPage.edit(gear),
      appManager: appManager,
    );
    // Add small delay so images future can finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byType(SafeImage), findsOneWidget);
    expect(find.text("Bass Rod"), findsOneWidget);
    expect(find.text("Ugly Stick"), findsOneWidget);
    expect(find.text("ABC123"), findsOneWidget);
    expect(find.text("9"), findsOneWidget);
    expect(find.text("Fast"), findsOneWidget);
    expect(find.text("Light"), findsOneWidget);
    expect(find.text("Pflueger"), findsOneWidget);
    expect(find.text("123ABC"), findsOneWidget);
    expect(find.text("3000"), findsOneWidget);
    expect(find.text("FireLine Crystal"), findsOneWidget);
    expect(find.text("8"), findsOneWidget);
    expect(find.text("Mono"), findsOneWidget);
    expect(find.text("15"), findsNWidgets(2));
    expect(find.text("24"), findsOneWidget);
    expect(find.text("2"), findsOneWidget);
    expect(find.text("Mustad Demon"), findsOneWidget);
    expect(find.text("6"), findsOneWidget);

    when(appManager.gearManager.addOrUpdate(
      captureAny,
      imageFile: anyNamed("imageFile"),
    )).thenAnswer((invocation) {
      // Assume image is saved correctly.
      invocation.positionalArguments.first.imageName = "flutter_logo.png";
      return Future.value(true);
    });
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(
      appManager.gearManager.addOrUpdate(
        captureAny,
        imageFile: anyNamed("imageFile"),
      ),
    );
    result.called(1);
    expect(result.captured.first, gear);
  });

  testWidgets("Editing with only name set", (tester) async {
    var gear = Gear(
      id: randomId(),
      name: "Bass Rod",
    );

    await pumpContext(
      tester,
      (context) => SaveGearPage.edit(gear),
      appManager: appManager,
    );

    expect(find.byType(SafeImage), findsNothing);
    expect(find.text("Not Selected"), findsNWidgets(2));

    var count = 0;
    for (var widget in tester.widgetList<TextInput>(find.byType(TextInput))) {
      count++;

      // Skip name since it will have a value.
      if (count == 1) {
        continue;
      }

      expect(widget.controller?.hasValue, isFalse);
    }
    expect(count, 16); // Verify all inputs were verified.

    when(appManager.gearManager.addOrUpdate(
      captureAny,
      imageFile: anyNamed("imageFile"),
    )).thenAnswer((invocation) => Future.value(true));
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(
      appManager.gearManager.addOrUpdate(
        captureAny,
        imageFile: anyNamed("imageFile"),
      ),
    );
    result.called(1);
    expect(result.captured.first, gear);
  });

  testWidgets("Name padding when tracking image", (tester) async {
    when(appManager.userPreferenceManager.gearFieldIds).thenReturn([]);

    await pumpContext(
      tester,
      (context) => const SaveGearPage(),
      appManager: appManager,
    );

    expect(
      findPaddingOfTextInput(tester, "Name").padding,
      insetsHorizontalDefaultBottomSmall,
    );
  });

  testWidgets("Name padding when not tracking image", (tester) async {
    var context = await buildContext(tester);
    when(appManager.userPreferenceManager.gearFieldIds).thenReturn(
        allGearFields(context).map((e) => e.id).toList()
          ..remove(gearFieldIdImage));

    await pumpContext(
      tester,
      (context) => const SaveGearPage(),
      appManager: appManager,
    );

    expect(
      findPaddingOfTextInput(tester, "Name").padding,
      insetsHorizontalDefaultVerticalSmall,
    );
  });

  testWidgets("Rod length padding when not tracking action/power",
      (tester) async {
    var context = await buildContext(tester);
    when(appManager.userPreferenceManager.gearFieldIds)
        .thenReturn(allGearFields(context).map((e) => e.id).toList()
          ..remove(gearFieldIdRodAction)
          ..remove(gearFieldIdRodPower));

    context = await pumpContext(
      tester,
      (context) => const SaveGearPage(),
      appManager: appManager,
    );

    expect(
      findPaddingOfMultiMeasurementInput(tester, context, "Rod Length").padding,
      insetsHorizontalDefaultBottomDefault,
    );
  });

  testWidgets("Rod action padding when rod text fields are showing",
      (tester) async {
    await pumpContext(
      tester,
      (context) => const SaveGearPage(),
      appManager: appManager,
    );

    expect(
      findPaddingOfListPickerInput(tester, "Rod Action").padding,
      insetsTopDefault,
    );
  });

  testWidgets("Rod action padding when rod text fields are not showing",
      (tester) async {
    var context = await buildContext(tester);
    when(appManager.userPreferenceManager.gearFieldIds)
        .thenReturn(allGearFields(context).map((e) => e.id).toList()
          ..remove(gearFieldIdRodMakeModel)
          ..remove(gearFieldIdRodSerialNumber)
          ..remove(gearFieldIdRodLength));

    await pumpContext(
      tester,
      (context) => const SaveGearPage(),
      appManager: appManager,
    );

    expect(
      findPaddingOfListPickerInput(tester, "Rod Action").padding,
      insetsZero,
    );
  });

  testWidgets("Rod power padding when text fields showing; action hidden",
      (tester) async {
    var context = await buildContext(tester);
    when(appManager.userPreferenceManager.gearFieldIds).thenReturn(
        allGearFields(context).map((e) => e.id).toList()
          ..remove(gearFieldIdRodAction));

    await pumpContext(
      tester,
      (context) => const SaveGearPage(),
      appManager: appManager,
    );

    expect(
      findPaddingOfListPickerInput(tester, "Rod Power").padding,
      insetsTopDefault,
    );
  });

  testWidgets("Rod power padding when text fields hidden; action showing",
      (tester) async {
    var context = await buildContext(tester);
    when(appManager.userPreferenceManager.gearFieldIds)
        .thenReturn(allGearFields(context).map((e) => e.id).toList()
          ..remove(gearFieldIdRodMakeModel)
          ..remove(gearFieldIdRodSerialNumber)
          ..remove(gearFieldIdRodLength));

    await pumpContext(
      tester,
      (context) => const SaveGearPage(),
      appManager: appManager,
    );

    expect(
      findPaddingOfListPickerInput(tester, "Rod Power").padding,
      insetsZero,
    );
  });
}
