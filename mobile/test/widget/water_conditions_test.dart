import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/water_conditions.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("No fields set, catch", (tester) async {
    await pumpContext(tester, (_) => WaterConditions(Catch()));
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("No fields set, trip", (tester) async {
    await pumpContext(tester, (_) => WaterConditions(Trip()));
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("Water clarity, catch", (tester) async {
    when(
      managers.waterClarityManager.entity(any),
    ).thenReturn(WaterClarity(id: randomId(), name: "Chocolate Milk"));

    await pumpContext(
      tester,
      (_) => WaterConditions(Catch(waterClarityId: randomId())),
    );

    expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
    expect(find.text("Chocolate Milk"), findsOneWidget);
  });

  testWidgets("Water clarity, trip", (tester) async {
    when(
      managers.waterClarityManager.entity(any),
    ).thenReturn(WaterClarity(id: randomId(), name: "Chocolate Milk"));

    await pumpContext(
      tester,
      (_) => WaterConditions(Trip(waterClarityId: randomId())),
    );

    expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
    expect(find.text("Chocolate Milk"), findsOneWidget);
  });

  testWidgets("Water temperature, catch", (tester) async {
    await pumpContext(
      tester,
      (_) => WaterConditions(
        Catch(
          waterTemperature: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.celsius, value: 50),
          ),
        ),
      ),
    );

    expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
    expect(find.text("50\u00B0C"), findsOneWidget);
  });

  testWidgets("Water temperature, trip", (tester) async {
    await pumpContext(
      tester,
      (_) => WaterConditions(
        Trip(
          waterTemperature: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.celsius, value: 50),
          ),
        ),
      ),
    );

    expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
    expect(find.text("50\u00B0C"), findsOneWidget);
  });

  testWidgets("Water depth, catch", (tester) async {
    await pumpContext(
      tester,
      (_) => WaterConditions(
        Catch(
          waterDepth: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.feet, value: 50),
          ),
        ),
      ),
    );

    expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
    expect(find.text("50 ft"), findsOneWidget);
  });

  testWidgets("Water depth, trip", (tester) async {
    await pumpContext(
      tester,
      (_) => WaterConditions(
        Trip(
          waterDepth: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.feet, value: 50),
          ),
        ),
      ),
    );

    expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
    expect(find.text("50 ft"), findsOneWidget);
  });

  testWidgets("All fields, catch", (tester) async {
    when(
      managers.waterClarityManager.entity(any),
    ).thenReturn(WaterClarity(id: randomId(), name: "Chocolate Milk"));

    await pumpContext(
      tester,
      (_) => WaterConditions(
        Trip(
          waterClarityId: randomId(),
          waterDepth: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.feet, value: 50),
          ),
          waterTemperature: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.celsius, value: 50),
          ),
        ),
      ),
    );

    expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
    expect(find.text("Chocolate Milk, 50\u00B0C, 50 ft"), findsOneWidget);
  });
}
