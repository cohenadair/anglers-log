import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/static_fishing_spot_map.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.imageManager.image(fileName: anyNamed("fileName")))
        .thenAnswer((_) => Future.value(null));

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("key");

    when(appManager.userPreferenceManager.mapType).thenReturn(MapType.light.id);

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));
  });

  testWidgets("Failed request shows container", (tester) async {
    when(appManager.imageManager.image(fileName: anyNamed("fileName")))
        .thenAnswer((_) => Future.value(null));

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.badGateway);
    when(response.body).thenReturn("Body");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    await pumpContext(
      tester,
      (_) => StaticFishingSpotMap(FishingSpot(
        lat: 1.2345,
        lng: 6.7891,
      )),
      appManager: appManager,
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    verify(appManager.httpWrapper.get(captureAny)).called(1);
    verifyNever(appManager.imageManager.saveImageBytes(any, any));
  });

  testWidgets("Image is fetched from catch", (tester) async {
    Uint8List? image;
    // runAsync is required here because readAsBytes does real async
    // work and can't be used with pump().
    await tester.runAsync(() async {
      image = await File("test/resources/android_logo.png").readAsBytes();
    });

    when(appManager.imageManager.image(fileName: anyNamed("fileName")))
        .thenAnswer((_) => Future.value(image));

    await pumpContext(
      tester,
      (_) => StaticFishingSpotMap(FishingSpot(
        lat: 1.2345,
        lng: 6.7891,
      )),
      appManager: appManager,
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    verifyNever(appManager.httpWrapper.get(any));
  });

  testWidgets("Required image > max && < max * 2", (tester) async {
    await pumpContext(
      tester,
      (_) => StaticFishingSpotMap(FishingSpot(
        lat: 1.2345,
        lng: 6.7891,
      )),
      appManager: appManager,
      mediaQueryData: const MediaQueryData(
        size: Size(1500, 800),
        devicePixelRatio: 1.0,
      ),
    );
    await tester.pumpAndSettle();

    var result = verify(appManager.httpWrapper.get(captureAny));
    result.called(1);

    var url = (result.captured.first as Uri).path;
    expect(url.contains("750x100@2x"), isTrue);
  });

  testWidgets("Required image > max * 2", (tester) async {
    await pumpContext(
      tester,
      (_) => StaticFishingSpotMap(FishingSpot(
        lat: 1.2345,
        lng: 6.7891,
      )),
      appManager: appManager,
      mediaQueryData: const MediaQueryData(
        size: Size(5000, 800),
        devicePixelRatio: 1.0,
      ),
    );
    await tester.pumpAndSettle();

    var result = verify(appManager.httpWrapper.get(captureAny));
    result.called(1);

    var url = (result.captured.first as Uri).path;
    expect(url.contains("1280x100@2x"), isTrue);
  });

  testWidgets("Image fetch is successful", (tester) async {
    Uint8List? image;
    // runAsync is required here because readAsBytes does real async
    // work and can't be used with pump().
    await tester.runAsync(() async {
      image = await File("test/resources/android_logo.png").readAsBytes();
    });

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.bodyBytes).thenReturn(image!);
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    when(appManager.imageManager.saveImageBytes(any, any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => StaticFishingSpotMap(FishingSpot(
        lat: 1.2345,
        lng: 6.7891,
      )),
      appManager: appManager,
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    verify(appManager.httpWrapper.get(captureAny)).called(1);
    verify(appManager.imageManager.saveImageBytes(any, any)).called(1);
  });
}
