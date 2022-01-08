import 'package:collection/src/iterable_extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_trip_page.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/atmosphere_input.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  late List<Catch> catches;
  late List<Angler> anglers;
  late List<BodyOfWater> bodiesOfWater;
  late List<Species> species;
  late List<FishingSpot> fishingSpots;
  late List<Bait> baits;
  late Atmosphere atmosphere;

  Atmosphere defaultAtmosphere() {
    return Atmosphere(
      temperature: Measurement(
        unit: Unit.celsius,
        value: 15,
      ),
      skyConditions: [SkyCondition.cloudy],
      windSpeed: Measurement(
        unit: Unit.kilometers_per_hour,
        value: 6.5,
      ),
      windDirection: Direction.north,
      pressure: Measurement(
        unit: Unit.millibars,
        value: 1000,
      ),
      humidity: Measurement(
        unit: Unit.percent,
        value: 50,
      ),
      visibility: Measurement(
        unit: Unit.kilometers,
        value: 10,
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

  List<Catch> defaultCatches() {
    return [
      Catch(
        id: randomId(),
        timestamp: Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(DateTime(2020, 2, 1).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(DateTime(2020, 3, 1).millisecondsSinceEpoch),
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
      startTimestamp: Int64(DateTime(2020, 1, 1, 9).millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime(2020, 1, 3, 17).millisecondsSinceEpoch),
      name: "Test Trip",
      catchIds: [catches[0].id, catches[2].id],
      bodyOfWaterIds: [bodiesOfWater[2].id],
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
        return null;
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

    when(appManager.catchManager.list(any)).thenReturn(catches);
    when(appManager.catchManager.displayName(any, any)).thenAnswer(
        (invocation) => formatTimestamp(invocation.positionalArguments[0],
            invocation.positionalArguments[1].timestamp.toInt()));

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

    when(appManager.locationMonitor.currentLocation).thenReturn(null);

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
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);
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
    when(appManager.locationMonitor.currentLocation)
        .thenReturn(const LatLng(1, 2));

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
    expect(newTrip.catchIds, isEmpty);
    expect(newTrip.bodyOfWaterIds, isEmpty);
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
      ..startTimestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch)
      ..endTimestamp = Int64(DateTime(2020, 1, 1).millisecondsSinceEpoch);

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
        tester.widgetList<PaddedCheckbox>(find.byType(PaddedCheckbox));
    expect(checkboxes.length, 2);
    expect(checkboxes.first.checked, isTrue);
    expect(checkboxes.last.checked, isTrue);
  });

  testWidgets("Checking All Day sets time of day to 0", (tester) async {
    var trip = defaultTrip();

    await tester.pumpWidget(Testable(
      (_) => SaveTripPage.edit(trip),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byType(PaddedCheckbox).first);
    await tapAndSettle(tester, find.byType(PaddedCheckbox).last);
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.tripManager.addOrUpdate(
      captureAny,
      imageFiles: anyNamed("imageFiles"),
    ));
    result.called(1);

    var newTrip = result.captured.first as Trip;
    expect(newTrip, isNotNull);

    var startTimestamp =
        DateTime.fromMillisecondsSinceEpoch(newTrip.startTimestamp.toInt());
    expect(startTimestamp.hour, 0);
    expect(startTimestamp.minute, 0);

    var endTimestamp =
        DateTime.fromMillisecondsSinceEpoch(newTrip.endTimestamp.toInt());
    expect(endTimestamp.hour, 0);
    expect(endTimestamp.minute, 0);
  });

  testWidgets("Time is updated when catches are picked", (tester) async {
    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime.fromMillisecondsSinceEpoch(
      150000000000, // Thursday, October 3, 1974 2:40:00 AM GMT
      isUtc: true,
    ));

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(DateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(DateTime(2020, 2, 1, 8).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(DateTime(2020, 3, 1, 15).millisecondsSinceEpoch),
      ),
    ];
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      sortOrder: anyNamed("sortOrder"),
      catchIds: anyNamed("catchIds"),
    )).thenReturn(catches);
    when(appManager.catchManager.id(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.id);

    await tester.pumpWidget(Testable(
      (_) => const SaveTripPage(),
      appManager: appManager,
    ));

    expect(find.text("Oct 3, 1974"), findsNWidgets(2));
    expect(find.text("2:40 AM"), findsNWidgets(2));

    await ensureVisibleAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.text("Jan 1, 2020"), findsOneWidget);
    expect(find.text("Mar 1, 2020"), findsOneWidget);
    expect(find.text("5:00 AM"), findsOneWidget);
    expect(find.text("3:00 PM"), findsOneWidget);
  });

  testWidgets("Time is not updated if catches picked is empty", (tester) async {
    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime.fromMillisecondsSinceEpoch(
      150000000000, // Thursday, October 3, 1974 2:40:00 AM GMT
      isUtc: true,
    ));

    var catches = [
      Catch(
        id: randomId(),
        timestamp: Int64(DateTime(2020, 1, 1, 5).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(DateTime(2020, 2, 1, 8).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(DateTime(2020, 3, 1, 15).millisecondsSinceEpoch),
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

    expect(find.text("Oct 3, 1974"), findsNWidgets(2));
    expect(find.text("2:40 AM"), findsNWidgets(2));

    await ensureVisibleAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.text("No catches"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.text("Oct 3, 1974"), findsNWidgets(2));
    expect(find.text("2:40 AM"), findsNWidgets(2));
  });
}
