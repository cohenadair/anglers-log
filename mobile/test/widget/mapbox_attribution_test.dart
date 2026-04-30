import 'package:adair_flutter_lib/widgets/padded_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/map/mapbox_map_controller.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/map_attribution.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../mocks/stubbed_map_controller.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
  });

  testWidgets("Attribution Android title", skip: true, (tester) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);

    await pumpContext(
      tester,
      (_) => const MapboxAttribution(mapType: MapType.light),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Maps SDK for Android"), findsOneWidget);
  });

  testWidgets("Attribution iOS title", skip: true, (tester) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    await pumpContext(
      tester,
      (_) => const MapboxAttribution(mapType: MapType.light),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Maps SDK for iOS"), findsOneWidget);
  });

  testWidgets("Attribution URL launched", skip: true, (tester) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
    when(
      managers.urlLauncherWrapper.launch(any),
    ).thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => const MapboxAttribution(mapType: MapType.light),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    await tapAndSettle(tester, find.text("Improve This Map"));

    verify(managers.urlLauncherWrapper.launch(any)).called(1);
  });

  testWidgets("Telemetry is enabled", skip: true, (tester) async {
    // TODO: Update when https://github.com/cohenadair/anglers-log/issues/1101
    //  is done.

    final mapController = StubbedMapController(managers);
    mapController.value = await MapboxMapController.create(
      mapController.map.value,
    );

    await pumpContext(
      tester,
      (_) => MapboxAttribution(
        mapController: mapController.value,
        mapType: MapType.satellite,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first, 50);
    expect(
      findSiblingOfText<PaddedCheckbox>(
        tester,
        ListItem,
        "Mapbox Telemetry",
      ).isChecked,
      isFalse,
    );
  });

  testWidgets("Telemetry is disabled", skip: true, (tester) async {
    // TODO: Update when https://github.com/cohenadair/anglers-log/issues/1101
    //  is done.

    var mapController = StubbedMapController(managers);
    mapController.value = await MapboxMapController.create(
      mapController.map.value,
    );

    await pumpContext(
      tester,
      (_) => MapboxAttribution(
        mapController: mapController.value,
        mapType: MapType.satellite,
      ),
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(
      findSiblingOfText<PaddedCheckbox>(
        tester,
        ListItem,
        "Mapbox Telemetry",
      ).isChecked,
      isFalse,
    );
  });
}
