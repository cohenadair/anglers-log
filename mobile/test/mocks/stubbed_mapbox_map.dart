import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks.mocks.dart';

class StubbedMapboxMap {
  OnMapScrollListener? onMapMoveCallback;

  final value = MockMapboxMap();
  final pointAnnotationManager = MockPointAnnotationManager();

  StubbedMapboxMap() {
    when(
      pointAnnotationManager.setSymbolZOrder(any),
    ).thenAnswer((_) => Future.value());

    final cancelable = MockCancelable();
    when(cancelable.cancel()).thenAnswer((_) {});
    when(
      pointAnnotationManager.tapEvents(onTap: anyNamed("onTap")),
    ).thenReturn(cancelable);
    when(pointAnnotationManager.createMulti(any)).thenAnswer((inv) {
      final options =
          inv.positionalArguments[0] as List<PointAnnotationOptions>;
      final annotations = options.map(
        (o) => PointAnnotation(id: randomId().uuid, geometry: o.geometry),
      );
      return Future.value(annotations.toList());
    });

    final annotations = MockAnnotationManager();
    when(
      annotations.createPointAnnotationManager(),
    ).thenAnswer((_) => Future.value(pointAnnotationManager));

    final attributionSettings = MockAttributionSettingsInterface();
    when(
      attributionSettings.updateSettings(any),
    ).thenAnswer((_) => Future.value());

    final logoSettings = MockLogoSettingsInterface();
    when(logoSettings.updateSettings(any)).thenAnswer((_) => Future.value());

    final compassSettings = MockCompassSettingsInterface();
    when(compassSettings.updateSettings(any)).thenAnswer((_) => Future.value());

    final scaleBarSettings = MockScaleBarSettingsInterface();
    when(
      scaleBarSettings.updateSettings(any),
    ).thenAnswer((_) => Future.value());

    final locationComponentSettings = MockLocationSettings();
    when(
      locationComponentSettings.updateSettings(any),
    ).thenAnswer((_) => Future.value());

    when(value.attribution).thenReturn(attributionSettings);
    when(value.logo).thenReturn(logoSettings);
    when(value.compass).thenReturn(compassSettings);
    when(value.scaleBar).thenReturn(scaleBarSettings);
    when(value.location).thenReturn(locationComponentSettings);
    when(value.annotations).thenReturn(annotations);
    when(value.setOnMapMoveListener(any)).thenAnswer(
      (invocation) => onMapMoveCallback = invocation.positionalArguments[0],
    );
  }
}
