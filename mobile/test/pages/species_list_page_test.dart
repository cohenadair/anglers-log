import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;
  SpeciesManager speciesManager;

  List<Species> speciesList = [
    Species()
      ..id = randomId()
      ..name = "Steelhead",
    Species()
      ..id = randomId()
      ..name = "Smallmouth Bass",
    Species()
      ..id = randomId()
      ..name = "Largemouth Bass",
    Species()
      ..id = randomId()
      ..name = "Striped Bass",
    Species()
      ..id = randomId()
      ..name = "Pike",
  ];

  setUp(() async {
    appManager = MockAppManager(
      mockCatchManager: true,
      mockDataManager: true,
    );

    when(appManager.mockCatchManager
            .existsWith(speciesId: anyNamed("speciesId")))
        .thenReturn(false);
    when(appManager.mockCatchManager.list()).thenReturn([]);

    when(appManager.mockDataManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    speciesManager = SpeciesManager(appManager);
    when(appManager.speciesManager).thenReturn(speciesManager);

    for (Species species in speciesList) {
      await speciesManager.addOrUpdate(species);
    }
  });

  group("Normal list page", () {
    testWidgets("Title updates when species updated",
        (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      expect(find.text("Species (5)"), findsOneWidget);
      await speciesManager.delete(speciesList[0].id);
      await tester.pumpAndSettle(Duration(milliseconds: 250));
      expect(find.text("Species (4)"), findsOneWidget);
    });

    testWidgets("List updates when species updated",
        (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Smallmouth Bass"), findsOneWidget);
      expect(find.text("Largemouth Bass"), findsOneWidget);
      expect(find.text("Striped Bass"), findsOneWidget);
      expect(find.text("Pike"), findsOneWidget);
      await speciesManager.delete(speciesList[0].id);
      await tester.pumpAndSettle(Duration(milliseconds: 250));
      expect(find.text("Steelhead"), findsNothing);
    });

    testWidgets("Species deleted if not associated with a catch",
        (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      expect(
          find.byType(ManageableListItem), findsNWidgets(speciesList.length));
      await tapAndSettle(tester, find.text("EDIT"));
      await tapAndSettle(tester, find.byIcon(Icons.delete).first);
      await tapAndSettle(tester, find.text("DELETE"), 250);
      expect(find.byType(ManageableListItem),
          findsNWidgets(speciesList.length - 1));
    });

    testWidgets("Dialog when deleting species associated with 1 catch",
        (WidgetTester tester) async {
      when(appManager.mockCatchManager
              .existsWith(speciesId: anyNamed("speciesId")))
          .thenReturn(true);
      when(appManager.mockCatchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..speciesId = speciesList[2].id,
      ]);

      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("EDIT"));
      await tapAndSettle(tester, find.byIcon(Icons.delete).first);

      expect(
        find.text(
            "Largemouth Bass is associated with 1 catch and cannot be deleted."),
        findsOneWidget,
      );
    });

    testWidgets("Dialog when deleting species associated with multiple catches",
        (WidgetTester tester) async {
      when(appManager.mockCatchManager
              .existsWith(speciesId: anyNamed("speciesId")))
          .thenReturn(true);
      when(appManager.mockCatchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..speciesId = speciesList[2].id,
        Catch()
          ..id = randomId()
          ..speciesId = speciesList[2].id,
      ]);

      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("EDIT"));
      await tapAndSettle(tester, find.byIcon(Icons.delete).first);

      expect(
        find.text("Largemouth Bass is associated with 2 catches and "
            "cannot be deleted."),
        findsOneWidget,
      );
    });

    testWidgets("Edit screen shown", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("EDIT"));
      await tapAndSettle(tester, find.byType(ManageableListItem).first);
      expect(find.text("Edit Species"), findsOneWidget);
    });

    testWidgets("New species page shown", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.byIcon(Icons.add));
      expect(find.text("New Species"), findsOneWidget);
    });
  });

  group("Picker", () {
    testWidgets("Title", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage.picker(
          onPicked: (_, __) => false,
        ),
        appManager: appManager,
      ));

      expect(find.text("Select Species"), findsOneWidget);
    });

    testWidgets("Picked callback invoked", (WidgetTester tester) async {
      bool picked = false;
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage.picker(
          onPicked: (_, __) {
            picked = true;
            return false;
          },
        ),
        appManager: appManager,
      ));

      await tester.tap(find.text("Steelhead"));
      expect(picked, isTrue);
    });
  });
}
