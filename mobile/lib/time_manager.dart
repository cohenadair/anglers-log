import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';

class TimeManager {
  static TimeManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).timeManager;

  DateTime get currentDateTime => DateTime.now();
  TimeOfDay get currentTime => TimeOfDay.now();
  int get msSinceEpoch => currentDateTime.millisecondsSinceEpoch;
}
