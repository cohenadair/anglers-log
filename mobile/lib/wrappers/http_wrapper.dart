import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import '../app_manager.dart';

class HttpWrapper {
  static HttpWrapper of(BuildContext context) => AppManager.get.httpWrapper;

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return http.post(url, headers: headers, body: body, encoding: encoding);
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return http.put(url, headers: headers, body: body, encoding: encoding);
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return http.get(url, headers: headers);
  }
}
