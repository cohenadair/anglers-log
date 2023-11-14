import 'dart:io';

import 'package:collection/src/iterable_extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as map;
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_trip_page.dart';
import 'package:mobile/utils/date_time_utils.dart' as date_time_utils;
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/trip_utils.dart';
import 'package:mobile/widgets/atmosphere_input.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  late List<Catch> catches;
  late List<Angler> anglers;
  late List<BodyOfWater> bodiesOfWater;
  late List<GpsTrail> gpsTrails;
  late List<Species> species;
  late List<FishingSpot> fishingSpots;
  late List<Bait> baits;
  late Atmosphere atmosphere;

  Atmosphere defaultAtmosphere() {
    return Atmosphere(
      temperature: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.celsius,
          value: 15,
        ),
      ),
      skyConditions: [SkyCondition.cloudy],
      windSpeed: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilometers_per_hour,
          value: 6.5,
        ),
      ),
      windDirection: Direction.north,
      pressure: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.millibars,
          value: 1000,
        ),
      ),
      humidity: MultiMeasurement(
        mainValue: Measurement(
          unit: Unit.percent,
          value: 50,
        ),
      ),
      visibility: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.kilometers,
          value: 10,
        ),
      ),
      moonPhase: MoonPhase.full,
      sunriseTimestamp: Int64(1624348800000),
      sunsetTimestamp: Int64(1624381200000),
    );
  }

  List<Angler> defaultAnglers() {
    return [
      Angler(id: randomId(), name: "Me"),
    ];
  }

  List<Bait> defaultBaits() {
    var bait0Id = randomId();
    return [
      Bait(
        id: randomId(),
        name: "Worm",
        variants: [
          BaitVariant(
            id: bait0Id,
            baseId: bait0Id,
            color: "Red",
          ),
        ],
      )
    ];
  }

  List<BodyOfWater> defaultBodiesOfWater() {
    return [
      BodyOfWater(id: randomId(), name: "BOW 1"),
      BodyOfWater(id: randomId(), name: "BOW 2"),
      BodyOfWater(id: randomId(), name: "BOW 3"),
    ];
  }

  List<GpsTrail> defaultGpsTrails() {
    return [
      GpsTrail(id: randomId(), points: [GpsTrailPoint()]),
      GpsTrail(id: randomId(), points: [GpsTrailPoint(), GpsTrailPoint()]),
      GpsTrail(id: randomId(), points: [GpsTrailPoint()]),
    ];
  }

  List<Catch> defaultCatches() {
    return [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch),
        timeZone: defaultTimeZone,
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 2, 1).millisecondsSinceEpoch),
        timeZone: defaultTimeZone,
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 3, 1).millisecondsSinceEpoch),
        timeZone: defaultTimeZone,
      ),
    ];
  }

  List<FishingSpot> defaultFishingSpots() {
    return [
      FishingSpot(id: randomId(), name: "Spot 1"),
    ];
  }

  List<Species> defaultSpecies() {
    return [
      Species(id: randomId(), name: "Rainbow Trout"),
    ];
  }

  Trip defaultTrip() {
    return Trip(
      id: randomId(),
      startTimestamp: Int64(dateTime(2020, 1, 1, 9).millisecondsSinceEpoch),
      endTimestamp: Int64(dateTime(2020, 1, 3, 17).millisecondsSinceEpoch),
      timeZone: defaultTimeZone,
      name: "Test Trip",
      catchIds: [catches[0].id, catches[2].id],
      bodyOfWaterIds: [bodiesOfWater[2].id],
      gpsTrailIds: [gpsTrails[0].id, gpsTrails[1].id],
      atmosphere: atmosphere,
      notes: "Test notes for a test trip.",
      catchesPerSpecies: [
        Trip_CatchesPerEntity(
          entityId: species[0].id,
          value: 5,
        ),
      ],
      catchesPerFishingSpot: [
        Trip_CatchesPerEntity(
          entityId: fishingSpots[0].id,
          value: 10,
        ),
      ],
      catchesPerAngler: [
        Trip_CatchesPerEntity(
          entityId: anglers[0].id,
          value: 15,
        ),
      ],
      catchesPerBait: [
        Trip_CatchesPerBait(
          attachment: BaitAttachment(
            baitId: baits[0].id,
            variantId: baits[0].variants[0].id,
          ),
          value: 20,
        ),
      ],
    );
  }

  setUp(() {
    appManager = StubbedAppManager();

    catches = defaultCatches();
    atmosphere = defaultAtmosphere();
    anglers = defaultAnglers();
    bodiesOfWater = defaultBodiesOfWater();
    gpsTrails = defaultGpsTrails();
    species = defaultSpecies();
    fishingSpots = defaultFishingSpots();
    baits = defaultBaits();

    when(appManager.anglerManager.entityExists(anglers[0].id)).thenReturn(true);
    when(appManager.anglerManager.entity(anglers[0].id)).thenReturn(anglers[0]);
    when(appManager.anglerManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(appManager.baitManager.variantFromAttachment(any))
        .thenAnswer((invocation) {
      var attachment = invocation.positionalArguments[0];
      var bait = baits.firstWhereOrNull((e) => e.id == attachment?.baitId);
      return bait?.variants
          .firstWhereOrNull((e) => e.id == attachment.variantId);
    });
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenAnswer((invocation) {
      var attachment = invocation.positionalArguments[1];
      var bait = baits.firstWhereOrNull((e) => e.id == attachment?.baitId);
      var variant =
          bait?.variants.firstWhereOrNull((e) => e.id == attachment.variantId);
      if (bait == null && variant == null) {
        return "";
      } else if (bait == null) {
        return variant!.color;
      } else if (variant == null) {
        return bait.name;
      } else {
        return "${bait.name} (${variant.color})";
      }
    });

    when(appManager.bodyOfWaterManager.list(any)).thenReturn(bodiesOfWater);
    when(appManager.bodyOfWaterManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(appManager.gpsTrailManager.list(any)).thenReturn(gpsTrails);
    when(appManager.gpsTrailManager.displayName(any, any)).thenAnswer(
        (invocation) =>
            "${invocation.positionalArguments[1].points.length} Points");

    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);
    when(appManager.catchManager.id(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.id);
    when(appManager.catchManager.list(any)).thenReturn(catches);
    when(appManager.catchManager.displayName(any, any)).thenAnswer(
        (invocation) => date_time_utils.formatTimestamp(
            invocation.positionalArguments[0],
            invocation.positionalArguments[1].timestamp.toInt(),
            null));

    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    when(appManager.fishingSpotManager.entityExists(fishingSpots[0].id))
        .thenReturn(true);
    when(appManager.fishingSpotManager.entity(fishingSpots[0].id))
        .thenReturn(fishingSpots[0]);
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
      includeLatLngLabels: anyNamed("includeLatLngLabels"),
    )).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    when(appManager.speciesManager.entityExists(species[0].id))
        .thenReturn(true);
    when(appManager.speciesManager.entity(species[0].id))
        .thenReturn(species[0]);
    when(appManager.speciesManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(appManager.tripManager
            .addOrUpdate(any, imageFiles: anyNamed("imageFiles")))
        .thenAnswer((invocation) => Future.value(true));

    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureImperialUnit)
        .thenReturn(Unit.inch_of_mercury);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.autoSetTripFields).thenReturn(true);

    when(appManager.subscriptionManager.isFree).thenReturn(true);

    appManager.stubCurrentTime(dateTime(2021, 2, 1, 10, 30));

    var timeZoneLocation = MockTimeZoneLocation();
    when(timeZoneLocation.displayNameUtc).thenReturn("America/New York");
    when(timeZoneLocation.name).thenReturn("America/New_York");
    when(appManager.timeManager.filteredLocations(
      any,
      exclude: anyNamed("exclude"),
    )).thenReturn([timeZoneLocation]);
  });

  testWidgets("Editing shows old values", (tester) async {
    var trip = defaultTrip();
    trip.imageNames.clear();
    trip.imageNames.addAll(["flutter_logo.png"]);

    await stubImage(appManager, tester, "flutter_logo.png");

    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(trip),
      appManager: appManager,
    ));
    // Let image future settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.byType(Image), findsOneWidget);
    expect(find.text("Jan 1, 2020"), findsOneWidget);
    expect(find.text("9:00 AM"), findsOneWidget);
    expect(find.text("Jan 3, 2020"), findsOneWidget);
    expect(find.text("5:00 PM"), findsOneWidget);
    expect(find.text("America/New York"), findsOneWidget);
    expect(find.text("Test Trip"), findsOneWidget);
    expect(find.text("Test notes for a test trip."), findsOneWidget);
    expect(find.text("Cloudy"), findsOneWidget);
    expect(find.text("Rainbow Trout"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    expect(find.text("Spot 1"), findsOneWidget);
    expect(find.text("10"), findsOneWidget);
    expect(find.text("Me"), findsOneWidget);
    expect(find.text("15"), findsOneWidget);
    expect(find.text("Worm (Red)"), findsOneWidget);
    expect(find.text("20"), findsOneWidget);
    expect(find.text("Jan 1, 2020 at 12:00 AM"), findsOneWidget);
    expect(find.text("Mar 1, 2020 at 12:00 AM"), findsOneWidget);
    expect(find.text("BOW 3"), findsOneWidget);
    expect(find.text("1 Points"), findsOneWidget);
    expect(find.text("2 Points"), findsOneWidget);
  });

  testWidgets("Editing title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(defaultTrip()),
      appManager: appManager,
    ));
    expect(find.text("Edit Trip"), findsOneWidget);
    expect(find.text("New Trip"), findsNothing);
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));
    expect(find.text("Edit Trip"), findsNothing);
    expect(find.text("New Trip"), findsOneWidget);
  });

  testWidgets("Atmosphere fetcher uses current location", (tester) async {
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const map.LatLng(1, 2));

    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(defaultTrip()),
      appManager: appManager,
    ));

    var fetcher = findFirst<AtmosphereInput>(tester).fetcher;
    expect(fetcher.latLng, isNotNull);
    expect(fetcher.latLng!.latitude, 1);
    expect(fetcher.latLng!.longitude, 2);
  });

  testWidgets("Atmosphere fetcher uses first catch fishing spot location",
      (tester) async {
    var catchId = randomId();
    var fishingSpotId = randomId();
    when(appManager.catchManager.entity(catchId)).thenReturn(Catch(
      id: catchId,
      fishingSpotId: fishingSpotId,
    ));
    when(appManager.fishingSpotManager.entity(fishingSpotId))
        .thenReturn(FishingSpot(
      id: fishingSpotId,
      lat: 3,
      lng: 4,
    ));

    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(Trip(
        id: randomId(),
        catchIds: [catchId],
      )),
      appManager: appManager,
    ));

    var fetcher = findFirst<AtmosphereInput>(tester).fetcher;
    expect(fetcher.latLng, isNotNull);
    expect(fetcher.latLng!.latitude, 3);
    expect(fetcher.latLng!.longitude, 4);
  });

  testWidgets("Atmosphere not auto-fetched for free users", (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([
      tripFieldIdStartTimestamp,
      tripFieldIdEndTimestamp,
      tripFieldIdCatches,
      tripFieldIdAtmosphere,
    ]);

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));
    expect(find.text("Atmosphere and Weather"), findsOneWidget);

    when(appManager.subscriptionManager.isFree).thenReturn(true);

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    verify(appManager.subscriptionManager.isFree).called(1);
    verifyNever(appManager.userPreferenceManager.autoFetchAtmosphere);
    verifyNever(appManager.httpWrapper.get(any));
  });

  testWidgets("Atmosphere not auto-fetched if not tracked", (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([
      tripFieldIdStartTimestamp,
      tripFieldIdEndTimestamp,
      tripFieldIdCatches,
    ]);

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));
    expect(find.text("Atmosphere and Weather"), findsNothing);

    when(appManager.subscriptionManager.isFree).thenReturn(false);

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    verify(appManager.subscriptionManager.isFree).called(1);
    verifyNever(appManager.userPreferenceManager.autoFetchAtmosphere);
    verifyNever(appManager.httpWrapper.get(any));
  });

  testWidgets("Atmosphere not auto-fetched if auto-fetch preference is false",
      (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([
      tripFieldIdStartTimestamp,
      tripFieldIdEndTimestamp,
      tripFieldIdCatches,
      tripFieldIdAtmosphere,
    ]);

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));
    expect(find.text("Atmosphere and Weather"), findsOneWidget);

    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    verify(appManager.subscriptionManager.isFree).called(1);
    verify(appManager.userPreferenceManager.autoFetchAtmosphere).called(1);
    verifyNever(appManager.httpWrapper.get(any));
  });

  testWidgets("Atmosphere not auto-fetched if trip field preference is false",
      (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([
      tripFieldIdStartTimestamp,
      tripFieldIdEndTimestamp,
      tripFieldIdCatches,
      tripFieldIdAtmosphere,
    ]);

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));
    expect(find.text("Atmosphere and Weather"), findsOneWidget);

    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(appManager.userPreferenceManager.autoSetTripFields).thenReturn(false);

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    verify(appManager.subscriptionManager.isFree).called(1);
    verify(appManager.userPreferenceManager.autoFetchAtmosphere).called(1);

    // 3 calls when catches are picked, and 2 calls rendering the auto-fill
    // checkbox header.
    verify(appManager.userPreferenceManager.autoSetTripFields).called(5);
    verifyNever(appManager.httpWrapper.get(any));
  });

  testWidgets("Atmosphere is auto-fetched", (tester) async {
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([
      tripFieldIdStartTimestamp,
      tripFieldIdEndTimestamp,
      tripFieldIdCatches,
      tripFieldIdAtmosphere,
    ]);

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    // Check AtmosphereInput data.
    await ensureVisibleAndSettle(tester, find.byType(AtmosphereInput));
    await tapAndSettle(tester, find.byType(AtmosphereInput));
    expect(find.text("Today at 10:30 AM"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(appManager.userPreferenceManager.autoSetTripFields).thenReturn(true);
    when(appManager.locationMonitor.currentLatLng)
        .thenReturn(const map.LatLng(1, 2));
    when(appManager.propertiesManager.visualCrossingApiKey).thenReturn("");

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    // Verify we try to fetch.
    verify(appManager.httpWrapper.get(any)).called(1);

    // Check AtmosphereInput data.
    await ensureVisibleAndSettle(tester, find.byType(AtmosphereInput));
    await tapAndSettle(tester, find.byType(AtmosphereInput));
    expect(find.text("Jan 1, 2020 at 5:00 AM"), findsOneWidget);
  });

  testWidgets("Saving edits updates existing trip", (tester) async {
    var trip = defaultTrip();

    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(trip),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager.addOrUpdate(
      captureAny,
      imageFiles: anyNamed("imageFiles"),
    ));
    result.called(1);

    var newTrip = result.captured.first as Trip;
    expect(newTrip, isNotNull);
    expect(newTrip, trip);
  });

  testWidgets("Saving empty trip doesn't set protobuf fields", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager.addOrUpdate(
      captureAny,
      imageFiles: anyNamed("imageFiles"),
    ));
    result.called(1);

    var newTrip = result.captured.first as Trip;
    expect(newTrip, isNotNull);
    expect(newTrip.hasId(), isTrue);
    expect(newTrip.hasStartTimestamp(), isTrue);
    expect(newTrip.hasEndTimestamp(), isTrue);
    expect(newTrip.hasTimeZone(), isTrue);
    expect(newTrip.catchIds, isEmpty);
    expect(newTrip.bodyOfWaterIds, isEmpty);
    expect(newTrip.gpsTrailIds, isEmpty);
    expect(newTrip.catchesPerSpecies, isEmpty);
    expect(newTrip.catchesPerAngler, isEmpty);
    expect(newTrip.catchesPerFishingSpot, isEmpty);
    expect(newTrip.catchesPerBait, isEmpty);
    expect(newTrip.customEntityValues, isEmpty);
    expect(newTrip.hasName(), isFalse);
    expect(newTrip.hasAtmosphere(), isFalse);
    expect(newTrip.hasNotes(), isFalse);
  });

  testWidgets("All Day checkboxes are checked on initial build",
      (tester) async {
    var trip = defaultTrip()
      ..startTimestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..endTimestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch);

    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(trip),
      appManager: appManager,
    ));

    // Verify time pickers are disabled.
    var timePickers = tester.widgetList<TimeLabel>(find.byType(TimeLabel));
    expect(timePickers.length, 2);
    expect(timePickers.first.enabled, isFalse);
    expect(timePickers.last.enabled, isFalse);

    // Verify "All Day" checkboxes are checked.
    var checkboxes =
        tester.widgetList<PaddedCheckbox>(find.byType(PaddedCheckbox)).toList();
    expect(checkboxes.length, 3); // First checkbox is for auto-set fields.
    expect(checkboxes[1].checked, isTrue);
    expect(checkboxes[2].checked, isTrue);
  });

  testWidgets("Checking All Day sets time of day to 0", (tester) async {
    var trip = defaultTrip();

    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(trip),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byType(PaddedCheckbox).at(1));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).at(2));
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager.addOrUpdate(
      captureAny,
      imageFiles: anyNamed("imageFiles"),
    ));
    result.called(1);

    var newTrip = result.captured.first as Trip;
    expect(newTrip, isNotNull);

    var startTimestamp = dateTimestamp(newTrip.startTimestamp.toInt());
    expect(startTimestamp.hour, 0);
    expect(startTimestamp.minute, 0);

    var endTimestamp = dateTimestamp(newTrip.endTimestamp.toInt());
    expect(endTimestamp.hour, 0);
    expect(endTimestamp.minute, 0);
  });

  testWidgets("Per entity not automatically updated if not showing",
      (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([
      Id(uuid: "0f012ca1-aae3-4aec-86e2-d85479eb6d66"), // Start
      Id(uuid: "c6afa4ff-add6-4a01-b69a-ba6f9b456c85"), // End
      Id(uuid: "d9a83fa6-926d-474d-8ddf-8d0e044d2ea4"), // Name
      Id(uuid: "0806fcc4-5d77-44b4-85e2-ebc066f37e12"), // Catches
    ]);

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
        anglerId: randomId(),
        fishingSpotId: randomId(),
        speciesId: randomId(),
        baits: [BaitAttachment(baitId: randomId())],
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    // Save changes, and verify per entities aren't set.
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager
        .addOrUpdate(captureAny, imageFiles: anyNamed("imageFiles")));
    result.called(1);

    var trip = result.captured.first as Trip;
    expect(trip.catchesPerAngler.isEmpty, isTrue);
    expect(trip.catchesPerFishingSpot.isEmpty, isTrue);
    expect(trip.catchesPerSpecies.isEmpty, isTrue);
    expect(trip.catchesPerBait.isEmpty, isTrue);
  });

  testWidgets("Per entity not automatically updated if auto-set is off",
      (tester) async {
    when(appManager.anglerManager.entityExists(any)).thenReturn(true);
    when(appManager.anglerManager.entity(any))
        .thenReturn(Angler(id: randomId()));
    when(appManager.anglerManager.displayName(any, any)).thenReturn("Me");

    when(appManager.baitManager.entityExists(any)).thenReturn(true);
    when(appManager.baitManager.entity(any)).thenReturn(Bait(id: randomId()));
    when(appManager.baitManager.displayName(any, any)).thenReturn("Bait");

    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(appManager.fishingSpotManager.entity(any))
        .thenReturn(FishingSpot(id: randomId()));
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("Spot");

    when(appManager.speciesManager.entityExists(any)).thenReturn(true);
    when(appManager.speciesManager.entity(any))
        .thenReturn(Species(id: randomId()));
    when(appManager.speciesManager.displayName(any, any)).thenReturn("Species");

    // Empty result shows all fields.
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.autoSetTripFields).thenReturn(false);

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
        anglerId: randomId(),
        fishingSpotId: randomId(),
        speciesId: randomId(),
        baits: [BaitAttachment(baitId: randomId())],
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    // Save changes, and verify per entities are set.
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager
        .addOrUpdate(captureAny, imageFiles: anyNamed("imageFiles")));
    result.called(1);

    var trip = result.captured.first as Trip;
    expect(trip.catchesPerAngler.isEmpty, isTrue);
    expect(trip.catchesPerFishingSpot.isEmpty, isTrue);
    expect(trip.catchesPerSpecies.isEmpty, isTrue);
    expect(trip.catchesPerBait.isEmpty, isTrue);
  });

  testWidgets("Per entity updated when catches are picked", (tester) async {
    when(appManager.anglerManager.entityExists(any)).thenReturn(true);
    when(appManager.anglerManager.entity(any))
        .thenReturn(Angler(id: randomId()));
    when(appManager.anglerManager.displayName(any, any)).thenReturn("Me");

    when(appManager.baitManager.entityExists(any)).thenReturn(true);
    when(appManager.baitManager.entity(any)).thenReturn(Bait(id: randomId()));
    when(appManager.baitManager.displayName(any, any)).thenReturn("Bait");

    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(appManager.fishingSpotManager.entity(any))
        .thenReturn(FishingSpot(id: randomId()));
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("Spot");

    when(appManager.speciesManager.entityExists(any)).thenReturn(true);
    when(appManager.speciesManager.entity(any))
        .thenReturn(Species(id: randomId()));
    when(appManager.speciesManager.displayName(any, any)).thenReturn("Species");

    // Empty result shows all fields.
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
        anglerId: randomId(),
        fishingSpotId: randomId(),
        speciesId: randomId(),
        baits: [BaitAttachment(baitId: randomId())],
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    // Save changes, and verify per entities are set.
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager
        .addOrUpdate(captureAny, imageFiles: anyNamed("imageFiles")));
    result.called(1);

    var trip = result.captured.first as Trip;
    expect(trip.catchesPerAngler.isNotEmpty, isTrue);
    expect(trip.catchesPerFishingSpot.isNotEmpty, isTrue);
    expect(trip.catchesPerSpecies.isNotEmpty, isTrue);
    expect(trip.catchesPerBait.isNotEmpty, isTrue);
  });

  testWidgets("Bodies of water not updated on picked if not showing",
      (tester) async {
    when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot(
      id: randomId(),
      bodyOfWaterId: randomId(),
    ));
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("Spot");

    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([
      Id(uuid: "0f012ca1-aae3-4aec-86e2-d85479eb6d66"), // Start
      Id(uuid: "c6afa4ff-add6-4a01-b69a-ba6f9b456c85"), // End
      Id(uuid: "d9a83fa6-926d-474d-8ddf-8d0e044d2ea4"), // Name
      Id(uuid: "0806fcc4-5d77-44b4-85e2-ebc066f37e12"), // Catches
    ]);

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
        anglerId: randomId(),
        fishingSpotId: randomId(),
        speciesId: randomId(),
        baits: [BaitAttachment(baitId: randomId())],
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    // Save changes, and verify per species aren't set.
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager
        .addOrUpdate(captureAny, imageFiles: anyNamed("imageFiles")));
    result.called(1);

    var trip = result.captured.first as Trip;
    expect(trip.bodyOfWaterIds.isEmpty, isTrue);
  });

  testWidgets("Bodies of water updated on picked", (tester) async {
    var id1 = randomId();
    var id2 = randomId();
    var invalidBowId = Id(uuid: "");
    var validBowId = randomId();

    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(appManager.fishingSpotManager.entity(id1)).thenReturn(FishingSpot(
      id: randomId(),
      bodyOfWaterId: invalidBowId,
    ));
    when(appManager.fishingSpotManager.entity(id2)).thenReturn(FishingSpot(
      id: randomId(),
      bodyOfWaterId: validBowId,
    ));
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("Spot");

    // Empty result shows all fields.
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);

    var catches = [
      Catch(
        id: randomId(),
        fishingSpotId: id1,
      ),
      Catch(
        id: randomId(),
        fishingSpotId: id2,
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    // Save changes, and verify per species aren't set.
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager
        .addOrUpdate(captureAny, imageFiles: anyNamed("imageFiles")));
    result.called(1);

    var trip = result.captured.first as Trip;
    expect(trip.bodyOfWaterIds.length, 1);
  });

  testWidgets("Calculated bodies of water doesn't update when empty",
      (tester) async {
    var id1 = randomId();
    var id2 = randomId();
    var invalidBowId1 = Id(uuid: "");
    var invalidBowId2 = Id(uuid: "");

    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(appManager.fishingSpotManager.entity(id1)).thenReturn(FishingSpot(
      id: randomId(),
      bodyOfWaterId: invalidBowId1,
    ));
    when(appManager.fishingSpotManager.entity(id2)).thenReturn(FishingSpot(
      id: randomId(),
      bodyOfWaterId: invalidBowId2,
    ));
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("Spot");

    // Empty result shows all fields.
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);

    var catches = [
      Catch(
        id: randomId(),
        fishingSpotId: id1,
      ),
      Catch(
        id: randomId(),
        fishingSpotId: id2,
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    // Select a catch to trigger auto updates.
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));

    // Save changes, and verify per species aren't set.
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager
        .addOrUpdate(captureAny, imageFiles: anyNamed("imageFiles")));
    result.called(1);

    var trip = result.captured.first as Trip;
    expect(trip.bodyOfWaterIds.isEmpty, isTrue);
  });

  testWidgets("Catch images not updated on picked if not showing",
      (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([
      Id(uuid: "0f012ca1-aae3-4aec-86e2-d85479eb6d66"), // Start
      Id(uuid: "c6afa4ff-add6-4a01-b69a-ba6f9b456c85"), // End
      Id(uuid: "d9a83fa6-926d-474d-8ddf-8d0e044d2ea4"), // Name
      Id(uuid: "0806fcc4-5d77-44b4-85e2-ebc066f37e12"), // Catches
    ]);

    await stubImages(appManager, tester, [
      "flutter_logo.png",
      "anglers_log_logo.png",
      "android_logo.png",
    ]);

    // Setup catches and editing trip to have the same photo so we can verify
    // duplicate photos are displayed, nor added to the trip.
    var trip = defaultTrip()
      ..catchIds.clear()
      ..imageNames.add("flutter_logo.png");

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
        imageNames: [
          "flutter_logo.png",
          "anglers_log_logo.png",
          "android_logo.png",
        ],
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(trip),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // We aren't tracking images, nothing should be shown.
    expect(find.byType(Image), findsNothing);

    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // The two new photos should not be shown since we aren't tracking photos.
    expect(find.byType(Image), findsNothing);

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager
        .addOrUpdate(any, imageFiles: captureAnyNamed("imageFiles")));
    result.called(1);

    var images = result.captured.first as List<File>;
    expect(images.isEmpty, isTrue);
  });

  testWidgets("Catch images updated on picked", (tester) async {
    await stubImages(appManager, tester, [
      "flutter_logo.png",
      "anglers_log_logo.png",
      "android_logo.png",
    ]);

    // Setup catches and editing trip to have the same photo so we can verify
    // duplicate photos are displayed, nor added to the trip.
    var trip = defaultTrip()
      ..catchIds.clear()
      ..imageNames.add("flutter_logo.png");

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
        imageNames: [
          "anglers_log_logo.png",
          "android_logo.png",
          "android_logo.png", // Duplicate should not show in the UI.
        ],
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);

    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(trip),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // Until catches are selected, only old trip photos are shown.
    expect(find.byType(Image), findsOneWidget);

    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // The two new photos should be shown. The one duplicate should not.
    expect(find.byType(Image), findsNWidgets(3));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager
        .addOrUpdate(any, imageFiles: captureAnyNamed("imageFiles")));
    result.called(1);

    var images = result.captured.first as List<File>;
    expect(images.length, 3);
  });

  testWidgets("Time is updated when catches are picked", (tester) async {
    appManager.stubCurrentTime(dateTime(2020, 1, 1, 3, 30));

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
        timeZone: defaultTimeZone,
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 2, 1, 8).millisecondsSinceEpoch),
        timeZone: defaultTimeZone,
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 3, 1, 15).millisecondsSinceEpoch),
        timeZone: defaultTimeZone,
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);
    when(appManager.catchManager.id(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.id);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    expect(find.text("Jan 1, 2020"), findsNWidgets(2));
    expect(find.text("3:30 AM"), findsNWidgets(2));

    await ensureVisibleAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.text("Jan 1, 2020"), findsOneWidget);
    expect(find.text("Mar 1, 2020"), findsOneWidget);
    expect(find.text("5:00 AM"), findsOneWidget);
    expect(find.text("3:00 PM"), findsOneWidget);
  });

  testWidgets("Time is not updated when auto-set is off", (tester) async {
    appManager.stubCurrentTime(dateTime(2020, 1, 1, 3, 30));

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
        timeZone: defaultTimeZone,
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 2, 1, 8).millisecondsSinceEpoch),
        timeZone: defaultTimeZone,
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 3, 1, 15).millisecondsSinceEpoch),
        timeZone: defaultTimeZone,
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);
    when(appManager.catchManager.id(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.id);

    when(appManager.userPreferenceManager.autoSetTripFields).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    expect(find.text("Jan 1, 2020"), findsNWidgets(2));
    expect(find.text("3:30 AM"), findsNWidgets(2));

    await ensureVisibleAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.text("Jan 1, 2020"), findsNWidgets(2));
    expect(find.text("3:30 AM"), findsNWidgets(2));
  });

  testWidgets("Time is not updated if catches picked is empty", (tester) async {
    appManager.stubCurrentTime(dateTime(2020, 1, 1, 3, 30));

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 2, 1, 8).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 3, 1, 15).millisecondsSinceEpoch),
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
    )).thenReturn(catches);
    when(appManager.catchManager.id(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.id);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    expect(find.text("Jan 1, 2020"), findsNWidgets(2));
    expect(find.text("3:30 AM"), findsNWidgets(2));

    await ensureVisibleAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.text("Jan 1, 2020"), findsNWidgets(2));
    expect(find.text("3:30 AM"), findsNWidgets(2));
  });

  testWidgets("Only date is updated when catches picked and all-day is checked",
      (tester) async {
    appManager.stubCurrentTime(dateTime(2020, 1, 1, 3, 30));

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 2, 1, 8).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 3, 1, 15).millisecondsSinceEpoch),
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn(catches);
    when(appManager.catchManager.id(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.id);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    expect(find.text("Jan 1, 2020"), findsNWidgets(2));
    expect(find.text("3:30 AM"), findsNWidgets(2));

    await tapAndSettle(tester, find.byType(Checkbox).at(1));
    await tapAndSettle(tester, find.byType(Checkbox).at(2));

    expect(find.text("12:00 AM"), findsNWidgets(2));

    await ensureVisibleAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.text("Jan 1, 2020"), findsOneWidget);
    expect(find.text("Mar 1, 2020"), findsOneWidget);
    expect(find.text("5:00 AM"), findsNothing);
    expect(find.text("3:00 PM"), findsNothing);
    expect(find.text("12:00 AM"), findsNWidgets(2));
  });

  testWidgets("Timestamps show if not included in tracked IDs", (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds)
        .thenReturn([randomId()]);
    appManager.stubCurrentTime(dateTime(2020, 1, 1, 3, 30));

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    expect(find.text("Jan 1, 2020"), findsNWidgets(2));
    expect(find.text("3:30 AM"), findsNWidgets(2));
  });
}
