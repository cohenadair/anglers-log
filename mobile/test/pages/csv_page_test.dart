import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/csv_page.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/trip_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

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
    when(appManager.ioWrapper.file(any)).thenReturn(mockFile);
    return mockFile;
  }

  setUp(() {
    appManager = StubbedAppManager();
    stubFile();

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.csvWrapper.convert(any)).thenReturn("");

    when(appManager.subscriptionManager.isFree).thenReturn(false);

    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.tideHeightSystem)
        .thenReturn(MeasurementSystem.metric);

    when(appManager.catchManager.catches(any)).thenReturn([]);

    when(appManager.tripManager.list()).thenReturn([]);

    when(appManager.pathProviderWrapper.temporaryPath)
        .thenAnswer((_) => Future.value(""));

    when(appManager.sharePlusWrapper.shareFiles(any))
        .thenAnswer((_) => Future.value());
  });

  Atmosphere testAtmosphere() {
    return Atmosphere(
      temperature: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.celsius,
          value: 15,
        ),
      ),
      skyConditions: [SkyCondition.cloudy, SkyCondition.drizzle],
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

  testWidgets("Feedback description shows an error", (tester) async {
    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await tapAndSettle(tester, find.text("EXPORT"));
    expect(
      find.text("Please select at least one export option above."),
      findsOneWidget,
    );
  });

  testWidgets("Feedback description is successful", (tester) async {
    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, find.text("EXPORT"));
    expect(find.text("Success!"), findsOneWidget);
  });

  testWidgets("Feedback shows loading on action tap", (tester) async {
    stubFile(250);
    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tester.tap(find.text("EXPORT"));
    await tester.pump();
    expect(find.byType(Loading), findsOneWidget);

    // Drain pending timer.
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
  });

  testWidgets("Feedback shows ProPage on tap", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value());
    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, find.text("EXPORT"));
    expect(find.byType(ProPage), findsOneWidget);
  });

  testWidgets("Only catches are exported", (tester) async {
    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(appManager.sharePlusWrapper.shareFiles(captureAny));
    result.called(1);
    expect((result.captured.first as List).length, 1);

    result = verify(appManager.ioWrapper.file(captureAny));
    expect((result.captured.first as String).contains("catches.csv"), isTrue);
  });

  testWidgets("Only trips are exported", (tester) async {
    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(appManager.sharePlusWrapper.shareFiles(captureAny));
    result.called(1);
    expect((result.captured.first as List).length, 1);

    result = verify(appManager.ioWrapper.file(captureAny));
    expect((result.captured.first as String).contains("trips.csv"), isTrue);
  });

  testWidgets("All files are exported", (tester) async {
    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(appManager.sharePlusWrapper.shareFiles(captureAny));
    result.called(1);
    expect((result.captured.first as List).length, 2);
  });

  testWidgets("Untracked catch fields are excluded", (tester) async {
    when(appManager.userPreferenceManager.catchFieldIds)
        .thenReturn([catchFieldIdTimestamp]);
    when(appManager.catchManager.catches(any)).thenReturn([
      Catch(
        id: randomId(),
        timestamp: Int64(5000),
      ),
    ]);

    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(appManager.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(csvList[0].length, 2);
    expect(csvList[1].length, 2);
  });

  testWidgets("Untracked atmosphere fields are excluded", (tester) async {
    when(appManager.userPreferenceManager.catchFieldIds)
        .thenReturn([catchFieldIdTimestamp, catchFieldIdAtmosphere]);
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([
      tripFieldIdStartTimestamp,
      tripFieldIdEndTimestamp,
      tripFieldIdAtmosphere,
    ]);
    when(appManager.catchManager.catches(any)).thenReturn([
      Catch(
        id: randomId(),
        timestamp: Int64(5000),
        atmosphere: testAtmosphere(),
      ),
    ]);
    when(appManager.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        startTimestamp: Int64(5000),
        endTimestamp: Int64(10000),
        atmosphere: testAtmosphere(),
      ),
    ]);

    // Track only one atmosphere field (empty preferences will show all fields).
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([
      atmosphereFieldIdSkyCondition,
    ]);

    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, find.text("EXPORT"));

    // Verify atmosphere fields are included.
    var result = verify(appManager.csvWrapper.convert(captureAny));
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

    var context =
        await pumpContext(tester, (_) => CsvPage(), appManager: appManager);

    // Track all other fields, verifying sky conditions is hidden.
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn(
      allAtmosphereFields(context).map((e) => e.id).toList()
        ..remove(atmosphereFieldIdSkyCondition),
    );

    await tapAndSettle(tester, find.text("EXPORT"));

    // Verify atmosphere fields are included.
    result = verify(appManager.csvWrapper.convert(captureAny));
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

  testWidgets("All catch fields are included", (tester) async {
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(appManager.anglerManager.displayNameFromId(any, any))
        .thenReturn("Cohen");
    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn(["Stone Fly", "Bugger"]);
    when(appManager.fishingSpotManager.displayNameFromId(
      any,
      any,
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("Baskets");
    when(appManager.methodManager.displayNamesFromIds(any, any))
        .thenReturn(["Shore", "Cast"]);
    when(appManager.speciesManager.displayNameFromId(any, any))
        .thenReturn("Rainbow");
    when(appManager.waterClarityManager.displayNameFromId(any, any))
        .thenReturn("Clear");
    when(appManager.gearManager.displayNamesFromIds(any, any))
        .thenReturn(["Gear A", "Gear B"]);

    when(appManager.catchManager.catches(any)).thenReturn([
      Catch(
        id: randomId(),
        timestamp: Int64(5000),
        atmosphere: testAtmosphere(),
        anglerId: randomId(),
        baits: [
          BaitAttachment(
            baitId: randomId(),
            variantId: randomId(),
          ),
        ],
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
          height: Tide_Height(
            timestamp: Int64(5000),
            value: 0.25,
          ),
        ),
      ),
    ]);

    var context =
        await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(appManager.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(
      csvList[0].length,
      // -3 for timestamp, images, and atmosphere; +2 for date and time.
      allCatchFields(context).length +
          allAtmosphereFields(context).length -
          3 +
          2,
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
    expect(csvList[0][9], "Angler");
    expect(csvList[0][10], "Catch and Release");
    expect(csvList[0][11], "Favorite");
    expect(csvList[0][12], "Fishing Methods");
    expect(csvList[0][13], "Tide");
    expect(csvList[0][14], "Water Clarity");
    expect(csvList[0][15], "Water Depth");
    expect(csvList[0][16], "Water Temperature");
    expect(csvList[0][17], "Length");
    expect(csvList[0][18], "Weight");
    expect(csvList[0][19], "Quantity");
    expect(csvList[0][20], "Notes");
    expect(csvList[1][0], "Dec 31, 1969");
    expect(csvList[1][1], "7:00 PM");
    expect(csvList[1][2], "America/New York");
    expect(csvList[1][3], "Evening");
    expect(csvList[1][4], "Winter");
    expect(csvList[1][5], "Rainbow");
    expect(csvList[1][6], "Stone Fly, Bugger");
    expect(csvList[1][7], "Gear A, Gear B");
    expect(csvList[1][8], "Baskets");
    expect(csvList[1][9], "Cohen");
    expect(csvList[1][10], "Yes");
    expect(csvList[1][11], "Yes");
    expect(csvList[1][12], "Shore, Cast");
    expect(csvList[1][13], "High, 0.25 m at 7:00 PM");
    expect(csvList[1][14], "Clear");
    expect(csvList[1][15], "15");
    expect(csvList[1][16], "60");
    expect(csvList[1][17], "25");
    expect(csvList[1][18], "5");
    expect(csvList[1][19], "1");
    expect(csvList[1][20], "Put up a good, 15 min, fight.");
  });

  testWidgets("Only required catch fields have values", (tester) async {
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(appManager.anglerManager.displayNameFromId(any, any)).thenReturn(null);
    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn([]);
    when(appManager.fishingSpotManager.displayNameFromId(
      any,
      any,
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn(null);
    when(appManager.methodManager.displayNamesFromIds(any, any)).thenReturn([]);
    when(appManager.gearManager.displayNamesFromIds(any, any)).thenReturn([]);
    when(appManager.speciesManager.displayNameFromId(any, any))
        .thenReturn(null);
    when(appManager.waterClarityManager.displayNameFromId(any, any))
        .thenReturn(null);
    when(appManager.catchManager.catches(any)).thenReturn([
      Catch(
        id: randomId(),
        timestamp: Int64(5000),
        speciesId: randomId(),
      ),
    ]);

    var context =
        await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, findListItemCheckbox(tester, "Trips"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(appManager.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(
      csvList[0].length,
      // -3 for timestamp, images, and atmosphere; +2 for date and time.
      allCatchFields(context).length +
          allAtmosphereFields(context).length -
          3 +
          2,
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
  });

  testWidgets("Untracked trip fields are excluded", (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds)
        .thenReturn([tripFieldIdStartTimestamp, tripFieldIdEndTimestamp]);
    when(appManager.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        startTimestamp: Int64(5000),
        endTimestamp: Int64(10000),
      ),
    ]);

    await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(appManager.csvWrapper.convert(captureAny));
    result.called(1);

    var csvList = result.captured.first as List<List<dynamic>>;
    expect(csvList.length, 2);
    expect(csvList[0].length, 4);
    expect(csvList[1].length, 4);
  });

  testWidgets("All trip fields are included", (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(appManager.catchManager.displayNamesFromIds(any, any))
        .thenReturn(["Rainbow", "Walleye"]);
    when(appManager.bodyOfWaterManager.displayNamesFromIds(any, any))
        .thenReturn(["Lake Huron", "Silver Lake"]);

    var emptyId = randomId();
    when(appManager.fishingSpotManager.displayNameFromId(any, any)).thenAnswer(
        (invocation) =>
            invocation.positionalArguments.last == emptyId ? null : "Spot 1");

    when(appManager.anglerManager.displayNameFromId(any, any))
        .thenReturn("Cohen");
    when(appManager.speciesManager.displayNameFromId(any, any))
        .thenReturn("Rainbow");
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("Bait");

    when(appManager.tripManager.list()).thenReturn([
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
      ),
    ]);

    var context =
        await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(appManager.csvWrapper.convert(captureAny));
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
    expect(csvList[0][9], "Catches Per Angler");
    expect(csvList[0][10], "Catches Per Bait");
    expect(csvList[0][11], "Catches Per Fishing Spot");
    expect(csvList[0][12], "Catches Per Species");
    expect(csvList[1][0], "Dec 31, 1969");
    expect(csvList[1][1], "7:00 PM");
    expect(csvList[1][2], "Jan 1, 1970");
    expect(csvList[1][3], "10:46 PM");
    expect(csvList[1][4], "Rainbow, Walleye");
    expect(csvList[1][5], "Lake Huron, Silver Lake");
    expect(csvList[1][6], "America/New York");
    expect(csvList[1][7], "Test Trip");
    expect(csvList[1][8], "Long trip, tons of fish.");
    expect(csvList[1][9], "Cohen: 10");
    expect(csvList[1][10], "Bait: 20, Bait: 25");
    expect(csvList[1][11], "Spot 1: 5, Spot 1: 12");
    expect(csvList[1][12], "Rainbow: 15");
  });

  testWidgets("Only required trip fields have values", (tester) async {
    when(appManager.userPreferenceManager.tripFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(appManager.catchManager.displayNamesFromIds(any, any)).thenReturn([]);
    when(appManager.bodyOfWaterManager.displayNamesFromIds(any, any))
        .thenReturn([]);
    when(appManager.fishingSpotManager.displayNameFromId(any, any))
        .thenReturn(null);
    when(appManager.anglerManager.displayNameFromId(any, any)).thenReturn(null);
    when(appManager.speciesManager.displayNameFromId(any, any))
        .thenReturn(null);
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("");

    when(appManager.tripManager.list()).thenReturn([
      Trip(
        id: randomId(),
        startTimestamp: Int64(5000),
        endTimestamp: Int64(100000000),
      ),
    ]);

    var context =
        await pumpContext(tester, (_) => CsvPage(), appManager: appManager);
    await tapAndSettle(tester, findListItemCheckbox(tester, "Catches"));
    await tapAndSettle(tester, find.text("EXPORT"));

    var result = verify(appManager.csvWrapper.convert(captureAny));
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
    expect(csvList[0][9], "Catches Per Angler");
    expect(csvList[0][10], "Catches Per Bait");
    expect(csvList[0][11], "Catches Per Fishing Spot");
    expect(csvList[0][12], "Catches Per Species");
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
  });
}
