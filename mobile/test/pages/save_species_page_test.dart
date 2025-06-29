import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_species_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.speciesManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(false));
    when(managers.speciesManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveSpeciesPage(),
      managers: managers,
    ));
    expect(find.text("New Species"), findsOneWidget);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveSpeciesPage.edit(
        Species()
          ..id = randomId()
          ..name = "Steelhead",
      ),
      managers: managers,
    ));
    expect(find.text("Edit Species"), findsOneWidget);
    expect(find.widgetWithText(TextField, "Steelhead"), findsOneWidget);
  });

  testWidgets("SpeciesManager callback invoked", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveSpeciesPage(),
      managers: managers,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Steelhead");
    await tapAndSettle(tester, find.text("SAVE"));
    verify(managers.speciesManager.addOrUpdate(any)).called(1);
  });

  testWidgets("Editing species keeps same ID", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";

    await tester.pumpWidget(Testable(
      (_) => SaveSpeciesPage.edit(species),
      managers: managers,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Bass");
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.speciesManager.addOrUpdate(captureAny));
    result.called(1);
    expect(result.captured.first.id, species.id);
    expect(result.captured.first.name, "Bass");
  });
}
