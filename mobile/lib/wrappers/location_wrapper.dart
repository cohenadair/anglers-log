import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class LocationWrapper {
  static LocationWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).locationWrapper;

  Location newLocation() => Location();
}