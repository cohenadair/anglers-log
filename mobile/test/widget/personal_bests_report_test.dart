import 'package:fixnum/fixnum.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mobile/widgets/personal_bests_report.dart';
import 'package:mobile/widgets/photo.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  late List<Species> species;
  late List<Catch> catches;
  late List<Trip> trips;

  MultiMeasurement length(double value) {
    return MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(
        unit: Unit.centimeters,
        value: value,
      ),
    );
  }

  MultiMeasurement weight(double value) {
    return MultiMeasurement(
      system: MeasurementSystem.metric,
      mainValue: Measurement(
        unit: Unit.kilograms,
        value: value,
      ),
    );
  }

  void resetSpecies() {
    species = [
      Species(id: randomId(), name: "Smallmouth"),
      Species(id: randomId(), name: "Largemouth"),
      Species(id: randomId(), name: "Pike"),
      Species(id: randomId(), name: "Walleye"),
      Species(id: randomId(), name: "Steelhead"),
      Species(id: randomId(), name: "Brown Trout"),
      Species(id: randomId(), name: "Flathead"),
      Species(id: randomId(), name: "Blue Catfish"),
      Species(id: randomId(), name: "Striped"),
      Species(id: randomId(), name: "Silver"),
    ];
  }

  void resetCatches() {
    catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[0].id,
        length: length(10),
        weight: weight(2),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[1].id,
        length: length(5),
        weight: weight(1),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[2].id,
        length: length(25),
        weight: weight(10),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[3].id,
        length: length(50),
        weight: weight(30),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[4].id,
        length: length(18),
        weight: weight(6),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[5].id,
        length: length(28),
        weight: weight(12),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[6].id,
        length: length(45),
        weight: weight(35),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[7].id,
        length: length(30),
        weight: weight(18),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[8].id,
        length: length(42),
        weight: weight(24),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(0),
        speciesId: species[9].id,
        length: length(20),
        weight: weight(4),
      ),
    ];
  }

  void resetTrips() {
    trips = [
      Trip(
        id: randomId(),
        name: "Trip 1",
        catchIds: [catches[0].id, catches[1].id],
      ),
      Trip(
        id: randomId(),
        name: "Trip 2",
        catchIds: [catches[2].id],
      ),
      Trip(
        id: randomId(),
        name: "Trip 3",
        catchIds: [
          catches[3].id,
          catches[4].id,
          catches[5].id,
          catches[6].id,
        ],
        // January 1, 2021
        startTimestamp: Int64(1609477200000),
        // January 2, 2021
        endTimestamp: Int64(1609563600000),
      ),
      Trip(
        id: randomId(),
        name: "Trip 4",
        catchIds: [catches[7].id, catches[8].id],
      ),
      Trip(
        id: randomId(),
        name: "Trip 5",
        catchIds: [catches[9].id],
      ),
    ];
  }

  Future<BuildContext> pumpReport(WidgetTester tester) async {
    return await pumpContext(
      tester,
      (context) => CustomScrollView(
        slivers: [
          SliverFillRemaining(
            fillOverscroll: true,
            hasScrollBody: false,
            child: PersonalBestsReport(),
          ),
        ],
      ),
      appManager: appManager,
    );
  }

  Future<BuildContext> pumpSingleScrollReport(WidgetTester tester) async {
    return await pumpContext(
      tester,
      // ensureVisible doesn't work with silvers, so use single scroll view
      // here.
      (context) => SingleChildScrollView(
        child: PersonalBestsReport(),
      ),
      appManager: appManager,
    );
  }

  setUp(() {
    appManager = StubbedAppManager();
    resetSpecies();
    resetCatches();
    resetTrips();

    when(appManager.catchManager.catches(
      any,
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.speciesManager.displayNameComparator(any)).thenReturn(
        (lhs, rhs) => ignoreCaseAlphabeticalComparator(lhs.name, rhs.name));
    when(appManager.speciesManager.entityExists(any)).thenAnswer((invocation) =>
        species.containsWhere(
            (fish) => fish.id == invocation.positionalArguments[0]));
    when(appManager.speciesManager.entity(any)).thenAnswer((invocation) =>
        species.firstWhereOrNull(
            (fish) => fish.id == invocation.positionalArguments[0]));
    when(appManager.speciesManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    when(appManager.tripManager.list()).thenReturn(trips);
    when(appManager.tripManager.numberOfCatches(any)).thenAnswer(
        (invocation) => invocation.positionalArguments[0].catchIds.length);
    when(appManager.tripManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(appManager.tripManager.name(any))
        .thenAnswer((invocation) => invocation.positionalArguments[0].name);

    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.isTrackingLength).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWeight).thenReturn(true);
    when(appManager.userPreferenceManager.statsDateRange).thenReturn(null);
    when(appManager.userPreferenceManager.setStatsDateRange(any))
        .thenAnswer((_) => Future.value());
  });

  testWidgets("Date range is loaded from preferences", (tester) async {
    when(appManager.userPreferenceManager.statsDateRange).thenReturn(DateRange(
      period: DateRange_Period.yesterday,
    ));

    await pumpReport(tester);
    expect(find.byType(DateRangePickerInput), findsOneWidget);
    expect(find.text("Yesterday"), findsOneWidget);
  });

  testWidgets("Placeholder shown when there is no data", (tester) async {
    when(appManager.tripManager.list()).thenReturn([]);
    when(appManager.catchManager.catches(
      any,
      opt: anyNamed("opt"),
    )).thenReturn([]);

    await pumpReport(tester);
    expect(find.byType(EmptyListPlaceholder), findsOneWidget);
  });

  testWidgets("Longest catch shown", (tester) async {
    await pumpReport(tester);
    expect(find.widgetWithText(InkWell, "Longest"), findsOneWidget);
  });

  testWidgets("Longest catch hidden when not tracking length", (tester) async {
    when(appManager.userPreferenceManager.isTrackingLength).thenReturn(false);
    await pumpReport(tester);
    expect(find.widgetWithText(InkWell, "Longest"), findsNothing);
  });

  testWidgets("Longest catch hidden when null", (tester) async {
    for (var cat in catches) {
      cat.clearLength();
    }
    await pumpReport(tester);
    expect(find.widgetWithText(InkWell, "Longest"), findsNothing);
  });

  testWidgets("Heaviest catch shown", (tester) async {
    await pumpReport(tester);
    expect(find.widgetWithText(InkWell, "Heaviest"), findsOneWidget);
  });

  testWidgets("Heaviest catch hidden when not tracking weight", (tester) async {
    when(appManager.userPreferenceManager.isTrackingWeight).thenReturn(false);
    await pumpReport(tester);
    expect(find.widgetWithText(InkWell, "Heaviest"), findsNothing);
  });

  testWidgets("Heaviest catch hidden when null", (tester) async {
    for (var cat in catches) {
      cat.clearWeight();
    }
    await pumpReport(tester);
    expect(find.widgetWithText(InkWell, "Heaviest"), findsNothing);
  });

  testWidgets("Best trip shown", (tester) async {
    await pumpReport(tester);
    expect(find.text("Best Trip"), findsOneWidget);
  });

  testWidgets("Best trip hidden when null", (tester) async {
    when(appManager.tripManager.list()).thenReturn([]);
    await pumpReport(tester);
    expect(find.text("Best Trip"), findsNothing);
  });

  testWidgets("Trip secondary subtitle is elapsed time", (tester) async {
    var context = await pumpReport(tester);
    expect(
      find.secondaryText(
        context,
        text: "Jan 1, 2021 to Jan 2, 2021",
      ),
      findsOneWidget,
    );
  });

  testWidgets("Trip secondary subtitle is null", (tester) async {
    when(appManager.tripManager.displayName(any, any)).thenAnswer(
        (invocation) => (invocation.positionalArguments[1] as Trip)
            .elapsedDisplayValue(invocation.positionalArguments[0]));
    when(appManager.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        catchIds: [catches[3].id],
        // January 1, 2021
        startTimestamp: Int64(1609477200000),
        // January 2, 2021
        endTimestamp: Int64(1609563600000),
      )
    ]);

    var context = await pumpReport(tester);

    expect(
      find.primaryText(
        context,
        text: "Jan 1, 2021 to Jan 2, 2021",
      ),
      findsOneWidget,
    );
    expect(
      find.secondaryText(
        context,
        text: "Jan 1, 2021 to Jan 2, 2021",
      ),
      findsNothing,
    );
  });

  testWidgets("Model produces all correct values", (tester) async {
    var context = await pumpSingleScrollReport(tester);

    // Trip
    expect(find.text("Best Trip"), findsOneWidget);
    expect(find.widgetWithText(MinChip, "4 Catches"), findsOneWidget);
    expect(find.primaryText(context, text: "Trip 3"), findsOneWidget);
    expect(
      find.secondaryText(
        context,
        text: "Jan 1, 2021 to Jan 2, 2021",
      ),
      findsOneWidget,
    );

    // Longest
    expect(find.text("Longest"), findsNWidgets(2));
    expect(find.widgetWithText(MinChip, "50 cm"), findsOneWidget);
    expect(find.primaryText(context, text: "Walleye"), findsOneWidget);
    expect(
      find.secondaryText(context, text: "Dec 31, 1969 at 7:00 PM"),
      findsNWidgets(2),
    );

    // Heaviest
    expect(find.text("Heaviest"), findsNWidgets(2));
    expect(find.widgetWithText(MinChip, "35 kg"), findsOneWidget);

    // 1 for PB, 1 in "Species By Length", and 1 in "Species By Weight".
    expect(find.primaryText(context, text: "Flathead"), findsNWidgets(3));
    expect(
      find.secondaryText(context, text: "Dec 31, 1969 at 7:00 PM"),
      findsNWidgets(2),
    );

    // By length
    await tester.ensureVisible(find.text("View all species").last);
    await tapAndSettle(tester, find.text("View all species").first);
    expect(find.text("Smallmouth"), findsOneWidget);
    expect(find.text("10 cm"), findsNWidgets(2));
    expect(find.text("Largemouth"), findsOneWidget);
    expect(find.text("5 cm"), findsNWidgets(2));
    expect(find.text("Pike"), findsOneWidget);
    expect(find.text("25 cm"), findsNWidgets(2));
    expect(find.text("Walleye"), findsOneWidget);
    expect(find.text("50 cm"), findsNWidgets(2));
    expect(find.text("Steelhead"), findsOneWidget);
    expect(find.text("18 cm"), findsNWidgets(2));
    expect(find.text("Brown Trout"), findsOneWidget);
    expect(find.text("28 cm"), findsNWidgets(2));
    expect(find.text("Flathead"), findsOneWidget);
    expect(find.text("45 cm"), findsNWidgets(2));
    expect(find.text("Blue Catfish"), findsOneWidget);
    expect(find.text("30 cm"), findsNWidgets(2));
    expect(find.text("Striped"), findsOneWidget);
    expect(find.text("42 cm"), findsNWidgets(2));
    expect(find.text("Silver"), findsOneWidget);
    expect(find.text("20 cm"), findsNWidgets(2));
    await tapAndSettle(tester, find.byType(BackButton));

    // By weight
    await tapAndSettle(tester, find.text("View all species").last);
    expect(find.text("Smallmouth"), findsOneWidget);
    expect(find.text("2 kg"), findsNWidgets(2));
    expect(find.text("Largemouth"), findsOneWidget);
    expect(find.text("1 kg"), findsNWidgets(2));
    expect(find.text("Pike"), findsOneWidget);
    expect(find.text("10 kg"), findsNWidgets(2));
    expect(find.text("Walleye"), findsOneWidget);
    expect(find.text("30 kg"), findsNWidgets(2));
    expect(find.text("Steelhead"), findsOneWidget);
    expect(find.text("6 kg"), findsNWidgets(2));
    expect(find.text("Brown Trout"), findsOneWidget);
    expect(find.text("12 kg"), findsNWidgets(2));
    expect(find.text("Flathead"), findsOneWidget);
    expect(find.text("35 kg"), findsNWidgets(2));
    expect(find.text("Blue Catfish"), findsOneWidget);
    expect(find.text("18 kg"), findsNWidgets(2));
    expect(find.text("Striped"), findsOneWidget);
    expect(find.text("24 kg"), findsNWidgets(2));
    expect(find.text("Silver"), findsOneWidget);
    expect(find.text("4 kg"), findsNWidgets(2));
  });

  testWidgets("Trips are skipped if not in date range", (tester) async {
    await pumpReport(tester);

    await tapAndSettle(tester, find.text("All dates"));
    await tapAndSettle(tester, find.text("Last week"));

    expect(find.text("Best Trip"), findsNothing);
  });

  testWidgets("Personal best doesn't have a photo", (tester) async {
    await pumpReport(tester);
    expect(find.byType(Photo), findsNothing);
  });

  testWidgets("Personal best has a photo", (tester) async {
    await stubImage(appManager, tester, "flutter_logo.png");
    catches[3].imageNames.add("flutter_logo.png");

    await pumpReport(tester);
    expect(find.byType(Photo), findsOneWidget);
  });

  testWidgets("Biggest catch unknown species", (tester) async {
    catches[3].clearSpeciesId();
    await pumpReport(tester);
    expect(find.text("Unknown Species"), findsOneWidget);
    expect(find.text("Walleye"), findsNothing);
  });

  testWidgets("Biggest catch known species", (tester) async {
    await pumpReport(tester);
    expect(find.text("Unknown Species"), findsNothing);
    expect(find.text("Walleye"), findsOneWidget);
  });

  testWidgets("Measurement per species shows empty", (tester) async {
    for (var cat in catches) {
      cat.clearLength();
      cat.clearWeight();
    }

    await pumpReport(tester);
    expect(find.text("Species By Length"), findsNothing);
    expect(find.text("Species By Weight"), findsNothing);
  });

  testWidgets("Measurement per species empty title", (tester) async {
    await pumpSingleScrollReport(tester);

    expect(find.byType(TitleLabel), findsNWidgets(5));
    await tester.ensureVisible(find.text("View all species").first);
    await tapAndSettle(tester, find.text("View all species").first);

    expect(find.byType(TitleLabel), findsNothing);
  });

  testWidgets("Measurement per species only max rows displayed",
      (tester) async {
    await pumpReport(tester);

    // 44 TableRowInkWell widgets comes from:
    //   - 5 rows * 4 columns in each row * 2 tables = 40, and
    //   - 2 cells for the "Longest" and "Average" labels * 2 tables = 4.
    expect(find.byType(TableRowInkWell), findsNWidgets(44));
  });

  testWidgets("Measurement per species bold cell", (tester) async {
    var context = await pumpReport(tester);
    expect(
      find.textStyle(
        "Longest",
        stylePrimary(context).copyWith(fontWeight: fontWeightBold),
      ),
      findsOneWidget,
    );
    expect(
      find.textStyle(
        "Heaviest",
        stylePrimary(context).copyWith(fontWeight: fontWeightBold),
      ),
      findsOneWidget,
    );
    expect(
      find.textStyle(
        "Average",
        stylePrimary(context).copyWith(fontWeight: fontWeightBold),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets("Measurement per species show all row shown if items > max",
      (tester) async {
    await pumpReport(tester);
    expect(find.text("View all species"), findsNWidgets(2));
  });

  testWidgets("Measurement per species show all row is hidden", (tester) async {
    species = [Species(id: randomId(), name: "Steelhead")];
    await pumpReport(tester);
    expect(find.text("View all species"), findsNothing);
  });
}
