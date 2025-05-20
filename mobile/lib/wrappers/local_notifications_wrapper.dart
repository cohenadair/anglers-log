import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../app_manager.dart';

class LocalNotificationsWrapper {
  static LocalNotificationsWrapper of(BuildContext context) =>
      AppManager.get.localNotificationsWrapper;

  FlutterLocalNotificationsPlugin newInstance() =>
      FlutterLocalNotificationsPlugin();
}
