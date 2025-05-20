import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import '../app_manager.dart';

class DeviceInfoWrapper {
  static DeviceInfoWrapper of(BuildContext context) =>
      AppManager.get.deviceInfoWrapper;

  Future<AndroidDeviceInfo> get androidInfo => DeviceInfoPlugin().androidInfo;

  Future<IosDeviceInfo> get iosInfo => DeviceInfoPlugin().iosInfo;
}
