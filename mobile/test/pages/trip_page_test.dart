import 'package:collection/src/iterable_extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/trip_page.dart';
import 'package:mobile/utils/date_time_utils.dart' as date_time_utils;
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/atmosphere_wrap.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
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
      temperature: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.celsius,
          value: 15,
        ),
      ),
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
        timestamp: Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 2, 1).millisecondsSinceEpoch),
      ),
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime(2020, 3, 1).millisecondsSinceEpoch),
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

    when(appManager.catchManager.list(any)).thenReturn(catches);
    when(appManager.catchManager.displayName(any, any)).thenAnswer(
        (invocation) => date_time_utils.formatTimestamp(
            invocation.positionalArguments[0],
            invocation.positionalArguments[1].timestamp.toInt(),
            null));
    when(appManager.catchManager.entity(any)).thenAnswer((invocation) => catches
        .firstWhereOrNull((e) => e.id == invocation.positionalArguments.first));

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

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    when(appManager.speciesManager.entityExists(species[0].id))
        .thenReturn(true);
    when(appManager.speciesManager.entity(species[0].id))
        .thenReturn(species[0]);
    when(appManager.speciesManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(appManager.speciesManager.entityExists(species[0].id))
        .thenReturn(true);
    when(appManager.speciesManager.entity(species[0].id))
        .thenReturn(species[0]);
    when(appManager.speciesManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(appManager.tripManager.deleteMessage(any, any)).thenReturn("Delete");
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(1);

    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);
  });

  testWidgets("All fields are shown", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(defaultTrip());

    var context = await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()),
      appManager: appManager,
    );

    expect(
      find.listHeadingText(context,
          text: "Jan 1, 2020 at 9:00 AM to Jan 3, 2020 at 5:00 PM"),
      findsOneWidget,
    );
    expect(find.widgetWithText(TitleLabel, "Test Trip"), findsOneWidget);
    expect(
      find.secondaryText(context, text: "Test notes for a test trip."),
      findsOneWidget,
    );
    expect(find.widgetWithText(Chip, "BOW 3"), findsOneWidget);
    expect(find.text("Jan 1, 2020 at 12:00 AM"), findsOneWidget);
    expect(find.text("Mar 1, 2020 at 12:00 AM"), findsOneWidget);
    expect(find.byType(AtmosphereWrap), findsOneWidget);
    expect(find.text("Me"), findsOneWidget);
    expect(find.text("15"), findsOneWidget);
    expect(find.text("Rainbow Trout"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
    expect(find.text("Spot 1", skipOffstage: false), findsOneWidget);
    expect(find.text("10", skipOffstage: false), findsOneWidget);
    expect(find.text("Worm (Red)", skipOffstage: false), findsOneWidget);
    expect(find.text("20", skipOffstage: false), findsOneWidget);
  });

  testWidgets("Null TripManager Trip uses passed in Trip", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..name = "Passed In Trip"),
      appManager: appManager,
    );

    expect(find.text("Passed In Trip"), findsOneWidget);
  });

  testWidgets("Bodies of water hidden", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..bodyOfWaterIds.clear()),
      appManager: appManager,
    );

    expect(find.byType(ChipWrap), findsNothing);
  });

  testWidgets("Catches hidden", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..catchIds.clear()),
      appManager: appManager,
    );

    expect(find.byType(ImageListItem), findsNothing);
  });

  testWidgets("Catch is skipped if it doesn't exist", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(null);
    when(appManager.catchManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()),
      appManager: appManager,
    );

    expect(find.byType(ImageListItem), findsNothing);
  });

  testWidgets("Atmosphere hidden", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..clearAtmosphere()),
      appManager: appManager,
    );

    expect(find.byType(AtmosphereWrap), findsNothing);
  });

  testWidgets("Bait is skipped if it doesn't exist", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(null);
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("");

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()),
      appManager: appManager,
    );

    expect(find.text("Catches Per Bait", skipOffstage: false), findsNothing);
  });

  testWidgets("Skunked hidden", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..clearAtmosphere()),
      appManager: appManager,
    );

    expect(find.text("Skunked"), findsNothing);
  });

  testWidgets("Skunked shown", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(null);
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(0);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..clearAtmosphere()),
      appManager: appManager,
    );

    expect(find.text("SKUNKED"), findsOneWidget);
  });

  testWidgets("Share text without name", (tester) async {
    when(appManager.tripManager.entity(any))
        .thenReturn(defaultTrip()..clearName());
    when(appManager.sharePlusWrapper.share(any))
        .thenAnswer((_) => Future.value(null));
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(5);

    await pumpContext(tester, (_) => TripPage(Trip()), appManager: appManager);
    await tapAndSettle(tester, find.byIcon(Icons.ios_share));

    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    var text = result.captured.first as String;
    expect(
      text,
      "Jan 1, 2020 at 9:00 AM to Jan 3, 2020 at 5:00 PM\n"
      "Catches: 5\n\n"
      "Shared with #AnglersLogApp for iOS.",
    );
  });

  testWidgets("Share text with name", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(defaultTrip());
    when(appManager.sharePlusWrapper.share(any))
        .thenAnswer((_) => Future.value(null));
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(5);
    when(appManager.tripManager.name(any)).thenReturn("Test Trip");

    await pumpContext(tester, (_) => TripPage(Trip()), appManager: appManager);
    await tapAndSettle(tester, find.byIcon(Icons.ios_share));

    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    var text = result.captured.first as String;
    expect(
      text,
      "Test Trip\n"
      "Jan 1, 2020 at 9:00 AM to Jan 3, 2020 at 5:00 PM\n"
      "Catches: 5\n\n"
      "Shared with #AnglersLogApp for iOS.",
    );
  });

  testWidgets("GPS trails hidden", (tester) async {
    when(appManager.tripManager.entity(any)).thenReturn(Trip(
      id: randomId(),
      startTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime.now().millisecondsSinceEpoch - 10000),
    ));

    await pumpContext(
      tester,
      (_) => TripPage(Trip()),
      appManager: appManager,
    );

    expect(find.byType(MinChip), findsNothing);
  });

  testWidgets("GPS trails that don't exist are hidden", (tester) async {
    when(appManager.gpsTrailManager.entity(any)).thenReturn(null);
    when(appManager.tripManager.entity(any)).thenReturn(Trip(
      id: randomId(),
      startTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime.now().millisecondsSinceEpoch - 10000),
      gpsTrailIds: [randomId()],
    ));

    await pumpContext(
      tester,
      (_) => TripPage(Trip()),
      appManager: appManager,
    );

    expect(find.byType(MinChip), findsNothing);
  });

  testWidgets("GPS trails shown", (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn(null);
    when(appManager.gpsTrailManager.displayName(any, any)).thenReturn("Trail");
    when(appManager.gpsTrailManager.entity(any)).thenReturn(GpsTrail());
    when(appManager.tripManager.entity(any)).thenReturn(Trip(
      id: randomId(),
      startTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime.now().millisecondsSinceEpoch - 10000),
      gpsTrailIds: [randomId(), randomId()],
    ));

    await pumpContext(
      tester,
      (_) => TripPage(Trip()),
      appManager: appManager,
    );

    expect(find.byType(MinChip), findsNWidgets(2));
  });
}
