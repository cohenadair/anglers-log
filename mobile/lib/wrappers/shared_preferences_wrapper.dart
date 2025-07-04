import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_manager.dart';

class SharedPreferencesWrapper {
  static SharedPreferencesWrapper of(BuildContext context) =>
      AppManager.get.sharedPreferencesWrapper;

  Future<bool> setString(String key, String value) async =>
      (await SharedPreferences.getInstance()).setString(key, value);

  Future<bool> remove(String key) async =>
      (await SharedPreferences.getInstance()).remove(key);
}
