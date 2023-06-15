import 'package:flutter/material.dart';
import 'package:mobile/wrappers/device_info_wrapper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';
import 'io_wrapper.dart';

class PermissionHandlerWrapper {
  static PermissionHandlerWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).permissionHandlerWrapper;

  Future<bool> requestLocation() async =>
      (await Permission.location.request()).isGranted;

  Future<bool> get isLocationGranted async => Permission.location.isGranted;

  Future<bool> requestLocationAlways() async =>
      (await Permission.locationAlways.request()).isGranted;

  Future<bool> get isLocationAlwaysGranted async =>
      Permission.locationAlways.isGranted;

  Future<bool> requestPhotos(
      DeviceInfoWrapper deviceInfo, IoWrapper ioWrapper) async {
    // TODO: Necessary until
    //  https://github.com/Baseflow/flutter-permission-handler/issues/944 is
    //  fixed. Permission.storage.request() always returns denied on Android 12
    //  and below.
    if (ioWrapper.isAndroid &&
        (await deviceInfo.androidInfo).version.sdkInt <= 32) {
      return (await Permission.storage.request()).isGranted;
    } else {
      return (await Permission.photos.request()).isGranted;
    }
  }

  Future<bool> requestNotification() async =>
      (await Permission.notification.request()).isGranted;

  Future<bool> openSettings() => openAppSettings();
}
