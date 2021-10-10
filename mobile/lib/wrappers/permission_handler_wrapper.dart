import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class PermissionHandlerWrapper {
  static PermissionHandlerWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).permissionHandlerWrapper;

  /// Prompts the use for location permission if needed. Returns true if the
  /// app has permission to access location; false otherwise.
  Future<bool> requestLocation() async =>
      (await Permission.location.request()).isGranted;

  Future<bool> get isLocationGranted async => Permission.location.isGranted;

  /// Prompts the use for photos permission if needed. Returns true if the app
  /// has permission to access photos; false otherwise.
  Future<bool> requestPhotos() async =>
      (await Permission.photos.request()).isGranted;

  Future<bool> openSettings() => openAppSettings();
}
