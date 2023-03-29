import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/time_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;
  late TimeManager timeManager;

  setUp(() async {
    appManager = StubbedAppManager();

    when(appManager.timeZoneWrapper.getAvailableTimeZones()).thenAnswer((_) {
      return Future.value([
        "America/New_York",
        "America/Chicago",
        "Europe/Isle_of_Man",
      ]);
    });
    when(appManager.timeZoneWrapper.getLocalTimeZone())
        .thenAnswer((realInvocation) => Future.value("America/New_York"));

    timeManager = TimeManager(appManager.app);
    await timeManager.initialize();
  });

  test("initialize reconciles native and lib time zones", () async {
    when(appManager.timeZoneWrapper.getAvailableTimeZones()).thenAnswer((_) {
      return Future.value([
        "Europe/Isle_of_Man",
        "America/Menominee",
        "America/Matamoros",
      ]);
    });

    await timeManager.initialize();

    // Verify count, and sort by offset, then alphabetically.
    var locations = timeManager.filteredLocations(null);
    expect(locations.length, 3);
    expect(locations[0].name, "America/Matamoros");
    expect(locations[1].name, "America/Menominee");
    expect(locations[2].name, "Europe/Isle_of_Man");
  });

  test("filteredLocations excludes location", () async {
    var locations = timeManager.filteredLocations(null,
        exclude: TimeZoneLocation.fromName("America/New_York"));
    expect(locations.length, 2);
    expect(locations[0].name, "America/Chicago");
    expect(locations[1].name, "Europe/Isle_of_Man");
  });

  test("dateTime defaults to current time zone", () async {
    expect(timeManager.dateTime(5000).location.name, "America/New_York");
  });

  test("dateTime uses input time zone", () async {
    expect(
      timeManager.dateTime(5000, "America/Chicago").location.name,
      "America/Chicago",
    );
  });

  test("now defaults to current time zone", () async {
    expect(timeManager.now().location.name, "America/New_York");
  });

  test("now uses input time zone", () async {
    expect(timeManager.now("America/Chicago").location.name, "America/Chicago");
  });

  test("TimeZoneLocation displayName replaces _", () {
    expect(
      TimeZoneLocation.fromName("America/New_York").displayName,
      "America/New York",
    );
  });

  test("TimeZoneLocation displayNameUtc includes offset", () {
    expect(
      TimeZoneLocation.fromName("America/New_York").displayNameUtc,
      TimeZoneLocation.fromName("America/New_York").currentTimeZone.isDst
          ? "America/New York (UTC-04:00)"
          : "America/New York (UTC-05:00)",
    );
  });

  test("TimeZoneLocation displayUtc with 0 offset", () {
    expect(
      TimeZoneLocation.fromName("Atlantic/Azores").displayNameUtc,
      TimeZoneLocation.fromName("Atlantic/Azores").currentTimeZone.isDst
          ? "Atlantic/Azores (UTC)"
          : "Atlantic/Azores (UTC-01:00)",
    );
  });

  test("TimeZoneLocation displayUtc with negative offset", () {
    expect(
      TimeZoneLocation.fromName("America/New_York").displayNameUtc,
      TimeZoneLocation.fromName("America/New_York").currentTimeZone.isDst
          ? "America/New York (UTC-04:00)"
          : "America/New York (UTC-05:00)",
    );
  });

  test("TimeZoneLocation displayUtc with positive offset", () {
    expect(
      TimeZoneLocation.fromName("Africa/Tunis").displayNameUtc,
      "Africa/Tunis (UTC+01:00)",
    );
  });

  test("TimeZoneLocation matchesFilter empty filter returns true", () {
    expect(TimeZoneLocation.fromName("Africa/Tunis").matchesFilter(""), isTrue);
    expect(
        TimeZoneLocation.fromName("Africa/Tunis").matchesFilter(null), isTrue);
  });

  test("TimeZoneLocation matchesFilter using display name", () {
    expect(
        TimeZoneLocation.fromName("Africa/Tunis").matchesFilter("Tun"), isTrue);
  });

  test("TimeZoneLocation matchesFilter using abbreviation", () {
    expect(
      TimeZoneLocation.fromName("America/New_York").matchesFilter("EST"),
      isTrue,
    );
  });

  test("TimeZoneLocation ==", () {
    expect(
      TimeZoneLocation.fromName("America/New_York") ==
          TimeZoneLocation.fromName("America/New_York"),
      isTrue,
    );
  });
}
