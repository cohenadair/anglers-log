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
    var result = true;
    var isAndroid = ioWrapper.isAndroid;
    if (isAndroid) {
      result &= (await Permission.accessMediaLocation.request()).isGranted;
    }

    // TODO: Necessary until
    //  https://github.com/Baseflow/flutter-permission-handler/issues/944 is
    //  fixed. Permission.photos.request() always returns denied on Android 12
    //  and below.
    if (isAndroid && (await deviceInfo.androidInfo).version.sdkInt <= 32) {
      result &= (await Permission.storage.request()).isGranted;
    } else {
      result &= (await Permission.photos.request()).isGranted;
    }

    return result;
  }

  Future<bool> requestNotification() async =>
      (await Permission.notification.request()).isGranted;

  Future<bool> openSettings() => openAppSettings();
}
