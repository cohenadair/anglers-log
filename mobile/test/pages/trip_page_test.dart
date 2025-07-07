import 'package:collection/src/iterable_extensions.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/trip_page.dart';
import 'package:mobile/utils/date_time_utils.dart' as date_time_utils;
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/atmosphere_wrap.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  late List<Catch> catches;
  late List<Angler> anglers;
  late List<BodyOfWater> bodiesOfWater;
  late List<Species> species;
  late List<FishingSpot> fishingSpots;
  late List<Bait> baits;
  late List<WaterClarity> waterClarities;
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

  List<WaterClarity> defaultWaterClarities() {
    return [
      WaterClarity(id: randomId(), name: "Clear"),
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
      waterClarityId: waterClarities[0].id,
      waterDepth: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.meters,
          value: 12,
        ),
      ),
      waterTemperature: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.celsius,
          value: 65,
        ),
      ),
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

  setUp(() async {
    managers = await StubbedManagers.create();

    catches = defaultCatches();
    atmosphere = defaultAtmosphere();
    anglers = defaultAnglers();
    bodiesOfWater = defaultBodiesOfWater();
    species = defaultSpecies();
    fishingSpots = defaultFishingSpots();
    baits = defaultBaits();
    waterClarities = defaultWaterClarities();

    when(managers.anglerManager.entityExists(anglers[0].id)).thenReturn(true);
    when(managers.anglerManager.entity(anglers[0].id)).thenReturn(anglers[0]);
    when(managers.anglerManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(managers.baitManager.variantFromAttachment(any))
        .thenAnswer((invocation) {
      var attachment = invocation.positionalArguments[0];
      var bait = baits.firstWhereOrNull((e) => e.id == attachment?.baitId);
      return bait?.variants
          .firstWhereOrNull((e) => e.id == attachment.variantId);
    });
    when(managers.baitManager.attachmentDisplayValue(any, any))
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

    when(managers.bodyOfWaterManager.list(any)).thenReturn(bodiesOfWater);
    when(managers.bodyOfWaterManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(managers.catchManager.list(any)).thenReturn(catches);
    when(managers.catchManager.displayName(any, any)).thenAnswer((invocation) =>
        date_time_utils.formatTimestamp(invocation.positionalArguments[0],
            invocation.positionalArguments[1].timestamp.toInt(), null));
    when(managers.catchManager.entity(any)).thenAnswer((invocation) => catches
        .firstWhereOrNull((e) => e.id == invocation.positionalArguments.first));

    when(managers.customEntityManager.entityExists(any)).thenReturn(false);

    when(managers.fishingSpotManager.entityExists(fishingSpots[0].id))
        .thenReturn(true);
    when(managers.fishingSpotManager.entity(fishingSpots[0].id))
        .thenReturn(fishingSpots[0]);
    when(managers.fishingSpotManager.displayName(
      any,
      any,
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
      includeLatLngLabels: anyNamed("includeLatLngLabels"),
    )).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(managers.ioWrapper.isAndroid).thenReturn(false);

    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    when(managers.speciesManager.entityExists(species[0].id)).thenReturn(true);
    when(managers.speciesManager.entity(species[0].id)).thenReturn(species[0]);
    when(managers.speciesManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(managers.speciesManager.entityExists(species[0].id)).thenReturn(true);
    when(managers.speciesManager.entity(species[0].id)).thenReturn(species[0]);
    when(managers.speciesManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(managers.waterClarityManager.entityExists(null)).thenReturn(false);
    when(managers.waterClarityManager.entityExists(waterClarities[0].id))
        .thenReturn(true);
    when(managers.waterClarityManager.entity(waterClarities[0].id))
        .thenReturn(waterClarities[0]);
    when(managers.waterClarityManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(managers.tripManager.deleteMessage(any, any)).thenReturn("Delete");
    when(managers.tripManager.numberOfCatches(any)).thenReturn(1);

    when(managers.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
  });

  testWidgets("All fields are shown", (tester) async {
    when(managers.tripManager.entity(any)).thenReturn(defaultTrip());

    var context = await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()),
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
    expect(find.text("Clear, 65\u00B0C, 12 m"), findsOneWidget);
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
    when(managers.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..name = "Passed In Trip"),
    );

    expect(find.text("Passed In Trip"), findsOneWidget);
  });

  testWidgets("Bodies of water hidden", (tester) async {
    when(managers.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..bodyOfWaterIds.clear()),
    );

    expect(find.byType(ChipWrap), findsNothing);
  });

  testWidgets("Catches hidden", (tester) async {
    when(managers.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..catchIds.clear()),
    );

    expect(find.byType(ImageListItem), findsNothing);
  });

  testWidgets("Catch is skipped if it doesn't exist", (tester) async {
    when(managers.tripManager.entity(any)).thenReturn(null);
    when(managers.catchManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()),
    );

    expect(find.byType(ImageListItem), findsNothing);
  });

  testWidgets("Atmosphere hidden", (tester) async {
    when(managers.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..clearAtmosphere()),
    );

    expect(find.byType(AtmosphereWrap), findsNothing);
  });

  testWidgets("Bait is skipped if it doesn't exist", (tester) async {
    when(managers.tripManager.entity(any)).thenReturn(null);
    when(managers.baitManager.attachmentDisplayValue(any, any)).thenReturn("");

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()),
    );

    expect(find.text("Catches Per Bait", skipOffstage: false), findsNothing);
  });

  testWidgets("Skunked hidden", (tester) async {
    when(managers.tripManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..clearAtmosphere()),
    );

    expect(find.text("Skunked"), findsNothing);
  });

  testWidgets("Skunked shown", (tester) async {
    when(managers.tripManager.entity(any)).thenReturn(null);
    when(managers.tripManager.numberOfCatches(any)).thenReturn(0);

    await pumpContext(
      tester,
      (_) => TripPage(defaultTrip()..clearAtmosphere()),
    );

    expect(find.text("SKUNKED"), findsOneWidget);
  });

  testWidgets("Share text without name", (tester) async {
    when(managers.tripManager.entity(any))
        .thenReturn(defaultTrip()..clearName());
    when(managers.sharePlusWrapper.share(any, any))
        .thenAnswer((_) => Future.value(null));
    when(managers.tripManager.numberOfCatches(any)).thenReturn(5);

    await pumpContext(tester, (_) => TripPage(Trip()));
    await tapAndSettle(tester, find.byIcon(Icons.ios_share));

    var result = verify(managers.sharePlusWrapper.share(captureAny, any));
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
    when(managers.tripManager.entity(any)).thenReturn(defaultTrip());
    when(managers.sharePlusWrapper.share(any, any))
        .thenAnswer((_) => Future.value(null));
    when(managers.tripManager.numberOfCatches(any)).thenReturn(5);
    when(managers.tripManager.name(any)).thenReturn("Test Trip");

    await pumpContext(tester, (_) => TripPage(Trip()));
    await tapAndSettle(tester, find.byIcon(Icons.ios_share));

    var result = verify(managers.sharePlusWrapper.share(captureAny, any));
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
    when(managers.tripManager.entity(any)).thenReturn(Trip(
      id: randomId(),
      startTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime.now().millisecondsSinceEpoch - 10000),
    ));

    await pumpContext(
      tester,
      (_) => TripPage(Trip()),
    );

    expect(find.byType(MinChip), findsNothing);
  });

  testWidgets("GPS trails that don't exist are hidden", (tester) async {
    when(managers.gpsTrailManager.entity(any)).thenReturn(null);
    when(managers.tripManager.entity(any)).thenReturn(Trip(
      id: randomId(),
      startTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime.now().millisecondsSinceEpoch - 10000),
      gpsTrailIds: [randomId()],
    ));

    await pumpContext(
      tester,
      (_) => TripPage(Trip()),
    );

    expect(find.byType(MinChip), findsNothing);
  });

  testWidgets("GPS trails shown", (tester) async {
    when(managers.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn(null);
    when(managers.gpsTrailManager.displayName(any, any)).thenReturn("Trail");
    when(managers.gpsTrailManager.entity(any)).thenReturn(GpsTrail());
    when(managers.tripManager.entity(any)).thenReturn(Trip(
      id: randomId(),
      startTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      endTimestamp: Int64(DateTime.now().millisecondsSinceEpoch - 10000),
      gpsTrailIds: [randomId(), randomId()],
    ));

    await pumpContext(
      tester,
      (_) => TripPage(Trip()),
    );

    expect(find.byType(MinChip), findsNWidgets(2));
  });
}
