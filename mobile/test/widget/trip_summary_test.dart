import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/trip_list_page.dart';
import 'package:mobile/pages/trip_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/tile.dart';
import 'package:mobile/widgets/trip_summary.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  late List<Catch> catches;
  late List<Trip> trips;

  Int64 timestamp(int msOffset) => Int64(1609477200000 + msOffset);

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

  void resetCatches() {
    catches = [
      // Trip 1
      Catch(
        id: randomId(),
        timestamp: timestamp(0),
        length: length(25),
      ),
      Catch(
        id: randomId(),
        timestamp: timestamp(Duration.millisecondsPerHour),
        weight: weight(10),
      ),
      Catch(
        id: randomId(),
        timestamp: timestamp(Duration.millisecondsPerHour +
            (Duration.millisecondsPerMinute * 30)),
        length: length(15),
        weight: weight(40),
      ),
      // Trip 3
      Catch(
        id: randomId(),
        timestamp: timestamp(Duration.millisecondsPerDay * 30 +
            (Duration.millisecondsPerHour * 5)),
        length: length(10),
      ),
      Catch(
        id: randomId(),
        timestamp: timestamp(Duration.millisecondsPerDay * 30 +
            (Duration.millisecondsPerHour * 5) +
            (Duration.millisecondsPerMinute * 45)),
        length: length(30),
      ),
      Catch(
        id: randomId(),
        timestamp: timestamp(Duration.millisecondsPerDay * 30),
        weight: weight(15),
      ),
      // Trip 2
      Catch(
        id: randomId(),
        timestamp: timestamp(-Duration.millisecondsPerDay * 30 +
            (Duration.millisecondsPerHour * 5)),
      ),
      Catch(
        id: randomId(),
        timestamp: timestamp(-Duration.millisecondsPerDay * 30 +
            (Duration.millisecondsPerHour * 5) +
            (Duration.millisecondsPerMinute * 45)),
        weight: weight(30),
      ),
      Catch(
        id: randomId(),
        timestamp: timestamp(-Duration.millisecondsPerDay * 30),
        weight: weight(5),
      ),
    ];
  }

  void resetTrips() {
    trips = [
      Trip(
        id: randomId(),
        name: "Trip 1",
        catchIds: {catches[0].id, catches[1].id, catches[2].id},
        startTimestamp: catches[0].timestamp,
        endTimestamp: catches[2].timestamp,
      ),
      Trip(
        id: randomId(),
        name: "Trip 2",
        catchIds: {catches[6].id, catches[7].id, catches[8].id},
        startTimestamp: catches[6].timestamp,
        endTimestamp: catches[8].timestamp,
      ),
      Trip(
        id: randomId(),
        name: "Trip 3",
        catchIds: {catches[3].id, catches[4].id, catches[5].id},
        startTimestamp: catches[5].timestamp,
        endTimestamp: catches[3].timestamp,
      ),
    ]..sort((lhs, rhs) => rhs.startTimestamp.compareTo(lhs.startTimestamp));
  }

  void expectTile(String text1, String text2) {
    expect(
      find.descendant(
        of: find.widgetWithText(Tile, text1),
        matching: find.text(text2),
      ),
      findsOneWidget,
    );
  }

  setUp(() async {
    managers = await StubbedManagers.create();
    resetCatches();
    resetTrips();

    when(managers.catchManager.catches(
      any,
      opt: anyNamed("opt"),
    )).thenAnswer((invocation) => catches
        .where((e) => invocation.namedArguments[const Symbol("opt")].catchIds
            .contains(e.id))
        .toList());
    when(managers.catchManager.uuidMapEntries())
        .thenReturn({for (var cat in catches) cat.id.uuid: cat}.entries);

    when(managers.tripManager.uuidMapEntries()).thenAnswer(
        (_) => {for (var trip in trips) trip.id.uuid: trip}.entries);
    when(managers.tripManager.idSet(entities: anyNamed("entities")))
        .thenReturn(trips.map((e) => e.id).toSet());
    when(managers.tripManager.numberOfCatches(any)).thenAnswer(
        (invocation) => invocation.positionalArguments[0].catchIds.length);
    when(managers.tripManager.entity(any)).thenReturn(Trip());
    when(managers.tripManager.deleteMessage(any, any)).thenReturn("Delete");

    var now = dateTimestamp(1641397060000);
    when(managers.lib.timeManager.currentDateTime).thenReturn(now);
    when(managers.lib.timeManager.now(any)).thenReturn(now);
    when(managers.lib.timeManager.currentTimestamp).thenReturn(1641397060000);

    when(managers.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.statsDateRange).thenReturn(null);
    when(managers.userPreferenceManager.setStatsDateRange(any))
        .thenAnswer((_) => Future.value());

    when(managers.ioWrapper.isAndroid).thenReturn(false);
    when(managers.isolatesWrapper.computeIntList(any, any))
        .thenAnswer((invocation) {
      return Future.value(invocation.positionalArguments
          .first(invocation.positionalArguments[1]));
    });
  });

  Future<BuildContext> pumpSummary(WidgetTester tester) async {
    var context = await pumpContext(
      tester,
      (_) => SingleChildScrollView(child: TripSummary()),
    );
    // Extra pump required because report generation is done in an Isolate.
    await tester.pumpAndSettle();
    return context;
  }

  testWidgets("Loading is shown while report is calculated", (tester) async {
    await pumpContext(
      tester,
      (_) => SingleChildScrollView(child: TripSummary()),
    );

    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(DateRangePickerInput), findsNothing);
  });

  testWidgets("Date range is loaded from preferences", (tester) async {
    when(managers.userPreferenceManager.statsDateRange).thenReturn(DateRange(
      period: DateRange_Period.yesterday,
    ));

    await pumpSummary(tester);
    expect(find.byType(DateRangePickerInput), findsOneWidget);
    expect(find.text("Yesterday"), findsOneWidget);
  });

  testWidgets("One trip", (tester) async {
    trips.removeRange(0, trips.length - 1);
    expect(trips.length, 1);

    when(managers.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(trips);

    await pumpSummary(tester);
    expect(find.text("Trip"), findsOneWidget);

    await tapAndSettle(tester, find.text("Trip"));
    expect(find.byType(TripListPage), findsOneWidget);
  });

  testWidgets("Zero trips", (tester) async {
    trips.clear();
    expect(trips.isEmpty, isTrue);

    await pumpSummary(tester);

    expect(find.text("Trips"), findsOneWidget);
    await tapAndSettle(tester, find.text("Trips"));
    expect(find.byType(TripListPage), findsNothing);

    expect(find.text("Longest Trip"), findsNothing);
    await tapAndSettle(tester, find.text("Since Last Trip"));
    expect(find.byType(TripListPage), findsNothing);

    expect(find.text("Weight Per Trip"), findsNothing);
    expect(find.text("Best Weight"), findsNothing);
    expect(find.text("Length Per Trip"), findsNothing);
    expect(find.text("Best Length"), findsNothing);
  });

  testWidgets("Date range that doesn't include now", (tester) async {
    expect(trips.isNotEmpty, isTrue);

    await pumpSummary(tester);

    await tapAndSettle(tester, find.text("All dates"));
    await tapAndSettle(tester, find.text("Last week"));

    expect(find.text("Longest Trip"), findsNothing);
    expect(find.text("Since Last Trip"), findsNothing);
  });

  testWidgets("Since last trip is visible", (tester) async {
    expect(trips.isNotEmpty, isTrue);

    await pumpSummary(tester);

    expect(find.text("Since Last Trip"), findsOneWidget);
    await tapAndSettle(tester, find.text("Since Last Trip"));
    expect(find.byType(TripPage), findsOneWidget);
  });

  testWidgets("Report is calculated correctly", (tester) async {
    expect(trips.isNotEmpty, isTrue);
    await pumpSummary(tester);

    expectTile("Trips", "3");
    expectTile("Total Trip Time", "1h");
    expectTile("Longest Trip", "5h");
    expectTile("Since Last Trip", "339d");
    expectTile("Average Trip Time", "30m");
    expectTile("Between Trips", "20d");
    expectTile("Between Catches", "1h");
    expectTile("Catches Per Trip", "3.0");
    expectTile("Catches Per Hour", "0.9");
    expectTile("Weight Per Trip", "19.17 kg");
    expectTile("Best Weight", "50 kg");
    expectTile("Length Per Trip", "20 cm");
    expectTile("Best Length", "40 cm");
  });

  // https://github.com/cohenadair/anglers-log/issues/903
  testWidgets("Best length with skunked trip", (tester) async {
    trips.add(Trip(id: randomId())); // Add a skunked trip.

    await pumpSummary(tester);
    expectTile("Best Length", "40 cm");
  });
}
