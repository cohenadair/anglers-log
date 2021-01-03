import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class PermissionHandlerWrapper {
  static PermissionHandlerWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).permissionHandlerWrapper;

  /// Prompts the use for photos permission. Returns true if the app has
  /// permission to access photos; false otherwise.
  Future<bool> requestPhotos() async {
    return (await Permission.photos.request()).isGranted;
  }

  Future<bool> openSettings() => openAppSettings();
}
