import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/save_body_of_water_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.bodyOfWaterManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));
    when(managers.bodyOfWaterManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(
      Testable((_) => SaveBodyOfWaterPage.edit(BodyOfWater())),
    );
    expect(find.text("Edit Body of Water"), findsOneWidget);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveBodyOfWaterPage()));
    expect(find.text("New Body of Water"), findsOneWidget);
  });

  testWidgets("Save new", (tester) async {
    await tester.pumpWidget(Testable((_) => const SaveBodyOfWaterPage()));

    await enterTextAndSettle(tester, find.byType(TextField), "Lake Huron");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.bodyOfWaterManager.addOrUpdate(captureAny));
    result.called(1);

    BodyOfWater bodyOfWater = result.captured.first;
    expect(bodyOfWater.name, "Lake Huron");
  });

  testWidgets("Editing", (tester) async {
    var bodyOfWater = BodyOfWater()
      ..id = randomId()
      ..name = "Lake Huron";

    await tester.pumpWidget(
      Testable((_) => SaveBodyOfWaterPage.edit(bodyOfWater)),
    );

    expect(find.text("Lake Huron"), findsOneWidget);

    await enterTextAndSettle(tester, find.byType(TextField), "Nine Mile");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.bodyOfWaterManager.addOrUpdate(captureAny));
    result.called(1);

    BodyOfWater newBodyOfWater = result.captured.first;
    expect(newBodyOfWater.id, bodyOfWater.id);
    expect(newBodyOfWater.name, "Nine Mile");
  });

  testWidgets("Editing name that already exists", (tester) async {
    when(managers.bodyOfWaterManager.nameExists(any)).thenReturn(true);

    var bodyOfWater = BodyOfWater()
      ..id = randomId()
      ..name = "Lake Huron";

    await tester.pumpWidget(
      Testable((_) => SaveBodyOfWaterPage.edit(bodyOfWater)),
    );

    await enterTextAndSettle(tester, find.byType(TextField), "Nine Mile");
    expect(find.text("Body of water already exists"), findsOneWidget);
  });
}
