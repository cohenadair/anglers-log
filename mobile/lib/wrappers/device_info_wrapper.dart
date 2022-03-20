import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class DeviceInfoWrapper {
  static DeviceInfoWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).deviceInfoWrapper;

  Future<AndroidDeviceInfo> get androidInfo => DeviceInfoPlugin().androidInfo;

  Future<IosDeviceInfo> get iosInfo => DeviceInfoPlugin().iosInfo;
}
