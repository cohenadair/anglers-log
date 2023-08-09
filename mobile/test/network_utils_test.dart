import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/network_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  test("getRestJson null response", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.badGateway);
    when(response.body).thenReturn("");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var json =
        await getRestJson(appManager.httpWrapper, Uri.parse("www.example.com"));
    expect(json, isNull);
    verify(response.body).called(1);
  });

  test("getRestJson non-null response when returnNullOnHttpError is false",
      () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.badGateway);
    when(response.body).thenReturn('{"key": "value"}');
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var json = await getRestJson(
      appManager.httpWrapper,
      Uri.parse("www.example.com"),
      returnNullOnHttpError: false,
    );

    expect(json, isNotNull);
    expect(json!["key"], "value");
  });

  test("getRestJson invalid JSON", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("{not valid JSON}");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var json =
        await getRestJson(appManager.httpWrapper, Uri.parse("www.example.com"));
    expect(json, isNull);
    verify(response.body).called(2);
  });

  test("getRestJson invalid JSON map", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("10");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var json =
        await getRestJson(appManager.httpWrapper, Uri.parse("www.example.com"));
    expect(json, isNull);
    verify(response.body).called(2);
  });

  test("getRestJson valid response", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("""{
      "key": "value"
    }""");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var json =
        await getRestJson(appManager.httpWrapper, Uri.parse("www.example.com"));
    expect(json, isNotNull);
    verify(response.body).called(1);
  });

  test("_sendRest throws exception in sender", () async {
    when(appManager.httpWrapper.get(any)).thenThrow(Exception());

    var json =
        await getRestJson(appManager.httpWrapper, Uri.parse("www.example.com"));
    expect(json, isNull);
  });
}
