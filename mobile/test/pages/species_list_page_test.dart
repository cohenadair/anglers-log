import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;
  SpeciesManager speciesManager;

  var speciesList = [
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
      mockAuthManager: true,
      mockCatchManager: true,
      mockLocalDatabaseManager: true,
      mockSubscriptionManager: true,
    );

    when(appManager.mockAuthManager.stream).thenAnswer((_) => MockStream());

    when(appManager.mockCatchManager
            .existsWith(speciesId: anyNamed("speciesId")))
        .thenReturn(false);
    when(appManager.mockCatchManager.list()).thenReturn([]);

    when(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockLocalDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => MockStream<void>());
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    speciesManager = SpeciesManager(appManager);
    when(appManager.speciesManager).thenReturn(speciesManager);

    for (var species in speciesList) {
      await speciesManager.addOrUpdate(species);
    }
  });

  group("Normal list page", () {
    testWidgets("Title updates when species updated", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      expect(find.text("Species (5)"), findsOneWidget);
      await speciesManager.delete(speciesList[0].id);
      await tester.pumpAndSettle(Duration(milliseconds: 250));
      expect(find.text("Species (4)"), findsOneWidget);
    });

    testWidgets("List updates when species updated", (tester) async {
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
        (tester) async {
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
        (tester) async {
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
          "Largemouth Bass is associated with 1 catch and cannot be deleted.",
        ),
        findsOneWidget,
      );
    });

    testWidgets("Dialog when deleting species associated with multiple catches",
        (tester) async {
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

    testWidgets("Edit screen shown", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("EDIT"));
      await tapAndSettle(tester, find.byType(ManageableListItem).first);
      expect(find.text("Edit Species"), findsOneWidget);
    });

    testWidgets("New species page shown", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.byIcon(Icons.add));
      expect(find.text("New Species"), findsOneWidget);
    });
  });

  group("Picker", () {
    testWidgets("Title", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(
          pickerSettings: ManageableListPagePickerSettings(
            onPicked: (_, __) => true,
          ),
        ),
        appManager: appManager,
      ));

      expect(find.text("Select Species"), findsOneWidget);
    });

    testWidgets("Picked callback invoked", (tester) async {
      var picked = false;
      await tester.pumpWidget(Testable(
        (_) => SpeciesListPage(
          pickerSettings: ManageableListPagePickerSettings.single(
            onPicked: (_, __) {
              picked = true;
              return false;
            },
          ),
        ),
        appManager: appManager,
      ));

      await tester.tap(find.text("Steelhead"));
      expect(picked, isTrue);
    });
  });
}
