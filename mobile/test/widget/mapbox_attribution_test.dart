import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/mapbox_attribution.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(managers.ioWrapper.isAndroid).thenReturn(true);
  });

  testWidgets("Attribution Android title", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(true);

    await pumpContext(
      tester,
      (_) => const MapboxAttribution(mapType: MapType.light),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Maps SDK for Android"), findsOneWidget);
  });

  testWidgets("Attribution iOS title", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(false);

    await pumpContext(
      tester,
      (_) => const MapboxAttribution(mapType: MapType.light),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Maps SDK for iOS"), findsOneWidget);
  });

  testWidgets("Attribution URL launched", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(true);
    when(managers.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => const MapboxAttribution(mapType: MapType.light),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    await tapAndSettle(tester, find.text("Improve This Map"));

    verify(managers.urlLauncherWrapper.launch(any)).called(1);
  });

  testWidgets("Telemetry is enabled", (tester) async {
    var mapController = StubbedMapController();
    when(mapController.value.getTelemetryEnabled())
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => MapboxAttribution(
        mapController: mapController.value,
        mapType: MapType.satellite,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first, 50);
    expect(
      findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Mapbox Telemetry")
          .checked,
      isTrue,
    );
  });

  testWidgets("Telemetry is disabled", (tester) async {
    var mapController = StubbedMapController();
    when(mapController.value.getTelemetryEnabled())
        .thenAnswer((_) => Future.value(false));

    await pumpContext(
      tester,
      (_) => MapboxAttribution(
        mapController: mapController.value,
        mapType: MapType.satellite,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(
      findSiblingOfText<PaddedCheckbox>(tester, ListItem, "Mapbox Telemetry")
          .checked,
      isFalse,
    );
  });
}
