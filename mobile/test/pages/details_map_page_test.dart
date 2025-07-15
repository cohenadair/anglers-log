import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/pages/details_map_page.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/default_mapbox_map.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(managers.userPreferenceManager.mapType).thenReturn(MapType.light.id);
    when(managers.propertiesManager.mapboxApiKey).thenReturn("");
    when(managers.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Shows close button", (tester) async {
    await pumpContext(
      tester,
      (_) => const DetailsMapPage(
        controller: null,
        map: DefaultMapboxMap(startPosition: LatLng(0, 0)),
        details: Empty(),
        isPresented: true,
      ),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets("Shows back button", (tester) async {
    await pumpContext(
      tester,
      (_) => Theme(
        data: ThemeData(platform: TargetPlatform.android),
        child: const DetailsMapPage(
          controller: null,
          map: DefaultMapboxMap(startPosition: LatLng(0, 0)),
          details: Empty(),
          isPresented: false,
        ),
      ),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}
