import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class ServicesWrapper {
  static ServicesWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).servicesWrapper;

  MethodChannel methodChannel(String name) => MethodChannel(name);
}
