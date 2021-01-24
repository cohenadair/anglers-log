import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../app_manager.dart';

class HttpWrapper {
  static HttpWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).httpWrapper;

  Future<http.Response> post(
    String url, {
    String auth,
    Map<String, dynamic> body,
  }) {
    return http.post(
      url,
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
        "Authorization": auth,
      },
      body: jsonEncode(body),
    );
  }
}
