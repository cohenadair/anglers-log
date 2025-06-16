import 'package:flutter/material.dart';
import 'package:mobile/wrappers/device_info_wrapper.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_manager.dart';
import 'io_wrapper.dart';

class PermissionHandlerWrapper {
  static PermissionHandlerWrapper of(BuildContext context) =>
      AppManager.get.permissionHandlerWrapper;

  Future<bool> requestLocation() async =>
      (await Permission.location.request()).isGranted;

  Future<bool> get isLocationGranted async => Permission.location.isGranted;

  Future<bool> requestLocationAlways() async =>
      (await Permission.locationAlways.request()).isGranted;

  Future<bool> get isLocationAlwaysGranted async =>
      Permission.locationAlways.isGranted;

  Future<bool> requestPhotos() async {
    var result = true;
    var isAndroid = IoWrapper.get.isAndroid;
    if (isAndroid) {
      result &= (await Permission.accessMediaLocation.request()).isGranted;
    }

    // TODO: Necessary until
    //  https://github.com/Baseflow/flutter-permission-handler/issues/944 is
    //  fixed. Permission.photos.request() always returns denied on Android 12
    //  and below.
    if (isAndroid &&
        (await DeviceInfoWrapper.get.androidInfo).version.sdkInt <= 32) {
      result &= (await Permission.storage.request()).isGranted;
    } else {
      result &= (await Permission.photos.request()).isGranted;
    }

    return result;
  }

  /// Observed behaviour:
  ///   - Fresh install, returns [PermissionStatus.denied].
  ///   - User selects "Don't Allow", returns
  ///     [PermissionStatus.permanentlyDenied].
  ///   - User selects "Allow", returns [PermissionStatus.granted].
  Future<bool> requestNotification() async =>
      (await notification.request()).isGranted;

  Permission get notification => Permission.notification;

  Future<bool> get isNotificationDenied => notification.isDenied;

  Future<bool> openSettings() => openAppSettings();
}
