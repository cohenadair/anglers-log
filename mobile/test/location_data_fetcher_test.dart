import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/location_data_fetcher.dart';
import 'package:mobile/widgets/fetch_input_header.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_managers.dart';
import 'test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("Fetch - valid coordinates returns null", (tester) async {
    var context = await buildContext(tester);
    var fetcher = TestFetcher(const LatLng(1.23456, 6.54321));
    expect(await fetcher.fetch(context), isNull);
  });

  testWidgets("Fetch - location permission granted", (tester) async {
    when(
      managers.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.locationMonitor.currentLatLng,
    ).thenReturn(const LatLng(1.23456, 6.54321));

    var context = await buildContext(tester);
    var fetcher = TestFetcher(null);
    expect(await fetcher.fetch(context), isNull);
    expect(fetcher.latLng, isNotNull);
    expect(fetcher.latLng, const LatLng(1.23456, 6.54321));
  });

  testWidgets("Fetch - location permission denied", (tester) async {
    // Code path not possible at this time.
  });

  testWidgets("Fetch - location permission error", (tester) async {
    when(
      managers.permissionHandlerWrapper.isLocationGranted,
    ).thenThrow(PlatformException(code: "Test error"));

    var result = await TestFetcher(null).fetch(await buildContext(tester));
    expect(result, isNotNull);
    expect(result!.data, isNull);
    expect(
      result.errorMessage,
      "There was an error requesting location permission. The Anglers' Log team has been notified, and we apologize for the inconvenience.",
    );
  });
}

class TestFetcher extends LocationDataFetcher<String> {
  TestFetcher(super.latLng);

  @override
  Future<FetchInputResult<String?>?> fetch(BuildContext context) =>
      super.fetch(context);
}
