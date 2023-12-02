import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pbserver.dart';
import 'package:mobile/pages/save_body_of_water_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.bodyOfWaterManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.bodyOfWaterManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveBodyOfWaterPage.edit(BodyOfWater()),
      appManager: appManager,
    ));
    expect(find.text("Edit Body of Water"), findsOneWidget);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveBodyOfWaterPage(),
      appManager: appManager,
    ));
    expect(find.text("New Body of Water"), findsOneWidget);
  });

  testWidgets("Save new", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveBodyOfWaterPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Lake Huron");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.bodyOfWaterManager.addOrUpdate(captureAny));
    result.called(1);

    BodyOfWater bodyOfWater = result.captured.first;
    expect(bodyOfWater.name, "Lake Huron");
  });

  testWidgets("Editing", (tester) async {
    var bodyOfWater = BodyOfWater()
      ..id = randomId()
      ..name = "Lake Huron";

    await tester.pumpWidget(Testable(
      (_) => SaveBodyOfWaterPage.edit(bodyOfWater),
      appManager: appManager,
    ));

    expect(find.text("Lake Huron"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "Nine Mile");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.bodyOfWaterManager.addOrUpdate(captureAny));
    result.called(1);

    BodyOfWater newBodyOfWater = result.captured.first;
    expect(newBodyOfWater.id, bodyOfWater.id);
    expect(newBodyOfWater.name, "Nine Mile");
  });

  testWidgets("Editing name that already exists", (tester) async {
    when(appManager.bodyOfWaterManager.nameExists(any)).thenReturn(true);

    var bodyOfWater = BodyOfWater()
      ..id = randomId()
      ..name = "Lake Huron";

    await tester.pumpWidget(Testable(
      (_) => SaveBodyOfWaterPage.edit(bodyOfWater),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Nine Mile");
    expect(find.text("Body of water already exists"), findsOneWidget);
  });
}
