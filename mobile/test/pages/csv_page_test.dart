import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:mobile/pages/csv_page.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/trip_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  MockFile stubFile([int writeAsStringDelay = 0]) {
    var mockFile = MockFile();
    when(mockFile.writeAsString(any, flush: anyNamed("flush"))).thenAnswer(
      (_) => Future.delayed(
        Duration(milliseconds: writeAsStringDelay),
        () => mockFile,
      ),
    );
    when(mockFile.existsSync()).thenReturn(false);
    when(mockFile.path).thenReturn("");
    when(managers.lib.ioWrapper.file(any)).thenReturn(mockFile);
    return mockFile;
  }

  setUp(() async {
    managers = await StubbedManagers.create();
    stubFile();

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    when(managers.csvWrapper.convert(any)).thenReturn("");

    when(managers.customEntityManager.entityExists(any)).thenReturn(false);

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);

    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(
      managers.userPreferenceManager.tideHeightSystem,
    ).thenReturn(MeasurementSystem.metric);

    when(managers.catchManager.catches(any)).thenReturn([]);

    when(managers.tripManager.list()).thenReturn([]);

    when(
      managers.pathProviderWrapper.temporaryPath,
    ).thenAnswer((_) => Future.value(""));

    when(
      managers.sharePlusWrapper.shareFiles(any, any),
    ).thenAnswer((_) => Future.value());
  });

  Atmosphere testAtmosphere() {
    return Atmosphere(
      temperature: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.celsius, value: 15),
      ),
      skyConditions: [SkyCondition.cloudy, SkyCondition.drizzle],
      windSpeed: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.kilometers_per_hour, value: 6.5),
      ),
      windDirection: Direction.north,
      pressure: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.millibars, value: 1000),
      ),
      humidity: MultiMeasurement(
        mainValue: Measurement(unit: Unit.percent, value: 50),
      ),
      visibility: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(unit: Unit.kilometers, value: 10),
      ),
      moonPhase: MoonPhase.full,
      sunriseTimestamp: Int64(1624348800000),
      sunsetTimestamp: Int64(1624381200000),
    );
  }

  testWidgets("Feedback description shows an error", (tester) async {
    await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));
    expect(
      find.text("Please select at least one export option above."),
      findsOneWidget,
    );
  });

  testWidgets("Feedback description is successful", (tester) async {
    await pumpContext(tester, (_) => CsvPage());
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));
    expect(find.text("Success!"), findsOneWidget);
  });

  testWidgets("Feedback shows loading on action tap", (tester) async {
    stubFile(250);
    await pumpContext(tester, (_) => CsvPage());
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tester.tap(find.text("EXPORT"));
    await tester.pump();
    expect(find.byType(Loading), findsOneWidget);

    // Drain pending timer.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
  });

  testWidgets("Feedback shows ProPage on tap", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(
      managers.lib.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value());
    await pumpContext(tester, (_) => CsvPage());
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));
    expect(find.byType(AnglersLogProPage), findsOneWidget);
  });

  testWidgets("Only catches are exported", (tester) async {
    await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.sharePlusWrapper.shareFiles(captureAny, any));
    result.called(1);
    expect((result.captured.first as List).length, 1);

    result = verify(managers.lib.ioWrapper.file(captureAny));
    expect((result.captured.first as String).contains("catches.csv"), isTrue);
  });

  testWidgets("Only trips are exported", (tester) async {
    await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.sharePlusWrapper.shareFiles(captureAny, any));
    result.called(1);
    expect((result.captured.first as List).length, 1);

    result = verify(managers.lib.ioWrapper.file(captureAny));
    expect((result.captured.first as String).contains("trips.csv"), isTrue);
  });

  testWidgets("All files are exported", (tester) async {
    await pumpContext(tester, (_) => CsvPage());
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.sharePlusWrapper.shareFiles(captureAny, any));
    result.called(1);
    expect((result.captured.first as List).length, 2);
  });

  testWidgets("Untracked catch fields are excluded", (tester) async {
    when(
      managers.userPreferenceManager.catchFieldIds,
    ).thenReturn([catchFieldIdTimestamp]);
    when(
      managers.catchManager.catches(any),
    ).thenReturn([Catch(id: randomId(), timestamp: Int64(5000))]);

    await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(csvList[0].length, 2);
    expect(csvList[1].length, 2);
  });

  testWidgets("Untracked atmosphere fields are excluded", (tester) async {
    when(
      managers.userPreferenceManager.catchFieldIds,
    ).thenReturn([catchFieldIdTimestamp, catchFieldIdAtmosphere]);
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([
      tripFieldIdStartTimestamp,
      tripFieldIdEndTimestamp,
      tripFieldIdAtmosphere,
    ]);
    when(managers.catchManager.catches(any)).thenReturn([
      Catch(
        id: randomId(),
        timestamp: Int64(5000),
        atmosphere: testAtmosphere(),
      ),
    ]);
    when(managers.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        startTimestamp: Int64(5000),
        endTimestamp: Int64(10000),
        atmosphere: testAtmosphere(),
      ),
    ]);

    // Track only one atmosphere field (empty preferences will show all fields).
    when(
      managers.userPreferenceManager.atmosphereFieldIds,
    ).thenReturn([atmosphereFieldIdSkyCondition]);

    await pumpContext(tester, (_) => CsvPage());
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    // Verify atmosphere fields are included.
    var result = verify(managers.csvWrapper.convert(captureAny));
    result.called(2);

    // Catches.
    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(csvList[0].length, 3); // Date, time, and sky conditions.
    expect(csvList[0][2], "Sky Conditions");
    expect(csvList[1][2], "Cloudy, Drizzle");

    // Trips.
    csvList = result.captured.last as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(csvList[0].length, 5); // Date, time, and sky conditions.
    expect(csvList[0][4], "Sky Conditions");
    expect(csvList[1][4], "Cloudy, Drizzle");

    var context = await pumpContext(tester, (_) => CsvPage());

    // Track all other fields, verifying sky conditions is hidden.
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn(
      allAtmosphereFields(context).map((e) => e.id).toList()
        ..remove(atmosphereFieldIdSkyCondition),
    );

    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    // Verify atmosphere fields are included.
    result = verify(managers.csvWrapper.convert(captureAny));
    result.called(2);

    // Catches.
    csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    // -1 for sky conditions, +2 for date and time.
    expect(csvList[0].length, allAtmosphereFields(context).length - 1 + 2);
    expect(csvList[0][2], "Temperature");
    expect(csvList[0][3], "Wind Direction");
    expect(csvList[0][4], "Wind Speed");
    expect(csvList[0][5], "Atmospheric Pressure");
    expect(csvList[0][6], "Air Visibility");
    expect(csvList[0][7], "Air Humidity");
    expect(csvList[0][8], "Moon Phase");
    expect(csvList[0][9], "Time of Sunrise");
    expect(csvList[0][10], "Time of Sunset");
    expect(csvList[1][2], "15°C");
    expect(csvList[1][3], "N");
    expect(csvList[1][4], "6.5 km/h");
    expect(csvList[1][5], "1000 MB");
    expect(csvList[1][6], "10 km");
    expect(csvList[1][7], "50%");
    expect(csvList[1][8], "Full");
    expect(csvList[1][9], "4:00 AM");
    expect(csvList[1][10], "1:00 PM");

    // Trips.
    csvList = result.captured.last as List<List<dynamic>>;
    expect(csvList.length, 2);
    // -1 for sky conditions, +4 for start/end date and start/end time.
    expect(csvList[0].length, allAtmosphereFields(context).length - 1 + 4);
    expect(csvList[0][4], "Temperature");
    expect(csvList[0][5], "Wind Direction");
    expect(csvList[0][6], "Wind Speed");
    expect(csvList[0][7], "Atmospheric Pressure");
    expect(csvList[0][8], "Air Visibility");
    expect(csvList[0][9], "Air Humidity");
    expect(csvList[0][10], "Moon Phase");
    expect(csvList[0][11], "Time of Sunrise");
    expect(csvList[0][12], "Time of Sunset");
    expect(csvList[1][4], "15°C");
    expect(csvList[1][5], "N");
    expect(csvList[1][6], "6.5 km/h");
    expect(csvList[1][7], "1000 MB");
    expect(csvList[1][8], "10 km");
    expect(csvList[1][9], "50%");
    expect(csvList[1][10], "Full");
    expect(csvList[1][11], "4:00 AM");
    expect(csvList[1][12], "1:00 PM");
  });

  testWidgets("All catch fields are included, preferences empty", (
    tester,
  ) async {
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(
      managers.anglerManager.displayNameFromId(any, any),
    ).thenReturn("Cohen");
    when(
      managers.baitManager.attachmentsDisplayValues(any, any),
    ).thenReturn(["Stone Fly", "Bugger"]);
    when(
      managers.fishingSpotManager.displayNameFromId(
        any,
        any,
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
        useLatLngFallback: anyNamed("useLatLngFallback"),
      ),
    ).thenReturn("Baskets");
    when(
      managers.fishingSpotManager.entity(any),
    ).thenReturn(FishingSpot(lat: 1.234567, lng: 6.543210));
    when(
      managers.methodManager.displayNamesFromIds(any, any),
    ).thenReturn(["Shore", "Cast"]);
    when(
      managers.speciesManager.displayNameFromId(any, any),
    ).thenReturn("Rainbow");
    when(
      managers.waterClarityManager.displayNameFromId(any, any),
    ).thenReturn("Clear");
    when(
      managers.gearManager.displayNamesFromIds(any, any),
    ).thenReturn(["Gear A", "Gear B"]);

    when(managers.catchManager.catches(any)).thenReturn([
      Catch(
        id: randomId(),
        timestamp: Int64(5000),
        atmosphere: testAtmosphere(),
        anglerId: randomId(),
        baits: [BaitAttachment(baitId: randomId(), variantId: randomId())],
        gearIds: [randomId()],
        period: Period.evening,
        fishingSpotId: randomId(),
        methodIds: [randomId()],
        speciesId: randomId(),
        timeZone: "America/New_York",
        isFavorite: true,
        wasCatchAndRelease: true,
        season: Season.winter,
        waterClarityId: randomId(),
        waterDepth: MultiMeasurement(mainValue: Measurement(value: 15)),
        waterTemperature: MultiMeasurement(mainValue: Measurement(value: 60)),
        length: MultiMeasurement(mainValue: Measurement(value: 25)),
        weight: MultiMeasurement(mainValue: Measurement(value: 5)),
        quantity: 1,
        notes: "Put up a good, 15 min, fight.",
        tide: Tide(
          type: TideType.high,
          height: Tide_Height(timestamp: Int64(5000), value: 0.25),
        ),
      ),
    ]);

    var context = await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(
      csvList[0].length,
      allCatchFields(context).length +
          allAtmosphereFields(context).length -
          3 + // Timestamp, images, atmosphere.
          2 + // Date and time.
          2, // Coordinates.
    );
    expect(csvList[0][0], "Date");
    expect(csvList[0][1], "Time");
    expect(csvList[0][2], "Time Zone");
    expect(csvList[0][3], "Time of Day");
    expect(csvList[0][4], "Season");
    expect(csvList[0][5], "Species");
    expect(csvList[0][6], "Bait");
    expect(csvList[0][7], "Gear");
    expect(csvList[0][8], "Fishing Spot");
    expect(csvList[0][9], "Latitude");
    expect(csvList[0][10], "Longitude");
    expect(csvList[0][11], "Angler");
    expect(csvList[0][12], "Catch and Release");
    expect(csvList[0][13], "Favourite");
    expect(csvList[0][14], "Fishing Methods");
    expect(csvList[0][15], "Tide");
    expect(csvList[0][16], "Water Clarity");
    expect(csvList[0][17], "Water Depth");
    expect(csvList[0][18], "Water Temperature");
    expect(csvList[0][19], "Length");
    expect(csvList[0][20], "Weight");
    expect(csvList[0][21], "Quantity");
    expect(csvList[0][22], "Notes");
    expect(csvList[1][0], "Dec 31, 1969");
    expect(csvList[1][1], "7:00 PM");
    expect(csvList[1][2], "America/New York");
    expect(csvList[1][3], "Evening");
    expect(csvList[1][4], "Winter");
    expect(csvList[1][5], "Rainbow");
    expect(csvList[1][6], "Stone Fly, Bugger");
    expect(csvList[1][7], "Gear A, Gear B");
    expect(csvList[1][8], "Baskets");
    expect(csvList[1][9], "1.234567");
    expect(csvList[1][10], "6.543210");
    expect(csvList[1][11], "Cohen");
    expect(csvList[1][12], "Yes");
    expect(csvList[1][13], "Yes");
    expect(csvList[1][14], "Shore, Cast");
    expect(csvList[1][15], "High, 0.25 m at 7:00 PM");
    expect(csvList[1][16], "Clear");
    expect(csvList[1][17], "15");
    expect(csvList[1][18], "60");
    expect(csvList[1][19], "25");
    expect(csvList[1][20], "5");
    expect(csvList[1][21], "1");
    expect(csvList[1][22], "Put up a good, 15 min, fight.");
  });

  testWidgets("All catch and custom fields are included", (tester) async {
    var context = await buildContext(tester);
    var customEntityId0 = randomId();
    var customEntityId1 = randomId();
    when(managers.userPreferenceManager.catchFieldIds).thenReturn(
      allCatchFields(context).map((e) => e.id).toList()
        ..add(customEntityId0)
        ..add(customEntityId1),
    );
    when(
      managers.customEntityManager.entityExists(customEntityId0),
    ).thenReturn(true);
    when(
      managers.customEntityManager.entityExists(customEntityId1),
    ).thenReturn(true);
    when(
      managers.customEntityManager.entity(customEntityId0),
    ).thenReturn(CustomEntity(id: customEntityId0, name: "Hat Style"));
    when(
      managers.customEntityManager.entity(customEntityId1),
    ).thenReturn(CustomEntity(id: customEntityId1, name: "Number Of Anglers"));
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(
      managers.anglerManager.displayNameFromId(any, any),
    ).thenReturn("Cohen");
    when(
      managers.baitManager.attachmentsDisplayValues(any, any),
    ).thenReturn(["Stone Fly", "Bugger"]);
    when(
      managers.fishingSpotManager.displayNameFromId(
        any,
        any,
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
        useLatLngFallback: anyNamed("useLatLngFallback"),
      ),
    ).thenReturn("Baskets");
    when(
      managers.fishingSpotManager.entity(any),
    ).thenReturn(FishingSpot(lat: 1.234567, lng: 6.543210));
    when(
      managers.methodManager.displayNamesFromIds(any, any),
    ).thenReturn(["Shore", "Cast"]);
    when(
      managers.speciesManager.displayNameFromId(any, any),
    ).thenReturn("Rainbow");
    when(
      managers.waterClarityManager.displayNameFromId(any, any),
    ).thenReturn("Clear");
    when(
      managers.gearManager.displayNamesFromIds(any, any),
    ).thenReturn(["Gear A", "Gear B"]);

    when(managers.catchManager.catches(any)).thenReturn([
      Catch(
        id: randomId(),
        timestamp: Int64(5000),
        atmosphere: testAtmosphere(),
        anglerId: randomId(),
        baits: [BaitAttachment(baitId: randomId(), variantId: randomId())],
        gearIds: [randomId()],
        period: Period.evening,
        fishingSpotId: randomId(),
        methodIds: [randomId()],
        speciesId: randomId(),
        timeZone: "America/New_York",
        isFavorite: true,
        wasCatchAndRelease: true,
        season: Season.winter,
        waterClarityId: randomId(),
        waterDepth: MultiMeasurement(mainValue: Measurement(value: 15)),
        waterTemperature: MultiMeasurement(mainValue: Measurement(value: 60)),
        length: MultiMeasurement(mainValue: Measurement(value: 25)),
        weight: MultiMeasurement(mainValue: Measurement(value: 5)),
        quantity: 1,
        notes: "Put up a good, 15 min, fight.",
        tide: Tide(
          type: TideType.high,
          height: Tide_Height(timestamp: Int64(5000), value: 0.25),
        ),
        customEntityValues: [
          CustomEntityValue(customEntityId: customEntityId0, value: "Ball"),
          CustomEntityValue(customEntityId: customEntityId1, value: "5"),
        ],
      ),
    ]);

    context = await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(
      csvList[0].length,
      // -3 for timestamp, images, and atmosphere; +4 for date, time, and custom
      // fields.
      allCatchFields(context).length +
          allAtmosphereFields(context).length -
          3 + // Timestamp, images, atmosphere.
          2 + // Date and time.
          2 + // Custom fields.
          2, // Coordinates.
    );
    expect(csvList[0][0], "Date");
    expect(csvList[0][1], "Time");
    expect(csvList[0][2], "Time Zone");
    expect(csvList[0][3], "Time of Day");
    expect(csvList[0][4], "Season");
    expect(csvList[0][5], "Species");
    expect(csvList[0][6], "Bait");
    expect(csvList[0][7], "Gear");
    expect(csvList[0][8], "Fishing Spot");
    expect(csvList[0][9], "Latitude");
    expect(csvList[0][10], "Longitude");
    expect(csvList[0][11], "Angler");
    expect(csvList[0][12], "Catch and Release");
    expect(csvList[0][13], "Favourite");
    expect(csvList[0][14], "Fishing Methods");
    expect(csvList[0][15], "Tide");
    expect(csvList[0][16], "Water Clarity");
    expect(csvList[0][17], "Water Depth");
    expect(csvList[0][18], "Water Temperature");
    expect(csvList[0][19], "Length");
    expect(csvList[0][20], "Weight");
    expect(csvList[0][21], "Quantity");
    expect(csvList[0][22], "Notes");
    expect(csvList[0][23], "Hat Style");
    expect(csvList[0][24], "Number Of Anglers");
    expect(csvList[1][0], "Dec 31, 1969");
    expect(csvList[1][1], "7:00 PM");
    expect(csvList[1][2], "America/New York");
    expect(csvList[1][3], "Evening");
    expect(csvList[1][4], "Winter");
    expect(csvList[1][5], "Rainbow");
    expect(csvList[1][6], "Stone Fly, Bugger");
    expect(csvList[1][7], "Gear A, Gear B");
    expect(csvList[1][8], "Baskets");
    expect(csvList[1][9], "1.234567");
    expect(csvList[1][10], "6.543210");
    expect(csvList[1][11], "Cohen");
    expect(csvList[1][12], "Yes");
    expect(csvList[1][13], "Yes");
    expect(csvList[1][14], "Shore, Cast");
    expect(csvList[1][15], "High, 0.25 m at 7:00 PM");
    expect(csvList[1][16], "Clear");
    expect(csvList[1][17], "15");
    expect(csvList[1][18], "60");
    expect(csvList[1][19], "25");
    expect(csvList[1][20], "5");
    expect(csvList[1][21], "1");
    expect(csvList[1][22], "Put up a good, 15 min, fight.");
    expect(csvList[1][23], "Ball");
    expect(csvList[1][24], "5");
  });

  testWidgets("Only required catch fields have values", (tester) async {
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(managers.anglerManager.displayNameFromId(any, any)).thenReturn(null);
    when(
      managers.baitManager.attachmentsDisplayValues(any, any),
    ).thenReturn([]);
    when(
      managers.fishingSpotManager.displayNameFromId(
        any,
        any,
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
        useLatLngFallback: anyNamed("useLatLngFallback"),
      ),
    ).thenReturn(null);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(managers.methodManager.displayNamesFromIds(any, any)).thenReturn([]);
    when(managers.gearManager.displayNamesFromIds(any, any)).thenReturn([]);
    when(managers.speciesManager.displayNameFromId(any, any)).thenReturn(null);
    when(
      managers.waterClarityManager.displayNameFromId(any, any),
    ).thenReturn(null);
    when(managers.catchManager.catches(any)).thenReturn([
      Catch(id: randomId(), timestamp: Int64(5000), speciesId: randomId()),
    ]);

    var context = await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(
      csvList[0].length,
      allCatchFields(context).length +
          allAtmosphereFields(context).length -
          3 + // Timestamp, images, atmosphere.
          2 + // Date and time.
          2, // Coordinates.
    );
    expect(csvList[1][0], "Dec 31, 1969");
    expect(csvList[1][1], "7:00 PM");
    expect(csvList[1][2], "");
    expect(csvList[1][3], "");
    expect(csvList[1][4], "");
    expect(csvList[1][5], "");
    expect(csvList[1][6], "");
    expect(csvList[1][7], "");
    expect(csvList[1][8], "");
    expect(csvList[1][9], "");
    expect(csvList[1][10], "");
    expect(csvList[1][11], "");
    expect(csvList[1][12], "");
    expect(csvList[1][13], "");
    expect(csvList[1][14], "");
    expect(csvList[1][15], "");
    expect(csvList[1][16], "");
    expect(csvList[1][17], "");
    expect(csvList[1][18], "");
    expect(csvList[1][19], "");
    expect(csvList[1][20], "");
    expect(csvList[1][21], "");
    expect(csvList[1][22], "");
    expect(csvList[1][23], "");
    expect(csvList[1][24], "");
    expect(csvList[1][25], "");
    expect(csvList[1][26], "");
    expect(csvList[1][27], "");
    expect(csvList[1][28], "");
    expect(csvList[1][29], "");
    expect(csvList[1][30], "");
    expect(csvList[1][31], "");
  });

  testWidgets("Untracked trip fields are excluded", (tester) async {
    when(
      managers.userPreferenceManager.tripFieldIds,
    ).thenReturn([tripFieldIdStartTimestamp, tripFieldIdEndTimestamp]);
    when(managers.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        startTimestamp: Int64(5000),
        endTimestamp: Int64(10000),
      ),
    ]);

    await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(csvList[0].length, 4);
    expect(csvList[1].length, 4);
  });

  testWidgets("All trip fields are included, preferences are empty", (
    tester,
  ) async {
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(
      managers.catchManager.displayNamesFromIds(any, any),
    ).thenReturn(["Rainbow", "Walleye"]);
    when(
      managers.bodyOfWaterManager.displayNamesFromIds(any, any),
    ).thenReturn(["Lake Huron", "Silver Lake"]);

    var emptyId = randomId();
    when(managers.fishingSpotManager.displayNameFromId(any, any)).thenAnswer(
      (invocation) =>
          invocation.positionalArguments.last == emptyId ? null : "Spot 1",
    );

    when(
      managers.anglerManager.displayNameFromId(any, any),
    ).thenReturn("Cohen");
    when(
      managers.speciesManager.displayNameFromId(any, any),
    ).thenReturn("Rainbow");
    when(
      managers.baitManager.attachmentDisplayValue(any, any),
    ).thenReturn("Bait");
    when(
      managers.waterClarityManager.displayNameFromId(any, any),
    ).thenReturn("Clear");

    when(managers.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        startTimestamp: Int64(5000),
        endTimestamp: Int64(100000000),
        timeZone: "America/New_York",
        name: "Test Trip",
        catchIds: [randomId()],
        bodyOfWaterIds: [randomId()],
        catchesPerFishingSpot: [
          Trip_CatchesPerEntity(entityId: randomId(), value: 5),
          Trip_CatchesPerEntity(entityId: randomId(), value: 12),
          Trip_CatchesPerEntity(entityId: emptyId, value: 12),
        ],
        catchesPerAngler: [
          Trip_CatchesPerEntity(entityId: randomId(), value: 10),
        ],
        catchesPerSpecies: [
          Trip_CatchesPerEntity(entityId: randomId(), value: 15),
        ],
        catchesPerBait: [
          Trip_CatchesPerBait(
            attachment: BaitAttachment(
              baitId: randomId(),
              variantId: randomId(),
            ),
            value: 20,
          ),
          Trip_CatchesPerBait(
            attachment: BaitAttachment(
              baitId: randomId(),
              variantId: randomId(),
            ),
            value: 25,
          ),
        ],
        notes: "Long trip, tons of fish.",
        waterClarityId: randomId(),
        waterDepth: MultiMeasurement(mainValue: Measurement(value: 10)),
        waterTemperature: MultiMeasurement(mainValue: Measurement(value: 65)),
      ),
    ]);

    var context = await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(
      csvList[0].length,
      // -5 for start/end timestamp, images, atmosphere, and GPS trails
      // +4 for start/end date and start/end time.
      allTripFields(context).length +
          allAtmosphereFields(context).length -
          5 +
          4,
    );
    expect(csvList[0][0], "Start Date");
    expect(csvList[0][1], "Start Time");
    expect(csvList[0][2], "End Date");
    expect(csvList[0][3], "End Time");
    expect(csvList[0][4], "Catches");
    expect(csvList[0][5], "Bodies of Water");
    expect(csvList[0][6], "Time Zone");
    expect(csvList[0][7], "Name");
    expect(csvList[0][8], "Notes");
    expect(csvList[0][9], "Water Clarity");
    expect(csvList[0][10], "Water Depth");
    expect(csvList[0][11], "Water Temperature");
    expect(csvList[0][12], "Catches Per Angler");
    expect(csvList[0][13], "Catches Per Bait");
    expect(csvList[0][14], "Catches Per Fishing Spot");
    expect(csvList[0][15], "Catches Per Species");
    expect(csvList[1][0], "Dec 31, 1969");
    expect(csvList[1][1], "7:00 PM");
    expect(csvList[1][2], "Jan 1, 1970");
    expect(csvList[1][3], "10:46 PM");
    expect(csvList[1][4], "Rainbow, Walleye");
    expect(csvList[1][5], "Lake Huron, Silver Lake");
    expect(csvList[1][6], "America/New York");
    expect(csvList[1][7], "Test Trip");
    expect(csvList[1][8], "Long trip, tons of fish.");
    expect(csvList[1][9], "Clear");
    expect(csvList[1][10], "10");
    expect(csvList[1][11], "65");
    expect(csvList[1][12], "Cohen: 10");
    expect(csvList[1][13], "Bait: 20, Bait: 25");
    expect(csvList[1][14], "Spot 1: 5, Spot 1: 12");
    expect(csvList[1][15], "Rainbow: 15");
  });

  testWidgets("All trip and custom fields are included", (tester) async {
    var context = await buildContext(tester);
    var customEntityId0 = randomId();
    var customEntityId1 = randomId();
    when(managers.userPreferenceManager.tripFieldIds).thenReturn(
      allTripFields(context).map((e) => e.id).toList()
        ..add(customEntityId0)
        ..add(customEntityId1),
    );
    when(
      managers.customEntityManager.entityExists(customEntityId0),
    ).thenReturn(true);
    when(
      managers.customEntityManager.entityExists(customEntityId1),
    ).thenReturn(true);
    when(
      managers.customEntityManager.entity(customEntityId0),
    ).thenReturn(CustomEntity(id: customEntityId0, name: "Trolling Speed"));
    when(
      managers.customEntityManager.entity(customEntityId1),
    ).thenReturn(CustomEntity(id: customEntityId1, name: "Number Of Anglers"));
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(
      managers.catchManager.displayNamesFromIds(any, any),
    ).thenReturn(["Rainbow", "Walleye"]);
    when(
      managers.bodyOfWaterManager.displayNamesFromIds(any, any),
    ).thenReturn(["Lake Huron", "Silver Lake"]);
    when(
      managers.waterClarityManager.displayNameFromId(any, any),
    ).thenReturn("Clear");

    var emptyId = randomId();
    when(managers.fishingSpotManager.displayNameFromId(any, any)).thenAnswer(
      (invocation) =>
          invocation.positionalArguments.last == emptyId ? null : "Spot 1",
    );

    when(
      managers.anglerManager.displayNameFromId(any, any),
    ).thenReturn("Cohen");
    when(
      managers.speciesManager.displayNameFromId(any, any),
    ).thenReturn("Rainbow");
    when(
      managers.baitManager.attachmentDisplayValue(any, any),
    ).thenReturn("Bait");

    when(managers.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        startTimestamp: Int64(5000),
        endTimestamp: Int64(100000000),
        timeZone: "America/New_York",
        name: "Test Trip",
        catchIds: [randomId()],
        bodyOfWaterIds: [randomId()],
        catchesPerFishingSpot: [
          Trip_CatchesPerEntity(entityId: randomId(), value: 5),
          Trip_CatchesPerEntity(entityId: randomId(), value: 12),
          Trip_CatchesPerEntity(entityId: emptyId, value: 12),
        ],
        catchesPerAngler: [
          Trip_CatchesPerEntity(entityId: randomId(), value: 10),
        ],
        catchesPerSpecies: [
          Trip_CatchesPerEntity(entityId: randomId(), value: 15),
        ],
        catchesPerBait: [
          Trip_CatchesPerBait(
            attachment: BaitAttachment(
              baitId: randomId(),
              variantId: randomId(),
            ),
            value: 20,
          ),
          Trip_CatchesPerBait(
            attachment: BaitAttachment(
              baitId: randomId(),
              variantId: randomId(),
            ),
            value: 25,
          ),
        ],
        notes: "Long trip, tons of fish.",
        customEntityValues: [
          CustomEntityValue(customEntityId: customEntityId0, value: "15"),
          CustomEntityValue(customEntityId: customEntityId1, value: "5"),
        ],
        waterClarityId: randomId(),
        waterDepth: MultiMeasurement(mainValue: Measurement(value: 10)),
        waterTemperature: MultiMeasurement(mainValue: Measurement(value: 65)),
      ),
    ]);

    context = await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(
      csvList[0].length,
      // -5 for start/end timestamp, images, atmosphere, and GPS trails
      // +6 for start/end date, start/end time, and custom fields.
      allTripFields(context).length +
          allAtmosphereFields(context).length -
          5 +
          6,
    );
    expect(csvList[0][0], "Start Date");
    expect(csvList[0][1], "Start Time");
    expect(csvList[0][2], "End Date");
    expect(csvList[0][3], "End Time");
    expect(csvList[0][4], "Catches");
    expect(csvList[0][5], "Bodies of Water");
    expect(csvList[0][6], "Time Zone");
    expect(csvList[0][7], "Name");
    expect(csvList[0][8], "Notes");
    expect(csvList[0][9], "Water Clarity");
    expect(csvList[0][10], "Water Depth");
    expect(csvList[0][11], "Water Temperature");
    expect(csvList[0][12], "Catches Per Angler");
    expect(csvList[0][13], "Catches Per Bait");
    expect(csvList[0][14], "Catches Per Fishing Spot");
    expect(csvList[0][15], "Catches Per Species");
    expect(csvList[1][0], "Dec 31, 1969");
    expect(csvList[1][1], "7:00 PM");
    expect(csvList[1][2], "Jan 1, 1970");
    expect(csvList[1][3], "10:46 PM");
    expect(csvList[1][4], "Rainbow, Walleye");
    expect(csvList[1][5], "Lake Huron, Silver Lake");
    expect(csvList[1][6], "America/New York");
    expect(csvList[1][7], "Test Trip");
    expect(csvList[1][8], "Long trip, tons of fish.");
    expect(csvList[1][9], "Clear");
    expect(csvList[1][10], "10");
    expect(csvList[1][11], "65");
    expect(csvList[1][12], "Cohen: 10");
    expect(csvList[1][13], "Bait: 20, Bait: 25");
    expect(csvList[1][14], "Spot 1: 5, Spot 1: 12");
    expect(csvList[1][15], "Rainbow: 15");
    expect(csvList[1][16], "15");
    expect(csvList[1][17], "5");
  });

  testWidgets("Only required trip fields have values", (tester) async {
    when(managers.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(managers.catchManager.displayNamesFromIds(any, any)).thenReturn([]);
    when(
      managers.bodyOfWaterManager.displayNamesFromIds(any, any),
    ).thenReturn([]);
    when(
      managers.fishingSpotManager.displayNameFromId(any, any),
    ).thenReturn(null);
    when(managers.anglerManager.displayNameFromId(any, any)).thenReturn(null);
    when(managers.speciesManager.displayNameFromId(any, any)).thenReturn(null);
    when(managers.baitManager.attachmentDisplayValue(any, any)).thenReturn("");
    when(
      managers.waterClarityManager.displayNameFromId(any, any),
    ).thenReturn("");

    when(managers.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        startTimestamp: Int64(5000),
        endTimestamp: Int64(100000000),
      ),
    ]);

    var context = await pumpContext(tester, (_) => CsvPage());
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await ensureVisibleAndSettle(tester, find.text("EXPORT"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(managers.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(
      csvList[0].length,
      // -5 for start/end timestamp, images, atmosphere, and GPS trails
      // +4 for start/end date and start/end time.
      allTripFields(context).length +
          allAtmosphereFields(context).length -
          5 +
          4,
    );
    expect(csvList[0][0], "Start Date");
    expect(csvList[0][1], "Start Time");
    expect(csvList[0][2], "End Date");
    expect(csvList[0][3], "End Time");
    expect(csvList[0][4], "Catches");
    expect(csvList[0][5], "Bodies of Water");
    expect(csvList[0][6], "Time Zone");
    expect(csvList[0][7], "Name");
    expect(csvList[0][8], "Notes");
    expect(csvList[0][9], "Water Clarity");
    expect(csvList[0][10], "Water Depth");
    expect(csvList[0][11], "Water Temperature");
    expect(csvList[0][12], "Catches Per Angler");
    expect(csvList[0][13], "Catches Per Bait");
    expect(csvList[0][14], "Catches Per Fishing Spot");
    expect(csvList[0][15], "Catches Per Species");
    expect(csvList[1][0], "Dec 31, 1969");
    expect(csvList[1][1], "7:00 PM");
    expect(csvList[1][2], "Jan 1, 1970");
    expect(csvList[1][3], "10:46 PM");
    expect(csvList[1][4], "");
    expect(csvList[1][5], "");
    expect(csvList[1][6], "");
    expect(csvList[1][7], "");
    expect(csvList[1][8], "");
    expect(csvList[1][9], "");
    expect(csvList[1][10], "");
    expect(csvList[1][11], "");
    expect(csvList[1][12], "");
    expect(csvList[1][13], "");
    expect(csvList[1][14], "");
    expect(csvList[1][15], "");
  });
}
