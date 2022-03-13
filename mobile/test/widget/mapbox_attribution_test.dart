import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/mapbox_attribution.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
    when(appManager.ioWrapper.isAndroid).thenReturn(true);
  });

  testWidgets("Attribution Android title", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    await pumpContext(
      tester,
      (_) => const MapboxAttribution(mapType: MapType.normal),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Maps SDK for Android"), findsOneWidget);
  });

  testWidgets("Attribution iOS title", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    await pumpContext(
      tester,
      (_) => const MapboxAttribution(mapType: MapType.normal),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Maps SDK for iOS"), findsOneWidget);
  });

  testWidgets("Attribution URL launched", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => const MapboxAttribution(mapType: MapType.normal),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    await tapAndSettle(tester, find.text("Improve This Map"));

    verify(appManager.urlLauncherWrapper.launch(any)).called(1);
  });

  testWidgets("Shows telemetry", (tester) async {
    await pumpContext(
      tester,
      (_) => MapboxAttribution(
        mapType: MapType.satellite,
        telemetry: MapboxTelemetry(isEnabled: true, onTogged: (_) {}),
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Telemetry"), findsOneWidget);
  });

  testWidgets("Hides telemetry", (tester) async {
    await pumpContext(
      tester,
      (_) => const MapboxAttribution(
        mapType: MapType.satellite,
        telemetry: null,
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.info_outline).first);
    expect(find.text("Mapbox Telemetry"), findsNothing);
  });
}
