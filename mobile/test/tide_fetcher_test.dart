import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/tide_fetcher.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/timezone.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockLog log;

  setUp(() {
    appManager = StubbedAppManager();
    log = MockLog();

    when(appManager.propertiesManager.worldTidesApiKey).thenReturn("key");
  });

  test("Fetch with null latLng", () async {
    var fetcher = TideFetcher(appManager.app, now(), null);
    var result = await fetcher.fetch();
    expect(result.data, isNull);
    expect(result.errorMessage, isNull);
  });

  test("Fetch with null JSON result", () async {
    stubFetchResponse(appManager, "");
    var fetcher = TideFetcher(appManager.app, now(), const LatLng(0, 0));
    var result = await fetcher.fetch();
    expect(result.data, isNull);
    expect(result.errorMessage, isNull);
  });

  testWidgets("Fetch with 'No location found' result", (tester) async {
    stubFetchResponse(appManager, '{"error": "No location found"}');

    var fetcher = TideFetcher(appManager.app, now(), const LatLng(0, 0));
    var context = await buildContext(tester);
    var result = await fetcher.fetch(Strings.of(context));

    expect(result.data, isNull);
    expect(
      result.errorMessage,
      "Fetch location is too far inland to determine tidal information.",
    );
  });

  test("Fetch with unknown error result", () async {
    stubFetchResponse(appManager, '{"error": "Some other error"}');
    var fetcher = TideFetcher(
      appManager.app,
      now(),
      const LatLng(0, 0),
      log: log,
    );
    var result = await fetcher.fetch();
    expect(result.data, isNull);
    expect(result.errorMessage, isNull);
    verify(log.e(any, "Tide fetch error: Some other error")).called(1);
  });

  test("Fetch JSON result is missing 'heights'", () async {
    stubFetchResponse(appManager, '{"heights": ""}');
    var fetcher = TideFetcher(
      appManager.app,
      now(),
      const LatLng(0, 0),
      log: log,
    );
    var result = await fetcher.fetch();
    expect(result.data, isNull);
    expect(result.errorMessage, isNull);
    verify(log.e(any, "Tide fetch is missing heights")).called(1);
  });

  test("Fetch JSON result is missing 'extremes'", () async {
    stubFetchResponse(appManager, '{"heights": [], "extremes": ""}');
    var fetcher = TideFetcher(
      appManager.app,
      now(),
      const LatLng(0, 0),
      log: log,
    );
    var result = await fetcher.fetch();
    expect(result.data, isNull);
    expect(result.errorMessage, isNull);
    verify(log.e(any, "Tide fetch is missing extremes")).called(1);
  });

  test("Parse invalid tide", () async {
    stubFetchResponse(appManager, '{"heights": [], "extremes": []}');
    var fetcher = TideFetcher(
      appManager.app,
      now(),
      const LatLng(0, 0),
      log: log,
    );
    var result = await fetcher.fetch();
    expect(result.data, isNull);
    expect(result.errorMessage, isNull);
    verify(log.e(any, "Fetched invalid tide value")).called(1);
  });

  test("Parse invalid height, dt, and type values", () async {
    stubFetchResponse(appManager,
        '{"status":200,"callCount":2,"copyright":"Tidal data retrieved from www.worldtides.info. Copyright (c) 2014-2021 Brainware LLC. Licensed for use of individual spatial coordinates on behalf of/by an end-user. Source data created by the Center for Operational Oceanographic Products and Services (CO-OPS) and is not subject to copyright protection. NO GUARANTEES ARE MADE ABOUT THE CORRECTNESS OF THIS DATA. You may not use it if anyone or anything could come to harm as a result of using it (e.g. for navigational purposes).","requestLat":37.754998,"requestLon":-122.509074,"responseLat":37.775,"responseLon":-122.513,"atlas":"NOAA","station":"Ocean Beach, outer coast, California","heights":[{"dt":"not a number","date":"2023-07-23T07:00+0000","height":"not a number"},{"dt":"not a number","date":"2023-07-23T07:30+0000","height":"not a number"},{"dt":1690099200,"date":"2023-07-23T08:00+0000","height":0.405},{"dt":1690100200,"date":"2023-07-23T08:30+0000","height":"not a number"}],"extremes":[{"dt":1690103643,"date":"2023-07-23T09:14+0000","height":0.487,"type":5},{"dt":1690127434,"date":"2023-07-23T15:50+0000","height":-0.762,"type":"Low"},{"dt":1690152976,"date":"2023-07-23T22:56+0000","height":0.623,"type":5}]}');
    var fetcher = TideFetcher(
      appManager.app,
      dateTime(2023, 7, 23),
      const LatLng(0, 0),
    );
    var result = await fetcher.fetch();
    expect(result.data, isNotNull);
    expect(result.errorMessage, isNull);
    expect(result.data!.daysHeights.length, 1);
    expect(result.data!.height.timestamp.toInt(), 1690099200000);
    expect(result.data!.height.value, 0.405);
    expect(result.data!.firstLowTimestamp.toInt(), 1690127434000);
    expect(result.data!.hasFirstHighTimestamp(), isFalse);
    expect(result.data!.hasSecondLowTimestamp(), isFalse);
    expect(result.data!.hasSecondHighTimestamp(), isFalse);
  });

  test("Non-current day heights are filtered", () async {
    stubFetchResponse(appManager,
        '{"status":200,"callCount":2,"copyright":"Tidal data retrieved from www.worldtides.info. Copyright (c) 2014-2021 Brainware LLC. Licensed for use of individual spatial coordinates on behalf of/by an end-user. Source data created by the Center for Operational Oceanographic Products and Services (CO-OPS) and is not subject to copyright protection. NO GUARANTEES ARE MADE ABOUT THE CORRECTNESS OF THIS DATA. You may not use it if anyone or anything could come to harm as a result of using it (e.g. for navigational purposes).","requestLat":37.754998,"requestLon":-122.509074,"responseLat":37.775,"responseLon":-122.513,"atlas":"NOAA","station":"Ocean Beach, outer coast, California","heights":[{"dt":1690063200,"date":"2023-07-22T22:00+0000","height":0.567},{"dt":1690065000,"date":"2023-07-22T22:30+0000","height":0.611},{"dt":1690066800,"date":"2023-07-22T23:00+0000","height":0.623},{"dt":1690155000,"date":"2023-07-23T23:30+0000","height":0.603},{"dt":1690174800,"date":"2023-07-24T05:00+0000","height":0.552},{"dt":1690176600,"date":"2023-07-24T05:30+0000","height":0.474},{"dt":1690178400,"date":"2023-07-24T06:00+0000","height":0.375}],"extremes":[{"dt":1658481240,"date":"2022-07-22T09:14+0000","height":0.487,"type":"High"},{"dt":1658505000,"date":"2022-07-22T15:50+0000","height":-0.762,"type":"Low"},{"dt":1690152976,"date":"2023-07-23T22:56+0000","height":0.623,"type":"High"},{"dt":1721796660,"date":"2024-07-24T04:51+0000","height":-0.203,"type":"Low"},{"dt":1721815800,"date":"2024-07-24T10:10+0000","height":0.341,"type":"High"}]}');
    var fetcher = TideFetcher(
      appManager.app,
      dateTime(2023, 7, 23),
      const LatLng(0, 0),
    );
    var result = await fetcher.fetch();
    expect(result.data, isNotNull);
    expect(result.errorMessage, isNull);
    expect(result.data!.daysHeights.length, 1);
    expect(result.data!.height.timestamp.toInt(), 1690155000000);
    expect(result.data!.height.value, 0.603);
    expect(result.data!.hasFirstLowTimestamp(), isFalse);
    expect(result.data!.firstHighTimestamp.toInt(), 1690152976000);
    expect(result.data!.hasSecondLowTimestamp(), isFalse);
    expect(result.data!.hasSecondHighTimestamp(), isFalse);
  });

  test("Parsed heights list results in incoming tide", () async {
    // https://www.worldtides.info/api/v3?heights&extremes&date=2023-07-23&lat=37.754998&lon=-122.509074&key=<api-key>
    stubFetchResponse(appManager,
        '{"status":200,"callCount":2,"copyright":"Tidal data retrieved from www.worldtides.info. Copyright (c) 2014-2021 Brainware LLC. Licensed for use of individual spatial coordinates on behalf of/by an end-user. Source data created by the Center for Operational Oceanographic Products and Services (CO-OPS) and is not subject to copyright protection. NO GUARANTEES ARE MADE ABOUT THE CORRECTNESS OF THIS DATA. You may not use it if anyone or anything could come to harm as a result of using it (e.g. for navigational purposes).","requestLat":37.754998,"requestLon":-122.509074,"responseLat":37.775,"responseLon":-122.513,"atlas":"NOAA","station":"Ocean Beach, outer coast, California","heights":[{"dt":1690095600,"date":"2023-07-23T07:00+0000","height":0.248},{"dt":1690097400,"date":"2023-07-23T07:30+0000","height":0.333},{"dt":1690099200,"date":"2023-07-23T08:00+0000","height":0.405},{"dt":1690101000,"date":"2023-07-23T08:30+0000","height":0.457},{"dt":1690102800,"date":"2023-07-23T09:00+0000","height":0.484},{"dt":1690104600,"date":"2023-07-23T09:30+0000","height":0.483},{"dt":1690106400,"date":"2023-07-23T10:00+0000","height":0.452},{"dt":1690108200,"date":"2023-07-23T10:30+0000","height":0.391},{"dt":1690110000,"date":"2023-07-23T11:00+0000","height":0.3},{"dt":1690111800,"date":"2023-07-23T11:30+0000","height":0.183},{"dt":1690113600,"date":"2023-07-23T12:00+0000","height":0.045},{"dt":1690115400,"date":"2023-07-23T12:30+0000","height":-0.106},{"dt":1690117200,"date":"2023-07-23T13:00+0000","height":-0.26},{"dt":1690119000,"date":"2023-07-23T13:30+0000","height":-0.407},{"dt":1690120800,"date":"2023-07-23T14:00+0000","height":-0.536},{"dt":1690122600,"date":"2023-07-23T14:30+0000","height":-0.64},{"dt":1690124400,"date":"2023-07-23T15:00+0000","height":-0.713},{"dt":1690126200,"date":"2023-07-23T15:30+0000","height":-0.754},{"dt":1690128000,"date":"2023-07-23T16:00+0000","height":-0.76},{"dt":1690129800,"date":"2023-07-23T16:30+0000","height":-0.733},{"dt":1690131600,"date":"2023-07-23T17:00+0000","height":-0.674},{"dt":1690133400,"date":"2023-07-23T17:30+0000","height":-0.585},{"dt":1690135200,"date":"2023-07-23T18:00+0000","height":-0.47},{"dt":1690137000,"date":"2023-07-23T18:30+0000","height":-0.335},{"dt":1690138800,"date":"2023-07-23T19:00+0000","height":-0.185},{"dt":1690140600,"date":"2023-07-23T19:30+0000","height":-0.029},{"dt":1690142400,"date":"2023-07-23T20:00+0000","height":0.124},{"dt":1690144200,"date":"2023-07-23T20:30+0000","height":0.266},{"dt":1690146000,"date":"2023-07-23T21:00+0000","height":0.39},{"dt":1690147800,"date":"2023-07-23T21:30+0000","height":0.492},{"dt":1690149600,"date":"2023-07-23T22:00+0000","height":0.567},{"dt":1690151400,"date":"2023-07-23T22:30+0000","height":0.611},{"dt":1690153200,"date":"2023-07-23T23:00+0000","height":0.623},{"dt":1690155000,"date":"2023-07-23T23:30+0000","height":0.603},{"dt":1690156800,"date":"2023-07-24T00:00+0000","height":0.552},{"dt":1690158600,"date":"2023-07-24T00:30+0000","height":0.474},{"dt":1690160400,"date":"2023-07-24T01:00+0000","height":0.375},{"dt":1690162200,"date":"2023-07-24T01:30+0000","height":0.265},{"dt":1690164000,"date":"2023-07-24T02:00+0000","height":0.153},{"dt":1690165800,"date":"2023-07-24T02:30+0000","height":0.047},{"dt":1690167600,"date":"2023-07-24T03:00+0000","height":-0.045},{"dt":1690169400,"date":"2023-07-24T03:30+0000","height":-0.118},{"dt":1690171200,"date":"2023-07-24T04:00+0000","height":-0.169},{"dt":1690173000,"date":"2023-07-24T04:30+0000","height":-0.197},{"dt":1690174800,"date":"2023-07-24T05:00+0000","height":-0.202},{"dt":1690176600,"date":"2023-07-24T05:30+0000","height":-0.184},{"dt":1690178400,"date":"2023-07-24T06:00+0000","height":-0.144},{"dt":1690180200,"date":"2023-07-24T06:30+0000","height":-0.087},{"dt":1690182000,"date":"2023-07-24T07:00+0000","height":-0.015},{"dt":1690183800,"date":"2023-07-24T07:30+0000","height":0.065},{"dt":1690185600,"date":"2023-07-24T08:00+0000","height":0.145},{"dt":1690187400,"date":"2023-07-24T08:30+0000","height":0.218},{"dt":1690189200,"date":"2023-07-24T09:00+0000","height":0.278},{"dt":1690191000,"date":"2023-07-24T09:30+0000","height":0.32},{"dt":1690192800,"date":"2023-07-24T10:00+0000","height":0.34},{"dt":1690194600,"date":"2023-07-24T10:30+0000","height":0.336},{"dt":1690196400,"date":"2023-07-24T11:00+0000","height":0.307},{"dt":1690198200,"date":"2023-07-24T11:30+0000","height":0.253},{"dt":1690200000,"date":"2023-07-24T12:00+0000","height":0.175},{"dt":1690201800,"date":"2023-07-24T12:30+0000","height":0.077},{"dt":1690203600,"date":"2023-07-24T13:00+0000","height":-0.036},{"dt":1690205400,"date":"2023-07-24T13:30+0000","height":-0.157},{"dt":1690207200,"date":"2023-07-24T14:00+0000","height":-0.277},{"dt":1690209000,"date":"2023-07-24T14:30+0000","height":-0.387},{"dt":1690210800,"date":"2023-07-24T15:00+0000","height":-0.478},{"dt":1690212600,"date":"2023-07-24T15:30+0000","height":-0.546},{"dt":1690214400,"date":"2023-07-24T16:00+0000","height":-0.586},{"dt":1690216200,"date":"2023-07-24T16:30+0000","height":-0.597},{"dt":1690218000,"date":"2023-07-24T17:00+0000","height":-0.579},{"dt":1690219800,"date":"2023-07-24T17:30+0000","height":-0.533},{"dt":1690221600,"date":"2023-07-24T18:00+0000","height":-0.459},{"dt":1690223400,"date":"2023-07-24T18:30+0000","height":-0.361},{"dt":1690225200,"date":"2023-07-24T19:00+0000","height":-0.242},{"dt":1690227000,"date":"2023-07-24T19:30+0000","height":-0.107},{"dt":1690228800,"date":"2023-07-24T20:00+0000","height":0.037},{"dt":1690230600,"date":"2023-07-24T20:30+0000","height":0.181},{"dt":1690232400,"date":"2023-07-24T21:00+0000","height":0.318},{"dt":1690234200,"date":"2023-07-24T21:30+0000","height":0.44},{"dt":1690236000,"date":"2023-07-24T22:00+0000","height":0.541},{"dt":1690237800,"date":"2023-07-24T22:30+0000","height":0.617},{"dt":1690239600,"date":"2023-07-24T23:00+0000","height":0.664},{"dt":1690241400,"date":"2023-07-24T23:30+0000","height":0.68},{"dt":1690243200,"date":"2023-07-25T00:00+0000","height":0.664},{"dt":1690245000,"date":"2023-07-25T00:30+0000","height":0.616},{"dt":1690246800,"date":"2023-07-25T01:00+0000","height":0.539},{"dt":1690248600,"date":"2023-07-25T01:30+0000","height":0.438},{"dt":1690250400,"date":"2023-07-25T02:00+0000","height":0.32},{"dt":1690252200,"date":"2023-07-25T02:30+0000","height":0.195},{"dt":1690254000,"date":"2023-07-25T03:00+0000","height":0.072},{"dt":1690255800,"date":"2023-07-25T03:30+0000","height":-0.042},{"dt":1690257600,"date":"2023-07-25T04:00+0000","height":-0.139},{"dt":1690259400,"date":"2023-07-25T04:30+0000","height":-0.216},{"dt":1690261200,"date":"2023-07-25T05:00+0000","height":-0.271},{"dt":1690263000,"date":"2023-07-25T05:30+0000","height":-0.302},{"dt":1690264800,"date":"2023-07-25T06:00+0000","height":-0.31},{"dt":1690266600,"date":"2023-07-25T06:30+0000","height":-0.295},{"dt":1690268400,"date":"2023-07-25T07:00+0000","height":-0.26}],"extremes":[{"dt":1690103643,"date":"2023-07-23T09:14+0000","height":0.487,"type":"High"},{"dt":1690127434,"date":"2023-07-23T15:50+0000","height":-0.762,"type":"Low"},{"dt":1690152976,"date":"2023-07-23T22:56+0000","height":0.623,"type":"High"},{"dt":1690174270,"date":"2023-07-24T04:51+0000","height":-0.203,"type":"Low"},{"dt":1690193404,"date":"2023-07-24T10:10+0000","height":0.341,"type":"High"},{"dt":1690215982,"date":"2023-07-24T16:26+0000","height":-0.598,"type":"Low"},{"dt":1690241392,"date":"2023-07-24T23:29+0000","height":0.68,"type":"High"},{"dt":1690264512,"date":"2023-07-25T05:55+0000","height":-0.31,"type":"Low"}]}');
    var fetcher = TideFetcher(
      appManager.app,
      // Use same timezone where real fetch was made (i.e. Chicago).
      TZDateTime(getLocation("America/Chicago"), 2023, 7, 23, 15, 30),
      const LatLng(0, 0),
    );
    var result = await fetcher.fetch();
    expect(result.data, isNotNull);
    expect(result.errorMessage, isNull);
    expect(result.data!.type, TideType.incoming);
  });

  test("Parsed heights list results in outgoing tide", () async {
    // https://www.worldtides.info/api/v3?heights&extremes&date=2023-07-23&lat=37.754998&lon=-122.509074&key=<api-key>
    stubFetchResponse(appManager,
        '{"status":200,"callCount":2,"copyright":"Tidal data retrieved from www.worldtides.info. Copyright (c) 2014-2021 Brainware LLC. Licensed for use of individual spatial coordinates on behalf of/by an end-user. Source data created by the Center for Operational Oceanographic Products and Services (CO-OPS) and is not subject to copyright protection. NO GUARANTEES ARE MADE ABOUT THE CORRECTNESS OF THIS DATA. You may not use it if anyone or anything could come to harm as a result of using it (e.g. for navigational purposes).","requestLat":37.754998,"requestLon":-122.509074,"responseLat":37.775,"responseLon":-122.513,"atlas":"NOAA","station":"Ocean Beach, outer coast, California","heights":[{"dt":1690095600,"date":"2023-07-23T07:00+0000","height":0.248},{"dt":1690097400,"date":"2023-07-23T07:30+0000","height":0.333},{"dt":1690099200,"date":"2023-07-23T08:00+0000","height":0.405},{"dt":1690101000,"date":"2023-07-23T08:30+0000","height":0.457},{"dt":1690102800,"date":"2023-07-23T09:00+0000","height":0.484},{"dt":1690104600,"date":"2023-07-23T09:30+0000","height":0.483},{"dt":1690106400,"date":"2023-07-23T10:00+0000","height":0.452},{"dt":1690108200,"date":"2023-07-23T10:30+0000","height":0.391},{"dt":1690110000,"date":"2023-07-23T11:00+0000","height":0.3},{"dt":1690111800,"date":"2023-07-23T11:30+0000","height":0.183},{"dt":1690113600,"date":"2023-07-23T12:00+0000","height":0.045},{"dt":1690115400,"date":"2023-07-23T12:30+0000","height":-0.106},{"dt":1690117200,"date":"2023-07-23T13:00+0000","height":-0.26},{"dt":1690119000,"date":"2023-07-23T13:30+0000","height":-0.407},{"dt":1690120800,"date":"2023-07-23T14:00+0000","height":-0.536},{"dt":1690122600,"date":"2023-07-23T14:30+0000","height":-0.64},{"dt":1690124400,"date":"2023-07-23T15:00+0000","height":-0.713},{"dt":1690126200,"date":"2023-07-23T15:30+0000","height":-0.754},{"dt":1690128000,"date":"2023-07-23T16:00+0000","height":-0.76},{"dt":1690129800,"date":"2023-07-23T16:30+0000","height":-0.733},{"dt":1690131600,"date":"2023-07-23T17:00+0000","height":-0.674},{"dt":1690133400,"date":"2023-07-23T17:30+0000","height":-0.585},{"dt":1690135200,"date":"2023-07-23T18:00+0000","height":-0.47},{"dt":1690137000,"date":"2023-07-23T18:30+0000","height":-0.335},{"dt":1690138800,"date":"2023-07-23T19:00+0000","height":-0.185},{"dt":1690140600,"date":"2023-07-23T19:30+0000","height":-0.029},{"dt":1690142400,"date":"2023-07-23T20:00+0000","height":0.124},{"dt":1690144200,"date":"2023-07-23T20:30+0000","height":0.266},{"dt":1690146000,"date":"2023-07-23T21:00+0000","height":0.39},{"dt":1690147800,"date":"2023-07-23T21:30+0000","height":0.492},{"dt":1690149600,"date":"2023-07-23T22:00+0000","height":0.567},{"dt":1690151400,"date":"2023-07-23T22:30+0000","height":0.611},{"dt":1690153200,"date":"2023-07-23T23:00+0000","height":0.623},{"dt":1690155000,"date":"2023-07-23T23:30+0000","height":0.603},{"dt":1690156800,"date":"2023-07-24T00:00+0000","height":0.552},{"dt":1690158600,"date":"2023-07-24T00:30+0000","height":0.474},{"dt":1690160400,"date":"2023-07-24T01:00+0000","height":0.375},{"dt":1690162200,"date":"2023-07-24T01:30+0000","height":0.265},{"dt":1690164000,"date":"2023-07-24T02:00+0000","height":0.153},{"dt":1690165800,"date":"2023-07-24T02:30+0000","height":0.047},{"dt":1690167600,"date":"2023-07-24T03:00+0000","height":-0.045},{"dt":1690169400,"date":"2023-07-24T03:30+0000","height":-0.118},{"dt":1690171200,"date":"2023-07-24T04:00+0000","height":-0.169},{"dt":1690173000,"date":"2023-07-24T04:30+0000","height":-0.197},{"dt":1690174800,"date":"2023-07-24T05:00+0000","height":-0.202},{"dt":1690176600,"date":"2023-07-24T05:30+0000","height":-0.184},{"dt":1690178400,"date":"2023-07-24T06:00+0000","height":-0.144},{"dt":1690180200,"date":"2023-07-24T06:30+0000","height":-0.087},{"dt":1690182000,"date":"2023-07-24T07:00+0000","height":-0.015},{"dt":1690183800,"date":"2023-07-24T07:30+0000","height":0.065},{"dt":1690185600,"date":"2023-07-24T08:00+0000","height":0.145},{"dt":1690187400,"date":"2023-07-24T08:30+0000","height":0.218},{"dt":1690189200,"date":"2023-07-24T09:00+0000","height":0.278},{"dt":1690191000,"date":"2023-07-24T09:30+0000","height":0.32},{"dt":1690192800,"date":"2023-07-24T10:00+0000","height":0.34},{"dt":1690194600,"date":"2023-07-24T10:30+0000","height":0.336},{"dt":1690196400,"date":"2023-07-24T11:00+0000","height":0.307},{"dt":1690198200,"date":"2023-07-24T11:30+0000","height":0.253},{"dt":1690200000,"date":"2023-07-24T12:00+0000","height":0.175},{"dt":1690201800,"date":"2023-07-24T12:30+0000","height":0.077},{"dt":1690203600,"date":"2023-07-24T13:00+0000","height":-0.036},{"dt":1690205400,"date":"2023-07-24T13:30+0000","height":-0.157},{"dt":1690207200,"date":"2023-07-24T14:00+0000","height":-0.277},{"dt":1690209000,"date":"2023-07-24T14:30+0000","height":-0.387},{"dt":1690210800,"date":"2023-07-24T15:00+0000","height":-0.478},{"dt":1690212600,"date":"2023-07-24T15:30+0000","height":-0.546},{"dt":1690214400,"date":"2023-07-24T16:00+0000","height":-0.586},{"dt":1690216200,"date":"2023-07-24T16:30+0000","height":-0.597},{"dt":1690218000,"date":"2023-07-24T17:00+0000","height":-0.579},{"dt":1690219800,"date":"2023-07-24T17:30+0000","height":-0.533},{"dt":1690221600,"date":"2023-07-24T18:00+0000","height":-0.459},{"dt":1690223400,"date":"2023-07-24T18:30+0000","height":-0.361},{"dt":1690225200,"date":"2023-07-24T19:00+0000","height":-0.242},{"dt":1690227000,"date":"2023-07-24T19:30+0000","height":-0.107},{"dt":1690228800,"date":"2023-07-24T20:00+0000","height":0.037},{"dt":1690230600,"date":"2023-07-24T20:30+0000","height":0.181},{"dt":1690232400,"date":"2023-07-24T21:00+0000","height":0.318},{"dt":1690234200,"date":"2023-07-24T21:30+0000","height":0.44},{"dt":1690236000,"date":"2023-07-24T22:00+0000","height":0.541},{"dt":1690237800,"date":"2023-07-24T22:30+0000","height":0.617},{"dt":1690239600,"date":"2023-07-24T23:00+0000","height":0.664},{"dt":1690241400,"date":"2023-07-24T23:30+0000","height":0.68},{"dt":1690243200,"date":"2023-07-25T00:00+0000","height":0.664},{"dt":1690245000,"date":"2023-07-25T00:30+0000","height":0.616},{"dt":1690246800,"date":"2023-07-25T01:00+0000","height":0.539},{"dt":1690248600,"date":"2023-07-25T01:30+0000","height":0.438},{"dt":1690250400,"date":"2023-07-25T02:00+0000","height":0.32},{"dt":1690252200,"date":"2023-07-25T02:30+0000","height":0.195},{"dt":1690254000,"date":"2023-07-25T03:00+0000","height":0.072},{"dt":1690255800,"date":"2023-07-25T03:30+0000","height":-0.042},{"dt":1690257600,"date":"2023-07-25T04:00+0000","height":-0.139},{"dt":1690259400,"date":"2023-07-25T04:30+0000","height":-0.216},{"dt":1690261200,"date":"2023-07-25T05:00+0000","height":-0.271},{"dt":1690263000,"date":"2023-07-25T05:30+0000","height":-0.302},{"dt":1690264800,"date":"2023-07-25T06:00+0000","height":-0.31},{"dt":1690266600,"date":"2023-07-25T06:30+0000","height":-0.295},{"dt":1690268400,"date":"2023-07-25T07:00+0000","height":-0.26}],"extremes":[{"dt":1690103643,"date":"2023-07-23T09:14+0000","height":0.487,"type":"High"},{"dt":1690127434,"date":"2023-07-23T15:50+0000","height":-0.762,"type":"Low"},{"dt":1690152976,"date":"2023-07-23T22:56+0000","height":0.623,"type":"High"},{"dt":1690174270,"date":"2023-07-24T04:51+0000","height":-0.203,"type":"Low"},{"dt":1690193404,"date":"2023-07-24T10:10+0000","height":0.341,"type":"High"},{"dt":1690215982,"date":"2023-07-24T16:26+0000","height":-0.598,"type":"Low"},{"dt":1690241392,"date":"2023-07-24T23:29+0000","height":0.68,"type":"High"},{"dt":1690264512,"date":"2023-07-25T05:55+0000","height":-0.31,"type":"Low"}]}');
    var fetcher = TideFetcher(
      appManager.app,
      // Use same timezone where real fetch was made (i.e. Chicago).
      TZDateTime(getLocation("America/Chicago"), 2023, 7, 23, 10, 30),
      const LatLng(0, 0),
    );
    var result = await fetcher.fetch();
    expect(result.data, isNotNull);
    expect(result.errorMessage, isNull);
    expect(result.data!.type, TideType.outgoing);
  });

  test("Parse extremes list with one low/high", () async {
    stubFetchResponse(appManager,
        '{"status":200,"callCount":2,"copyright":"Tidal data retrieved from www.worldtides.info. Copyright (c) 2014-2021 Brainware LLC. Licensed for use of individual spatial coordinates on behalf of/by an end-user. Source data created by the Center for Operational Oceanographic Products and Services (CO-OPS) and is not subject to copyright protection. NO GUARANTEES ARE MADE ABOUT THE CORRECTNESS OF THIS DATA. You may not use it if anyone or anything could come to harm as a result of using it (e.g. for navigational purposes).","requestLat":37.754998,"requestLon":-122.509074,"responseLat":37.775,"responseLon":-122.513,"atlas":"NOAA","station":"Ocean Beach, outer coast, California","heights":[{"dt":1690095600,"date":"2023-07-23T07:00+0000","height":0.248},{"dt":1690097400,"date":"2023-07-23T07:30+0000","height":0.333},{"dt":1690099200,"date":"2023-07-23T08:00+0000","height":0.405},{"dt":1690101000,"date":"2023-07-23T08:30+0000","height":0.457},{"dt":1690102800,"date":"2023-07-23T09:00+0000","height":0.484},{"dt":1690104600,"date":"2023-07-23T09:30+0000","height":0.483},{"dt":1690106400,"date":"2023-07-23T10:00+0000","height":0.452},{"dt":1690108200,"date":"2023-07-23T10:30+0000","height":0.391},{"dt":1690110000,"date":"2023-07-23T11:00+0000","height":0.3},{"dt":1690111800,"date":"2023-07-23T11:30+0000","height":0.183},{"dt":1690113600,"date":"2023-07-23T12:00+0000","height":0.045},{"dt":1690115400,"date":"2023-07-23T12:30+0000","height":-0.106},{"dt":1690117200,"date":"2023-07-23T13:00+0000","height":-0.26},{"dt":1690119000,"date":"2023-07-23T13:30+0000","height":-0.407},{"dt":1690120800,"date":"2023-07-23T14:00+0000","height":-0.536},{"dt":1690122600,"date":"2023-07-23T14:30+0000","height":-0.64},{"dt":1690124400,"date":"2023-07-23T15:00+0000","height":-0.713},{"dt":1690126200,"date":"2023-07-23T15:30+0000","height":-0.754},{"dt":1690128000,"date":"2023-07-23T16:00+0000","height":-0.76},{"dt":1690129800,"date":"2023-07-23T16:30+0000","height":-0.733},{"dt":1690131600,"date":"2023-07-23T17:00+0000","height":-0.674},{"dt":1690133400,"date":"2023-07-23T17:30+0000","height":-0.585},{"dt":1690135200,"date":"2023-07-23T18:00+0000","height":-0.47},{"dt":1690137000,"date":"2023-07-23T18:30+0000","height":-0.335},{"dt":1690138800,"date":"2023-07-23T19:00+0000","height":-0.185},{"dt":1690140600,"date":"2023-07-23T19:30+0000","height":-0.029},{"dt":1690142400,"date":"2023-07-23T20:00+0000","height":0.124},{"dt":1690144200,"date":"2023-07-23T20:30+0000","height":0.266},{"dt":1690146000,"date":"2023-07-23T21:00+0000","height":0.39},{"dt":1690147800,"date":"2023-07-23T21:30+0000","height":0.492},{"dt":1690149600,"date":"2023-07-23T22:00+0000","height":0.567},{"dt":1690151400,"date":"2023-07-23T22:30+0000","height":0.611},{"dt":1690153200,"date":"2023-07-23T23:00+0000","height":0.623},{"dt":1690155000,"date":"2023-07-23T23:30+0000","height":0.603},{"dt":1690156800,"date":"2023-07-24T00:00+0000","height":0.552},{"dt":1690158600,"date":"2023-07-24T00:30+0000","height":0.474},{"dt":1690160400,"date":"2023-07-24T01:00+0000","height":0.375},{"dt":1690162200,"date":"2023-07-24T01:30+0000","height":0.265},{"dt":1690164000,"date":"2023-07-24T02:00+0000","height":0.153},{"dt":1690165800,"date":"2023-07-24T02:30+0000","height":0.047},{"dt":1690167600,"date":"2023-07-24T03:00+0000","height":-0.045},{"dt":1690169400,"date":"2023-07-24T03:30+0000","height":-0.118},{"dt":1690171200,"date":"2023-07-24T04:00+0000","height":-0.169},{"dt":1690173000,"date":"2023-07-24T04:30+0000","height":-0.197},{"dt":1690174800,"date":"2023-07-24T05:00+0000","height":-0.202},{"dt":1690176600,"date":"2023-07-24T05:30+0000","height":-0.184},{"dt":1690178400,"date":"2023-07-24T06:00+0000","height":-0.144},{"dt":1690180200,"date":"2023-07-24T06:30+0000","height":-0.087},{"dt":1690182000,"date":"2023-07-24T07:00+0000","height":-0.015},{"dt":1690183800,"date":"2023-07-24T07:30+0000","height":0.065},{"dt":1690185600,"date":"2023-07-24T08:00+0000","height":0.145},{"dt":1690187400,"date":"2023-07-24T08:30+0000","height":0.218},{"dt":1690189200,"date":"2023-07-24T09:00+0000","height":0.278},{"dt":1690191000,"date":"2023-07-24T09:30+0000","height":0.32},{"dt":1690192800,"date":"2023-07-24T10:00+0000","height":0.34},{"dt":1690194600,"date":"2023-07-24T10:30+0000","height":0.336},{"dt":1690196400,"date":"2023-07-24T11:00+0000","height":0.307},{"dt":1690198200,"date":"2023-07-24T11:30+0000","height":0.253},{"dt":1690200000,"date":"2023-07-24T12:00+0000","height":0.175},{"dt":1690201800,"date":"2023-07-24T12:30+0000","height":0.077},{"dt":1690203600,"date":"2023-07-24T13:00+0000","height":-0.036},{"dt":1690205400,"date":"2023-07-24T13:30+0000","height":-0.157},{"dt":1690207200,"date":"2023-07-24T14:00+0000","height":-0.277},{"dt":1690209000,"date":"2023-07-24T14:30+0000","height":-0.387},{"dt":1690210800,"date":"2023-07-24T15:00+0000","height":-0.478},{"dt":1690212600,"date":"2023-07-24T15:30+0000","height":-0.546},{"dt":1690214400,"date":"2023-07-24T16:00+0000","height":-0.586},{"dt":1690216200,"date":"2023-07-24T16:30+0000","height":-0.597},{"dt":1690218000,"date":"2023-07-24T17:00+0000","height":-0.579},{"dt":1690219800,"date":"2023-07-24T17:30+0000","height":-0.533},{"dt":1690221600,"date":"2023-07-24T18:00+0000","height":-0.459},{"dt":1690223400,"date":"2023-07-24T18:30+0000","height":-0.361},{"dt":1690225200,"date":"2023-07-24T19:00+0000","height":-0.242},{"dt":1690227000,"date":"2023-07-24T19:30+0000","height":-0.107},{"dt":1690228800,"date":"2023-07-24T20:00+0000","height":0.037},{"dt":1690230600,"date":"2023-07-24T20:30+0000","height":0.181},{"dt":1690232400,"date":"2023-07-24T21:00+0000","height":0.318},{"dt":1690234200,"date":"2023-07-24T21:30+0000","height":0.44},{"dt":1690236000,"date":"2023-07-24T22:00+0000","height":0.541},{"dt":1690237800,"date":"2023-07-24T22:30+0000","height":0.617},{"dt":1690239600,"date":"2023-07-24T23:00+0000","height":0.664},{"dt":1690241400,"date":"2023-07-24T23:30+0000","height":0.68},{"dt":1690243200,"date":"2023-07-25T00:00+0000","height":0.664},{"dt":1690245000,"date":"2023-07-25T00:30+0000","height":0.616},{"dt":1690246800,"date":"2023-07-25T01:00+0000","height":0.539},{"dt":1690248600,"date":"2023-07-25T01:30+0000","height":0.438},{"dt":1690250400,"date":"2023-07-25T02:00+0000","height":0.32},{"dt":1690252200,"date":"2023-07-25T02:30+0000","height":0.195},{"dt":1690254000,"date":"2023-07-25T03:00+0000","height":0.072},{"dt":1690255800,"date":"2023-07-25T03:30+0000","height":-0.042},{"dt":1690257600,"date":"2023-07-25T04:00+0000","height":-0.139},{"dt":1690259400,"date":"2023-07-25T04:30+0000","height":-0.216},{"dt":1690261200,"date":"2023-07-25T05:00+0000","height":-0.271},{"dt":1690263000,"date":"2023-07-25T05:30+0000","height":-0.302},{"dt":1690264800,"date":"2023-07-25T06:00+0000","height":-0.31},{"dt":1690266600,"date":"2023-07-25T06:30+0000","height":-0.295},{"dt":1690268400,"date":"2023-07-25T07:00+0000","height":-0.26}],"extremes":[{"dt":1690103643,"date":"2023-07-23T09:14+0000","height":0.487,"type":"High"},{"dt":1690127434,"date":"2023-07-23T15:50+0000","height":-0.762,"type":"Low"}]}');
    var fetcher = TideFetcher(
      appManager.app,
      // Use same timezone where real fetch was made (i.e. Chicago).
      TZDateTime(getLocation("America/Chicago"), 2023, 7, 23, 10, 30),
      const LatLng(0, 0),
    );
    var result = await fetcher.fetch();
    expect(result.data, isNotNull);
    expect(result.errorMessage, isNull);
    expect(result.data!.hasFirstLowTimestamp(), isTrue);
    expect(result.data!.hasFirstHighTimestamp(), isTrue);
    expect(result.data!.hasSecondLowTimestamp(), isFalse);
    expect(result.data!.hasSecondLowTimestamp(), isFalse);
  });

  test("Parse extremes list with two low/high", () async {
    // https://www.worldtides.info/api/v3?heights&extremes&date=2023-07-23&lat=37.754998&lon=-122.509074&key=<api-key>
    stubFetchResponse(appManager,
        '{"status":200,"callCount":2,"copyright":"Tidal data retrieved from www.worldtides.info. Copyright (c) 2014-2021 Brainware LLC. Licensed for use of individual spatial coordinates on behalf of/by an end-user. Source data created by the Center for Operational Oceanographic Products and Services (CO-OPS) and is not subject to copyright protection. NO GUARANTEES ARE MADE ABOUT THE CORRECTNESS OF THIS DATA. You may not use it if anyone or anything could come to harm as a result of using it (e.g. for navigational purposes).","requestLat":37.754998,"requestLon":-122.509074,"responseLat":37.775,"responseLon":-122.513,"atlas":"NOAA","station":"Ocean Beach, outer coast, California","heights":[{"dt":1690095600,"date":"2023-07-23T07:00+0000","height":0.248},{"dt":1690097400,"date":"2023-07-23T07:30+0000","height":0.333},{"dt":1690099200,"date":"2023-07-23T08:00+0000","height":0.405},{"dt":1690101000,"date":"2023-07-23T08:30+0000","height":0.457},{"dt":1690102800,"date":"2023-07-23T09:00+0000","height":0.484},{"dt":1690104600,"date":"2023-07-23T09:30+0000","height":0.483},{"dt":1690106400,"date":"2023-07-23T10:00+0000","height":0.452},{"dt":1690108200,"date":"2023-07-23T10:30+0000","height":0.391},{"dt":1690110000,"date":"2023-07-23T11:00+0000","height":0.3},{"dt":1690111800,"date":"2023-07-23T11:30+0000","height":0.183},{"dt":1690113600,"date":"2023-07-23T12:00+0000","height":0.045},{"dt":1690115400,"date":"2023-07-23T12:30+0000","height":-0.106},{"dt":1690117200,"date":"2023-07-23T13:00+0000","height":-0.26},{"dt":1690119000,"date":"2023-07-23T13:30+0000","height":-0.407},{"dt":1690120800,"date":"2023-07-23T14:00+0000","height":-0.536},{"dt":1690122600,"date":"2023-07-23T14:30+0000","height":-0.64},{"dt":1690124400,"date":"2023-07-23T15:00+0000","height":-0.713},{"dt":1690126200,"date":"2023-07-23T15:30+0000","height":-0.754},{"dt":1690128000,"date":"2023-07-23T16:00+0000","height":-0.76},{"dt":1690129800,"date":"2023-07-23T16:30+0000","height":-0.733},{"dt":1690131600,"date":"2023-07-23T17:00+0000","height":-0.674},{"dt":1690133400,"date":"2023-07-23T17:30+0000","height":-0.585},{"dt":1690135200,"date":"2023-07-23T18:00+0000","height":-0.47},{"dt":1690137000,"date":"2023-07-23T18:30+0000","height":-0.335},{"dt":1690138800,"date":"2023-07-23T19:00+0000","height":-0.185},{"dt":1690140600,"date":"2023-07-23T19:30+0000","height":-0.029},{"dt":1690142400,"date":"2023-07-23T20:00+0000","height":0.124},{"dt":1690144200,"date":"2023-07-23T20:30+0000","height":0.266},{"dt":1690146000,"date":"2023-07-23T21:00+0000","height":0.39},{"dt":1690147800,"date":"2023-07-23T21:30+0000","height":0.492},{"dt":1690149600,"date":"2023-07-23T22:00+0000","height":0.567},{"dt":1690151400,"date":"2023-07-23T22:30+0000","height":0.611},{"dt":1690153200,"date":"2023-07-23T23:00+0000","height":0.623},{"dt":1690155000,"date":"2023-07-23T23:30+0000","height":0.603},{"dt":1690156800,"date":"2023-07-24T00:00+0000","height":0.552},{"dt":1690158600,"date":"2023-07-24T00:30+0000","height":0.474},{"dt":1690160400,"date":"2023-07-24T01:00+0000","height":0.375},{"dt":1690162200,"date":"2023-07-24T01:30+0000","height":0.265},{"dt":1690164000,"date":"2023-07-24T02:00+0000","height":0.153},{"dt":1690165800,"date":"2023-07-24T02:30+0000","height":0.047},{"dt":1690167600,"date":"2023-07-24T03:00+0000","height":-0.045},{"dt":1690169400,"date":"2023-07-24T03:30+0000","height":-0.118},{"dt":1690171200,"date":"2023-07-24T04:00+0000","height":-0.169},{"dt":1690173000,"date":"2023-07-24T04:30+0000","height":-0.197},{"dt":1690174800,"date":"2023-07-24T05:00+0000","height":-0.202},{"dt":1690176600,"date":"2023-07-24T05:30+0000","height":-0.184},{"dt":1690178400,"date":"2023-07-24T06:00+0000","height":-0.144},{"dt":1690180200,"date":"2023-07-24T06:30+0000","height":-0.087},{"dt":1690182000,"date":"2023-07-24T07:00+0000","height":-0.015},{"dt":1690183800,"date":"2023-07-24T07:30+0000","height":0.065},{"dt":1690185600,"date":"2023-07-24T08:00+0000","height":0.145},{"dt":1690187400,"date":"2023-07-24T08:30+0000","height":0.218},{"dt":1690189200,"date":"2023-07-24T09:00+0000","height":0.278},{"dt":1690191000,"date":"2023-07-24T09:30+0000","height":0.32},{"dt":1690192800,"date":"2023-07-24T10:00+0000","height":0.34},{"dt":1690194600,"date":"2023-07-24T10:30+0000","height":0.336},{"dt":1690196400,"date":"2023-07-24T11:00+0000","height":0.307},{"dt":1690198200,"date":"2023-07-24T11:30+0000","height":0.253},{"dt":1690200000,"date":"2023-07-24T12:00+0000","height":0.175},{"dt":1690201800,"date":"2023-07-24T12:30+0000","height":0.077},{"dt":1690203600,"date":"2023-07-24T13:00+0000","height":-0.036},{"dt":1690205400,"date":"2023-07-24T13:30+0000","height":-0.157},{"dt":1690207200,"date":"2023-07-24T14:00+0000","height":-0.277},{"dt":1690209000,"date":"2023-07-24T14:30+0000","height":-0.387},{"dt":1690210800,"date":"2023-07-24T15:00+0000","height":-0.478},{"dt":1690212600,"date":"2023-07-24T15:30+0000","height":-0.546},{"dt":1690214400,"date":"2023-07-24T16:00+0000","height":-0.586},{"dt":1690216200,"date":"2023-07-24T16:30+0000","height":-0.597},{"dt":1690218000,"date":"2023-07-24T17:00+0000","height":-0.579},{"dt":1690219800,"date":"2023-07-24T17:30+0000","height":-0.533},{"dt":1690221600,"date":"2023-07-24T18:00+0000","height":-0.459},{"dt":1690223400,"date":"2023-07-24T18:30+0000","height":-0.361},{"dt":1690225200,"date":"2023-07-24T19:00+0000","height":-0.242},{"dt":1690227000,"date":"2023-07-24T19:30+0000","height":-0.107},{"dt":1690228800,"date":"2023-07-24T20:00+0000","height":0.037},{"dt":1690230600,"date":"2023-07-24T20:30+0000","height":0.181},{"dt":1690232400,"date":"2023-07-24T21:00+0000","height":0.318},{"dt":1690234200,"date":"2023-07-24T21:30+0000","height":0.44},{"dt":1690236000,"date":"2023-07-24T22:00+0000","height":0.541},{"dt":1690237800,"date":"2023-07-24T22:30+0000","height":0.617},{"dt":1690239600,"date":"2023-07-24T23:00+0000","height":0.664},{"dt":1690241400,"date":"2023-07-24T23:30+0000","height":0.68},{"dt":1690243200,"date":"2023-07-25T00:00+0000","height":0.664},{"dt":1690245000,"date":"2023-07-25T00:30+0000","height":0.616},{"dt":1690246800,"date":"2023-07-25T01:00+0000","height":0.539},{"dt":1690248600,"date":"2023-07-25T01:30+0000","height":0.438},{"dt":1690250400,"date":"2023-07-25T02:00+0000","height":0.32},{"dt":1690252200,"date":"2023-07-25T02:30+0000","height":0.195},{"dt":1690254000,"date":"2023-07-25T03:00+0000","height":0.072},{"dt":1690255800,"date":"2023-07-25T03:30+0000","height":-0.042},{"dt":1690257600,"date":"2023-07-25T04:00+0000","height":-0.139},{"dt":1690259400,"date":"2023-07-25T04:30+0000","height":-0.216},{"dt":1690261200,"date":"2023-07-25T05:00+0000","height":-0.271},{"dt":1690263000,"date":"2023-07-25T05:30+0000","height":-0.302},{"dt":1690264800,"date":"2023-07-25T06:00+0000","height":-0.31},{"dt":1690266600,"date":"2023-07-25T06:30+0000","height":-0.295},{"dt":1690268400,"date":"2023-07-25T07:00+0000","height":-0.26}],"extremes":[{"dt":1690103643,"date":"2023-07-23T09:14+0000","height":0.487,"type":"High"},{"dt":1690127434,"date":"2023-07-23T15:50+0000","height":-0.762,"type":"Low"},{"dt":1690152976,"date":"2023-07-23T22:56+0000","height":0.623,"type":"High"},{"dt":1690174270,"date":"2023-07-24T04:51+0000","height":-0.203,"type":"Low"},{"dt":1690193404,"date":"2023-07-24T10:10+0000","height":0.341,"type":"High"},{"dt":1690215982,"date":"2023-07-24T16:26+0000","height":-0.598,"type":"Low"},{"dt":1690241392,"date":"2023-07-24T23:29+0000","height":0.68,"type":"High"},{"dt":1690264512,"date":"2023-07-25T05:55+0000","height":-0.31,"type":"Low"}]}');
    var fetcher = TideFetcher(
      appManager.app,
      // Use same timezone where real fetch was made (i.e. Chicago).
      TZDateTime(getLocation("America/Chicago"), 2023, 7, 23, 10, 30),
      const LatLng(0, 0),
    );
    var result = await fetcher.fetch();
    expect(result.data, isNotNull);
    expect(result.errorMessage, isNull);
    expect(result.data!.hasFirstLowTimestamp(), isTrue);
    expect(result.data!.hasFirstHighTimestamp(), isTrue);
    expect(result.data!.hasSecondLowTimestamp(), isTrue);
    expect(result.data!.hasSecondLowTimestamp(), isTrue);
  });
}
