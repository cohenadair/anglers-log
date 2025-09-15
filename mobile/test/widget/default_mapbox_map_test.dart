import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/default_mapbox_map.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../mocks/stubbed_managers.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
  late StubbedMapController mapController;

  setUp(() async {
    managers = await StubbedManagers.create();
    mapController = StubbedMapController();

    when(managers.userPreferenceManager.mapType).thenReturn(MapType.light.id);
    when(managers.propertiesManager.mapboxApiKey).thenReturn("KEY");
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Zoom set to 0 if start position is 0", (tester) async {
    await pumpMap(
      tester,
      mapController,
      const DefaultMapboxMap(startPosition: LatLng(0, 0)),
    );
    expect(findFirst<MapboxMap>(tester).initialCameraPosition.zoom, 0);
  });

  testWidgets("Zoom set to default if start position is valid", (tester) async {
    await pumpMap(
      tester,
      mapController,
      const DefaultMapboxMap(startPosition: LatLng(1, 2)),
    );
    expect(
      findFirst<MapboxMap>(tester).initialCameraPosition.zoom,
      mapZoomDefault,
    );
  });

  testWidgets("Zoom set to start zoom", (tester) async {
    await pumpMap(
      tester,
      mapController,
      const DefaultMapboxMap(
        startPosition: LatLng(1, 2),
        startZoom: mapZoomDefault - 1,
      ),
    );
    expect(
      findFirst<MapboxMap>(tester).initialCameraPosition.zoom,
      mapZoomDefault - 1,
    );
  });
}
