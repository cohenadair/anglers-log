import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../log.dart';
import '../wrappers/http_wrapper.dart';

const _log = Log("NetworkUtils");

Future<Response?> getRest(HttpWrapper httpWrapper, Uri uri) async {
  Response? response;
  try {
    response = await httpWrapper.get(uri);
  } catch (error) {
    // This can happen if there's no network connection.
    _log.w("Error in HTTP request: $error");
    return null;
  }

  if (response.statusCode != HttpStatus.ok) {
    _log.e(
        StackTrace.current,
        "Error in REST call: ${response.statusCode}: ${response.body},"
        " query=$uri");
    return null;
  }

  return response;
}

Future<Map<String, dynamic>?> getRestJson(
    HttpWrapper httpWrapper, Uri uri) async {
  var response = await getRest(httpWrapper, uri);
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
        "Response body is a non-JSON format: ${response.body}");
    return null;
  }

  return json;
}

bool isValidJsonMap(dynamic possibleJson) =>
    possibleJson != null && possibleJson is Map<String, dynamic>;
