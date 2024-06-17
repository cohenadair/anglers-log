import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class LocalNotificationsWrapper {
  static LocalNotificationsWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).localNotificationsWrapper;

  FlutterLocalNotificationsPlugin newInstance() =>
      FlutterLocalNotificationsPlugin();
}
