import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/pages/save_trip_page.dart';
import 'package:mobile/pages/species_counter_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/pages/trip_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  late List<Species> species;

  List<Species> defaultSpecies() {
    return [
      Species(
        id: randomId(),
        name: "Steelhead",
      ),
      Species(
        id: randomId(),
        name: "Pike",
      ),
      Species(
        id: randomId(),
        name: "Bass",
      ),
    ];
  }

  setUp(() {
    appManager = StubbedAppManager();
    species = defaultSpecies();

    when(appManager.userPreferenceManager.speciesCounter).thenReturn({});
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(appManager.speciesManager.list(any)).thenReturn(species);
    when(appManager.speciesManager.listSortedByDisplayName(
      any,
      ids: anyNamed("ids"),
    )).thenReturn(species);
    when(appManager.speciesManager.displayNameFromId(any, any))
        .thenAnswer((invocation) {
      var id = invocation.positionalArguments[1] as Id;
      return species.firstWhereOrNull((e) => e.id == id)?.name;
    });
  });

  testWidgets("Page loaded from preferences", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    expect(find.text("Steelhead"), findsOneWidget);
    expect(find.text("Pike"), findsOneWidget);
    expect(find.text("Bass"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    expect(find.text("7"), findsOneWidget);
  });

  testWidgets("Reset button sets all counts to 0", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    expect(find.text("3"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    expect(find.text("7"), findsOneWidget);

    await tapAndSettle(tester, find.text("RESET"));
    expect(find.text("0"), findsNWidgets(3));
    verify(appManager.userPreferenceManager.setSpeciesCounter(any)).called(1);
  });

  testWidgets("Create trip from counts", (tester) async {
    when(appManager.customEntityManager.entityExists(any)).thenReturn(true);
    when(appManager.tripManager.entityExists(any)).thenReturn(true);
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });
    when(appManager.userPreferenceManager.autoSetTripFields).thenReturn(false);
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Create Trip"));
    expect(find.byType(SaveTripPage), findsOneWidget);

    var trip = findFirst<SaveTripPage>(tester).oldTrip;
    expect(trip, isNotNull);
    expect(trip!.catchesPerSpecies.length, 3);
    expect(trip.catchesPerSpecies[0].value, 3);
    expect(trip.catchesPerSpecies[1].value, 5);
    expect(trip.catchesPerSpecies[2].value, 7);
  });

  testWidgets("Create/append trip is disabled", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({});

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    expect(
      findFirstWithText<PopupMenuItem<String>>(tester, "Create Trip").enabled,
      isFalse,
    );
    expect(
      findFirstWithText<PopupMenuItem<String>>(tester, "Append Trip").enabled,
      isFalse,
    );
  });

  testWidgets("Append trip: no trip is selected", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([]);

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Append Trip"));
    expect(find.byType(TripListPage), findsOneWidget);

    await tapAndSettle(tester, find.byType(CloseButton));
    verifyNever(appManager.tripManager.addOrUpdate(any));
  });

  testWidgets("Append trip: add to existing counts", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([
      Trip(
        id: randomId(),
        name: "Test Trip",
        catchesPerSpecies: [
          Trip_CatchesPerEntity(
            entityId: species[0].id,
            value: 15,
          ),
          Trip_CatchesPerEntity(
            entityId: species[1].id,
            value: 20,
          ),
          Trip_CatchesPerEntity(
            entityId: species[2].id,
            value: 25,
          ),
        ],
      ),
    ]);
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(0);
    when(appManager.tripManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Append Trip"));
    expect(find.byType(TripListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Test Trip"));
    var result = verify(appManager.tripManager.addOrUpdate(captureAny));
    result.called(1);

    var trip = result.captured.first as Trip;
    expect(trip.catchesPerSpecies.length, 3);
    expect(trip.catchesPerSpecies[0].entityId, species[0].id);
    expect(trip.catchesPerSpecies[0].value, 18);
    expect(trip.catchesPerSpecies[1].entityId, species[1].id);
    expect(trip.catchesPerSpecies[1].value, 25);
    expect(trip.catchesPerSpecies[2].entityId, species[2].id);
    expect(trip.catchesPerSpecies[2].value, 32);
  });

  testWidgets("Append trip: add new counts", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([
      Trip(
        id: randomId(),
        name: "Test Trip",
        catchesPerSpecies: [
          Trip_CatchesPerEntity(
            entityId: randomId(),
            value: 15,
          ),
        ],
      ),
    ]);
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(0);
    when(appManager.tripManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Append Trip"));
    expect(find.byType(TripListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Test Trip"));
    var result = verify(appManager.tripManager.addOrUpdate(captureAny));
    result.called(1);

    var trip = result.captured.first as Trip;
    expect(trip.catchesPerSpecies.length, 4);
    expect(trip.catchesPerSpecies[1].entityId, species[0].id);
    expect(trip.catchesPerSpecies[1].value, 3);
    expect(trip.catchesPerSpecies[2].entityId, species[1].id);
    expect(trip.catchesPerSpecies[2].value, 5);
    expect(trip.catchesPerSpecies[3].entityId, species[2].id);
    expect(trip.catchesPerSpecies[3].value, 7);
  });

  testWidgets("Append trip: SnackBar shows trip name", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([
      Trip(
        id: randomId(),
        name: "Test Trip",
      ),
    ]);
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(0);
    when(appManager.tripManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Append Trip"));
    expect(find.byType(TripListPage), findsOneWidget);

    await tapAndSettle(tester, find.text("Test Trip"));
    var result = verify(appManager.tripManager.addOrUpdate(captureAny));
    result.called(1);

    // Verify SnackBar is shown.
    expect(
      find.text("Species counts added to Test Trip."),
      findsOneWidget,
    );
  });

  testWidgets("Append trip: SnackBar shows no trip name", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([
      Trip(id: randomId()),
    ]);
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(0);
    when(appManager.tripManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(FormPage.moreMenuIcon));
    await tapAndSettle(tester, find.text("Append Trip"));
    expect(find.byType(TripListPage), findsOneWidget);

    await tapAndSettle(tester, find.byType(ManageableListItem).last);
    var result = verify(appManager.tripManager.addOrUpdate(captureAny));
    result.called(1);

    // Verify SnackBar is shown.
    expect(
      find.text("Species counts added to trip."),
      findsOneWidget,
    );
  });

  testWidgets("Select species: 0 to 1+", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({});

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );
    expect(find.byType(ListItem), findsOneWidget); // "Select Species".

    // Select species.
    await tapAndSettle(tester, find.text("Select Species"));
    expect(find.byType(SpeciesListPage), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.byType(ListItem), findsNWidgets(4));
    var result =
        verify(appManager.userPreferenceManager.setSpeciesCounter(captureAny));
    result.called(1);
    expect(result.captured.first.length, 3);
  });

  testWidgets("Select species: 1+ to 0", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );
    expect(find.byType(ListItem), findsNWidgets(4));

    // Deselect all species.
    await tapAndSettle(tester, find.text("Select Species"));
    expect(find.byType(SpeciesListPage), findsOneWidget);
    await tapAndSettle(tester, find.byType(Checkbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.byType(ListItem), findsOneWidget);
    var result =
        verify(appManager.userPreferenceManager.setSpeciesCounter(captureAny));
    result.called(1);
    expect(result.captured.first.isEmpty, isTrue);
  });

  testWidgets("Select species: 1+ to 1+ with changes", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 3,
      species[1].id: 5,
      species[2].id: 7,
    });

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    // Deselect all species.
    await tapAndSettle(tester, find.text("Select Species"));
    expect(find.byType(SpeciesListPage), findsOneWidget);
    await tapAndSettle(tester, find.byType(Checkbox).last);
    await tapAndSettle(tester, find.byType(BackButton));

    var result =
        verify(appManager.userPreferenceManager.setSpeciesCounter(captureAny));
    result.called(1);
    expect(result.captured.first.length, 2);
  });

  testWidgets("Species list is empty", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({});

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    expect(find.byType(ListItem), findsOneWidget);
  });

  testWidgets("Decrement button is disabled", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[0].id: 0,
      species[2].id: 7,
    });

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    expect(
      findFirstWithIcon<IconButton>(tester, Icons.remove).onPressed,
      isNull,
    );
    expect(
      tester
          .widgetList<IconButton>(find.widgetWithIcon(IconButton, Icons.remove))
          .last
          .onPressed,
      isNotNull,
    );
  });

  testWidgets("Decrement button decreases count by 1", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[2].id: 7,
    });
    when(appManager.speciesManager.listSortedByDisplayName(
      any,
      ids: anyNamed("ids"),
    )).thenReturn([species[2]]);

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.remove));
    var result =
        verify(appManager.userPreferenceManager.setSpeciesCounter(captureAny));
    result.called(1);
    expect(result.captured.first[species[2].id], 6);
  });

  testWidgets("Increment button increases count by 1", (tester) async {
    when(appManager.userPreferenceManager.speciesCounter).thenReturn({
      species[2].id: 7,
    });
    when(appManager.speciesManager.listSortedByDisplayName(
      any,
      ids: anyNamed("ids"),
    )).thenReturn([species[2]]);

    await pumpContext(
      tester,
      (_) => SpeciesCounterPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.add));
    var result =
        verify(appManager.userPreferenceManager.setSpeciesCounter(captureAny));
    result.called(1);
    expect(result.captured.first[species[2].id], 8);
  });
}
