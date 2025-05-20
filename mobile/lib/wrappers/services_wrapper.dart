import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_manager.dart';

class ServicesWrapper {
  static ServicesWrapper of(BuildContext context) =>
      AppManager.get.servicesWrapper;

  MethodChannel methodChannel(String name) => MethodChannel(name);
}
