import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/network_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  test("getRestJson null response", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.badGateway);
    when(response.body).thenReturn("");
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(response));

    var json = await getRestJson(
      managers.httpWrapper,
      Uri.parse("www.example.com"),
    );
    expect(json, isNull);
    verify(response.body).called(1);
  });

  test(
    "getRestJson non-null response when returnNullOnHttpError is false",
    () async {
      var response = MockResponse();
      when(response.statusCode).thenReturn(HttpStatus.badGateway);
      when(response.body).thenReturn('{"key": "value"}');
      when(
        managers.httpWrapper.get(any),
      ).thenAnswer((_) => Future.value(response));

      var json = await getRestJson(
        managers.httpWrapper,
        Uri.parse("www.example.com"),
        returnNullOnHttpError: false,
      );

      expect(json, isNotNull);
      expect(json!["key"], "value");
    },
  );

  test("getRestJson invalid JSON", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("{not valid JSON}");
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(response));

    var json = await getRestJson(
      managers.httpWrapper,
      Uri.parse("www.example.com"),
    );
    expect(json, isNull);
    verify(response.body).called(1);
  });

  test("getRestJson invalid JSON map", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("10");
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(response));

    var json = await getRestJson(
      managers.httpWrapper,
      Uri.parse("www.example.com"),
    );
    expect(json, isNull);
    verify(response.body).called(1);
  });

  test("getRestJson valid response", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("""{
      "key": "value"
    }""");
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(response));

    var json = await getRestJson(
      managers.httpWrapper,
      Uri.parse("www.example.com"),
    );
    expect(json, isNotNull);
    verify(response.body).called(1);
  });

  test("_sendRest throws exception in sender", () async {
    when(managers.httpWrapper.get(any)).thenThrow(Exception());

    var json = await getRestJson(
      managers.httpWrapper,
      Uri.parse("www.example.com"),
    );
    expect(json, isNull);
  });
}
