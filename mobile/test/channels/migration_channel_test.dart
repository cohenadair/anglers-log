import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/channels/migration_channel.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockServicesWrapper servicesWrapper;
  late MockMethodChannel methodChannel;

  setUp(() {
    servicesWrapper = MockServicesWrapper();

    methodChannel = MockMethodChannel();
    when(servicesWrapper.methodChannel(any)).thenReturn(methodChannel);

    var wrapper = MockServicesWrapper();
    when(wrapper.methodChannel(any)).thenReturn(methodChannel);
  });

  test("No legacy data to migrate returns null", () async {
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value(null));
    expect(await legacyJson(servicesWrapper), isNull);
  });

  test("Channel result missing database path", () async {
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value({
          "img": "path/to/images",
          "json": "{}",
        }));
    var result = await legacyJson(servicesWrapper);
    expect(result, isNotNull);
    expect(result!.errorCode, LegacyJsonErrorCode.missingData);
  });

  test("Channel result missing images path", () async {
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value({
          "db": "path/to/database",
          "json": "{}",
        }));
    var result = await legacyJson(servicesWrapper);
    expect(result, isNotNull);
    expect(result!.errorCode, LegacyJsonErrorCode.missingData);
  });

  test("Channel result missing json", () async {
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value({
          "img": "path/to/images",
          "db": "path/to/database",
        }));
    var result = await legacyJson(servicesWrapper);
    expect(result, isNotNull);
    expect(result!.errorCode, LegacyJsonErrorCode.missingData);
  });

  test("Invalid JSON", () async {
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value({
          "img": "path/to/images",
          "db": "path/to/database",
          "json": "bad JSON string",
        }));
    var result = await legacyJson(servicesWrapper);
    expect(result, isNotNull);
    expect(result!.errorCode, LegacyJsonErrorCode.invalidJson);
  });

  test("Platform exception", () async {
    when(methodChannel.invokeMethod(any))
        .thenAnswer(((_) => throw PlatformException(code: "Test")));
    var result = await legacyJson(servicesWrapper);
    expect(result, isNotNull);
    expect(result!.errorCode, LegacyJsonErrorCode.platformException);
  });

  test("Successful case", () async {
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value({
          "img": "path/to/images",
          "db": "path/to/database",
          "json": "{}",
        }));
    var result = await legacyJson(servicesWrapper);
    expect(result, isNotNull);
    expect(result!.errorCode, isNull);
    expect(result.imagesPath, "path/to/images");
    expect(result.databasePath, "path/to/database");
    expect(result.json, isNotNull);
  });
}
