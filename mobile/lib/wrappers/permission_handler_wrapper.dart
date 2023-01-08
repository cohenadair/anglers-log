import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

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

  Future<bool> requestPhotos() async =>
      (await Permission.photos.request()).isGranted;

  Future<bool> openSettings() => openAppSettings();
}
