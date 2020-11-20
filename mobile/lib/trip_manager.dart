import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';

class TripManager {
  static TripManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).tripManager;

  int get numberOfTrips => 0;
}
