import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_species_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockSpeciesManager: true,
    );

    when(appManager.mockSpeciesManager.nameExists(any)).thenReturn(false);
  });

  testWidgets("New title", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveSpeciesPage(),
      appManager: appManager,
    ));
    expect(find.text("New Species"), findsOneWidget);
  });

  testWidgets("Edit title", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveSpeciesPage.edit(
        Species()
          ..id = randomId()
          ..name = "Steelhead",
      ),
      appManager: appManager,
    ));
    expect(find.text("Edit Species"), findsOneWidget);
    expect(find.widgetWithText(TextField, "Steelhead"), findsOneWidget);
  });

  testWidgets("SpeciesManager callback invoked", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveSpeciesPage(),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Steelhead");
    await tapAndSettle(tester, find.text("SAVE"));
    verify(appManager.mockSpeciesManager.addOrUpdate(any)).called(1);
  });

  testWidgets("Editing species keeps same ID", (WidgetTester tester) async {
    Species species = Species()
      ..id = randomId()
      ..name = "Steelhead";

    await tester.pumpWidget(Testable(
      (_) => SaveSpeciesPage.edit(species),
      appManager: appManager,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Bass");
    await tapAndSettle(tester, find.text("SAVE"));

    VerificationResult result =
        verify(appManager.mockSpeciesManager.addOrUpdate(captureAny));
    result.called(1);
    expect(result.captured.first.id, species.id);
    expect(result.captured.first.name, "Bass");
  });
}
