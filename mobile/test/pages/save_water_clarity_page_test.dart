import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/save_water_clarity_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.waterClarityManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));
    when(managers.waterClarityManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(
      Testable((_) => SaveWaterClarityPage.edit(WaterClarity())),
    );
    expect(find.text("Edit Water Clarity"), findsOneWidget);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveWaterClarityPage()));
    expect(find.text("New Water Clarity"), findsOneWidget);
  });

  testWidgets("Save new", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveWaterClarityPage()));

    await enterTextAndSettle(tester, find.byType(TextField), "Clear");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.waterClarityManager.addOrUpdate(captureAny));
    result.called(1);

    WaterClarity waterClarity = result.captured.first;
    expect(waterClarity.name, "Clear");
  });

  testWidgets("Editing", (tester) async {
    var waterClarity = WaterClarity()
      ..id = randomId()
      ..name = "Clear";

    await tester.pumpWidget(
      Testable((_) => SaveWaterClarityPage.edit(waterClarity)),
    );

    expect(find.text("Clear"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "Stained");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.waterClarityManager.addOrUpdate(captureAny));
    result.called(1);

    WaterClarity newClarity = result.captured.first;
    expect(newClarity.id, waterClarity.id);
    expect(newClarity.name, "Stained");
  });
}
