import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;
  late SpeciesManager speciesManager;

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
    managers = await StubbedManagers.create();

    when(
      managers.catchManager.existsWith(speciesId: anyNamed("speciesId")),
    ).thenReturn(false);
    when(managers.catchManager.list()).thenReturn([]);

    when(
      managers.localDatabaseManager.deleteEntity(any, any),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.localDatabaseManager.insertOrReplace(any, any),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.lib.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    speciesManager = SpeciesManager(managers.app);
    when(managers.app.speciesManager).thenReturn(speciesManager);

    for (var species in speciesList) {
      await speciesManager.addOrUpdate(species);
    }
  });

  group("Normal list page", () {
    testWidgets("Title updates when species updated", (tester) async {
      await tester.pumpWidget(Testable((_) => const SpeciesListPage()));

      expect(find.text("Species (5)"), findsOneWidget);
      await speciesManager.delete(speciesList[0].id);
      await tester.pumpAndSettle(const Duration(milliseconds: 250));
      expect(find.text("Species (4)"), findsOneWidget);
    });

    testWidgets("List updates when species updated", (tester) async {
      await tester.pumpWidget(Testable((_) => const SpeciesListPage()));

      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Smallmouth Bass"), findsOneWidget);
      expect(find.text("Largemouth Bass"), findsOneWidget);
      expect(find.text("Striped Bass"), findsOneWidget);
      expect(find.text("Pike"), findsOneWidget);
      await speciesManager.delete(speciesList[0].id);
      await tester.pumpAndSettle(const Duration(milliseconds: 250));
      expect(find.text("Steelhead"), findsNothing);
    });

    testWidgets("Species deleted if not associated with a catch", (
      tester,
    ) async {
      await tester.pumpWidget(Testable((_) => const SpeciesListPage()));

      expect(
        find.byType(ManageableListItem),
        findsNWidgets(speciesList.length),
      );
      await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
      await tapAndSettle(tester, find.byIcon(Icons.delete).first);
      await tapAndSettle(tester, find.text("DELETE"), 250);
      expect(
        find.byType(ManageableListItem),
        findsNWidgets(speciesList.length - 1),
      );
    });

    testWidgets("Dialog when deleting species associated with 1 catch", (
      tester,
    ) async {
      when(
        managers.catchManager.existsWith(speciesId: anyNamed("speciesId")),
      ).thenReturn(true);
      when(managers.catchManager.list()).thenReturn([
        Catch()
          ..id = randomId()
          ..speciesId = speciesList[2].id,
      ]);

      await tester.pumpWidget(Testable((_) => const SpeciesListPage()));

      await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
      await tapAndSettle(tester, find.byIcon(Icons.delete).first);

      expect(
        find.text(
          "Largemouth Bass is associated with 1 catch and cannot be deleted.",
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      "Dialog when deleting species associated with multiple catches",
      (tester) async {
        when(
          managers.catchManager.existsWith(speciesId: anyNamed("speciesId")),
        ).thenReturn(true);
        when(managers.catchManager.list()).thenReturn([
          Catch()
            ..id = randomId()
            ..speciesId = speciesList[2].id,
          Catch()
            ..id = randomId()
            ..speciesId = speciesList[2].id,
        ]);

        await tester.pumpWidget(Testable((_) => const SpeciesListPage()));

        await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
        await tapAndSettle(tester, find.byIcon(Icons.delete).first);

        expect(
          find.text(
            "Largemouth Bass is associated with 2 catches and "
            "cannot be deleted.",
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets("Edit screen shown", (tester) async {
      await tester.pumpWidget(Testable((_) => const SpeciesListPage()));

      await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
      await tapAndSettle(tester, find.byType(ManageableListItem).first);
      expect(find.text("Edit Species"), findsOneWidget);
    });

    testWidgets("New species page shown", (tester) async {
      await tester.pumpWidget(Testable((_) => const SpeciesListPage()));

      await tapAndSettle(tester, find.byIcon(Icons.add));
      expect(find.text("New Species"), findsOneWidget);
    });
  });

  group("Picker", () {
    testWidgets("Title", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => SpeciesListPage(
            pickerSettings: ManageableListPagePickerSettings(
              onPicked: (_, __) => true,
            ),
          ),
        ),
      );

      expect(find.text("Select Species"), findsOneWidget);
    });

    testWidgets("Picked callback invoked", (tester) async {
      var picked = false;
      await tester.pumpWidget(
        Testable(
          (_) => SpeciesListPage(
            pickerSettings: ManageableListPagePickerSettings.single(
              onPicked: (_, __) {
                picked = true;
                return false;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text("Steelhead"));
      expect(picked, isTrue);
    });
  });
}
