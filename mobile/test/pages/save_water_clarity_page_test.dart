import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pbserver.dart';
import 'package:mobile/pages/save_water_clarity_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.waterClarityManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.waterClarityManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveWaterClarityPage.edit(WaterClarity()),
      appManager: appManager,
    ));
    expect(find.text("Edit Water Clarity"), findsOneWidget);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveWaterClarityPage(),
      appManager: appManager,
    ));
    expect(find.text("New Water Clarity"), findsOneWidget);
  });

  testWidgets("Save new", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveWaterClarityPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Clear");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.waterClarityManager.addOrUpdate(captureAny));
    result.called(1);

    WaterClarity waterClarity = result.captured.first;
    expect(waterClarity.name, "Clear");
  });

  testWidgets("Editing", (tester) async {
    var waterClarity = WaterClarity()
      ..id = randomId()
      ..name = "Clear";

    await tester.pumpWidget(Testable(
      (_) => SaveWaterClarityPage.edit(waterClarity),
      appManager: appManager,
    ));

    expect(find.text("Clear"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "Stained");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.waterClarityManager.addOrUpdate(captureAny));
    result.called(1);

    WaterClarity newClarity = result.captured.first;
    expect(newClarity.id, waterClarity.id);
    expect(newClarity.name, "Stained");
  });
}
