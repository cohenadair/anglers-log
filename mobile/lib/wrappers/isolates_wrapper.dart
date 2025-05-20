import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';

class IsolatesWrapper {
  static IsolatesWrapper of(BuildContext context) =>
      AppManager.get.isolatesWrapper;

  Future<List<int>> computeIntList(
    List<int> Function(List<int>) callback,
    List<int> arg,
  ) {
    return compute(callback, arg);
  }
}
