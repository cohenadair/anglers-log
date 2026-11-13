import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../app_manager.dart';

class ServicesWrapper {
  static ServicesWrapper of(BuildContext context) =>
      AppManager.get.servicesWrapper;

  MethodChannel methodChannel(String name) => MethodChannel(name);
}
