import 'dart:io';

import 'package:http/http.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/atmosphere_fetcher.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.propertiesManager.visualCrossingApiKey).thenReturn("");

    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);

    // Set to the VisualCrossing defaults for each measurement type.
    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureImperialUnit)
        .thenReturn(Unit.inch_of_mercury);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
  });

  void expectMissingField(
      String field, bool Function(Atmosphere) hasValue) async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body)
        .thenReturn("{\"currentConditions\":{\"$field\": \"wrong\"}}");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var fetcher =
        AtmosphereFetcher(appManager.app, dateTime(0), const LatLng(0, 0));

    var atmosphere = await fetcher.fetch();
    expect(atmosphere, isNotNull);
    expect(hasValue(atmosphere.data!), isFalse);
  }

  test("Null latLng returns null", () async {
    var fetcher = AtmosphereFetcher(appManager.app, dateTime(0), null);
    expect((await fetcher.fetch()).data, isNull);
  });

  test("HTTP request throws exception", () async {
    when(appManager.httpWrapper.get(any))
        .thenThrow(const SocketException("Test error"));

    var fetcher =
        AtmosphereFetcher(appManager.app, dateTime(0), const LatLng(0, 0));
    expect((await fetcher.fetch()).data, isNull);
  });

  test("Request includes no fields", () async {
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(Response("", HttpStatus.badGateway)));

    var fetcher =
        AtmosphereFetcher(appManager.app, dateTime(0), const LatLng(0, 0));
    expect((await fetcher.fetch()).data, isNull);

    var result = verify(appManager.httpWrapper.get(captureAny));
    expect(result.captured.first is Uri, isTrue);

    var uri = result.captured.first as Uri;
    expect(uri.queryParameters["elements"], isEmpty);
  });

  test("Request includes user preference fields", () async {
    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([
      atmosphereFieldIdTemperature,
      atmosphereFieldIdHumidity,
      atmosphereFieldIdSkyCondition,
      atmosphereFieldIdMoonPhase,
      atmosphereFieldIdPressure,
      atmosphereFieldIdVisibility,
      atmosphereFieldIdWindSpeed,
      atmosphereFieldIdWindDirection,
      atmosphereFieldIdSunriseTimestamp,
      atmosphereFieldIdSunsetTimestamp,
    ]);
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(Response("", HttpStatus.badGateway)));

    var fetcher =
        AtmosphereFetcher(appManager.app, dateTime(0), const LatLng(0, 0));
    expect((await fetcher.fetch()).data, isNull);

    var result = verify(appManager.httpWrapper.get(captureAny));
    expect(result.captured.first is Uri, isTrue);

    var uri = result.captured.first as Uri;
    expect(
      uri.queryParameters["elements"],
      "temp,humidity,conditions,moonphase,pressure,visibility,windspeed,"
      "winddir,sunriseEpoch,sunsetEpoch",
    );
  });

  test("Response includes invalid JSON", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("not JSON");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var fetcher =
        AtmosphereFetcher(appManager.app, dateTime(0), const LatLng(0, 0));
    expect((await fetcher.fetch()).data, isNull);
  });

  test("Response invalid 'currentConditions' key", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    // Null.
    when(response.body).thenReturn("{\"currentConditions\":null}");
    var fetcher =
        AtmosphereFetcher(appManager.app, dateTime(0), const LatLng(0, 0));
    expect((await fetcher.fetch()).data, isNull);
  });

  test("Wrong data type - temperature", () async {
    expectMissingField("temp", (atmosphere) => atmosphere.hasTemperature());
  });

  test("Wrong data type - humidity", () async {
    expectMissingField("humidity", (atmosphere) => atmosphere.hasHumidity());
  });

  test("Wrong data type - wind speed", () async {
    expectMissingField("windspeed", (atmosphere) => atmosphere.hasWindSpeed());
  });

  test("Wrong data type - wind direction", () async {
    expectMissingField(
        "winddir", (atmosphere) => atmosphere.hasWindDirection());
  });

  test("Wrong data type - pressure", () async {
    expectMissingField("pressure", (atmosphere) => atmosphere.hasPressure());
  });

  test("Wrong data type - visibility", () async {
    expectMissingField(
        "visibility", (atmosphere) => atmosphere.hasVisibility());
  });

  test("Wrong data type - conditions", () async {
    expectMissingField(
        "conditions", (atmosphere) => atmosphere.skyConditions.isNotEmpty);
  });

  test("Wrong data type - sunrise", () async {
    expectMissingField(
        "sunriseEpoch", (atmosphere) => atmosphere.hasSunsetTimestamp());
  });

  test("Wrong data type - sunset", () async {
    expectMissingField(
        "sunsetEpoch", (atmosphere) => atmosphere.hasSunsetTimestamp());
  });

  test("Wrong data type - moon phase", () async {
    expectMissingField("moonphase", (atmosphere) => atmosphere.hasMoonPhase());
  });

  test("Successful response", () async {
    // Real response from VisualCrossing API.
    var json =
        '{"queryCost":1,"latitude":35.925178304610114,"longitude":-83.96468538790941,"resolvedAddress":"35.925178304610114,-83.96468538790941","address":"35.925178304610114,-83.96468538790941","timezone":"America/New_York","tzoffset":-4.0,"days":[{"temp":77.9,"humidity":79.15,"windspeed":12.1,"winddir":93.8,"pressure":1021.9,"visibility":9.9,"sunriseEpoch":1624962142,"sunsetEpoch":1625014586,"moonphase":0.64,"conditions":"type_21, type_42"}],"currentConditions":{"temp":74.0,"humidity":90.3,"windspeed":4.7,"winddir":8.0,"pressure":1022.5,"visibility":9.9,"conditions":"type_42","sunriseEpoch":1624962142,"sunsetEpoch":1625014586,"moonphase":0.63}}';
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn(json);
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var fetcher =
        AtmosphereFetcher(appManager.app, dateTime(0), const LatLng(0, 0));

    var atmosphere = (await fetcher.fetch()).data;
    expect(atmosphere, isNotNull);
    expect(atmosphere!.temperature.mainValue.value, 74.0);
    expect(atmosphere.temperature.mainValue.unit, Unit.fahrenheit);
    expect(atmosphere.humidity.mainValue.value, 90.0);
    expect(atmosphere.windSpeed.mainValue.value, 4.7);
    expect(atmosphere.windSpeed.mainValue.unit, Unit.miles_per_hour);
    expect(atmosphere.windDirection, Direction.north);
    expect(atmosphere.pressure.mainValue.value, 1022.5);
    expect(atmosphere.pressure.mainValue.unit, Unit.millibars);
    expect(atmosphere.visibility.mainValue.value, 9.9);
    expect(atmosphere.visibility.mainValue.unit, Unit.miles);
    expect(atmosphere.sunriseTimestamp.toInt(), 1624962142000); // ms
    expect(atmosphere.sunsetTimestamp.toInt(), 1625014586000); // ms
    expect(atmosphere.moonPhase, MoonPhase.waning_gibbous);
    expect(atmosphere.skyConditions, [SkyCondition.cloudy]);
    expect(atmosphere.timeZone, defaultTimeZone);
  });

  test("API value is converted to user preference units", () async {
    // Set to something different from the VisualCrossing default.
    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
    when(appManager.userPreferenceManager.airPressureImperialUnit)
        .thenReturn(Unit.pounds_per_square_inch);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);

    // Real response from VisualCrossing API.
    var json =
        '{"queryCost":1,"latitude":35.925178304610114,"longitude":-83.96468538790941,"resolvedAddress":"35.925178304610114,-83.96468538790941","address":"35.925178304610114,-83.96468538790941","timezone":"America/New_York","tzoffset":-4.0,"days":[{"temp":77.9,"humidity":79.15,"windspeed":12.1,"winddir":93.8,"pressure":1021.9,"visibility":9.9,"sunriseEpoch":1624962142,"sunsetEpoch":1625014586,"moonphase":0.64,"conditions":"type_21, type_42"}],"currentConditions":{"temp":74.0,"humidity":90.3,"windspeed":4.7,"winddir":8.0,"pressure":1022.5,"visibility":9.9,"conditions":"type_42","sunriseEpoch":1624962142,"sunsetEpoch":1625014586,"moonphase":0.63}}';
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn(json);
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var fetcher =
        AtmosphereFetcher(appManager.app, dateTime(0), const LatLng(0, 0));

    var atmosphere = (await fetcher.fetch()).data;
    expect(atmosphere, isNotNull);
    expect(atmosphere!.temperature.mainValue.value, 74);
    expect(atmosphere.temperature.mainValue.unit, Unit.fahrenheit);
    expect(atmosphere.humidity.mainValue.value, 90.0);
    expect(atmosphere.windSpeed.mainValue.value, 7.563916800000001);
    expect(atmosphere.windSpeed.mainValue.unit, Unit.kilometers_per_hour);
    expect(atmosphere.windDirection, Direction.north);
    expect(atmosphere.pressure.mainValue.value, 14.8301355);
    expect(atmosphere.pressure.mainValue.unit, Unit.pounds_per_square_inch);
    expect(atmosphere.visibility.mainValue.value, 15.932505600000002);
    expect(atmosphere.visibility.mainValue.unit, Unit.kilometers);
    expect(atmosphere.sunriseTimestamp.toInt(), 1624962142000); // ms
    expect(atmosphere.sunsetTimestamp.toInt(), 1625014586000); // ms
    expect(atmosphere.moonPhase, MoonPhase.waning_gibbous);
    expect(atmosphere.skyConditions, [SkyCondition.cloudy]);
    expect(atmosphere.timeZone, defaultTimeZone);
  });
}
