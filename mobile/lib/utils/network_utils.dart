import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../log.dart';
import '../wrappers/http_wrapper.dart';

const _log = Log("NetworkUtils");

Future<Response?> getRest(
  HttpWrapper httpWrapper,
  Uri uri, {
  bool returnNullOnHttpError = true,
}) {
  return _sendRest(
    () => httpWrapper.get(uri),
    uri,
    returnNullOnHttpError: returnNullOnHttpError,
  );
}

Future<Response?> putRest(HttpWrapper httpWrapper, Uri uri, Object? body) {
  return _sendRest(() => httpWrapper.put(uri, body: body), uri);
}

Future<Map<String, dynamic>?> getRestJson(
  HttpWrapper httpWrapper,
  Uri uri, {
  bool returnNullOnHttpError = true,
}) async {
  var response = await getRest(
    httpWrapper,
    uri,
    returnNullOnHttpError: returnNullOnHttpError,
  );

  if (response == null) {
    return null;
  }

  // Catch any parsing errors as a safety measure. We cannot trust that
  // the response object will always be a value JSON string.
  dynamic json;
  try {
    json = jsonDecode(response.body);
  } on Exception {
    json = null;
  }

  if (!isValidJsonMap(json)) {
    _log.e(StackTrace.current,
        "Response body is a non-JSON map format: ${response.body}");
    return null;
  }

  return json;
}

bool isValidJsonMap(dynamic possibleJson) =>
    possibleJson != null && possibleJson is Map<String, dynamic>;

Future<Response?> _sendRest(
  Future<Response> Function() sender,
  Uri uri, {
  bool returnNullOnHttpError = true,
}) async {
  Response? response;
  try {
    response = await sender();
  } catch (error) {
    // This can happen if there's no network connection.
    _log.w("Error in HTTP request: $error; query=$uri");
    return null;
  }

  if (response.statusCode != HttpStatus.ok && returnNullOnHttpError) {
    _log.e(
      StackTrace.current,
      "Error in REST response: ${response.statusCode}: ${response.body},"
      " query=$uri",
    );
    return null;
  }

  return response;
}
