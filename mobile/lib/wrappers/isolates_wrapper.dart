import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class IsolatesWrapper {
  static IsolatesWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).isolatesWrapper;

  Future<List<int>> computeIntList(
    List<int> Function(List<int>) callback,
    List<int> arg,
  ) {
    return compute(callback, arg);
  }
}
