import 'package:flutter/material.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/permission_handler_wrapper.dart';

import '../i18n/strings.dart';
import 'dialog_utils.dart';

Future<bool> requestLocationPermissionIfNeeded({
  required BuildContext context,
  bool requestAlways = true,
}) async {
  var ioWrapper = IoWrapper.of(context);
  var locationMonitor = LocationMonitor.of(context);
  var permissionWrapper = PermissionHandlerWrapper.of(context);

  // Permission is granted, nothing more to do.
  if ((requestAlways && await permissionWrapper.isLocationAlwaysGranted) ||
      (!requestAlways && await permissionWrapper.isLocationGranted)) {
    return true;
  }

  var isGranted = false;
  var showDeniedDialog = false;

  if (ioWrapper.isIOS ||
      (await permissionWrapper.isLocationGranted && requestAlways)) {
    if (ioWrapper.isAndroid) {
      if (context.mounted) {
        await _showLocationDialog(
          context: context,
          msg: Strings.of(context).permissionGpsTrailDescription,
          openSettingsAction: () async =>
              isGranted = await permissionWrapper.requestLocationAlways(),
        );
      }
    } else {
      isGranted = await permissionWrapper.requestLocationAlways();
      showDeniedDialog = true;
    }
  } else {
    // Android users must grant non-background location first, before we're
    // allowed to request background (always) location.
    isGranted = await permissionWrapper.requestLocation();
    showDeniedDialog = true;
  }

  if (isGranted) {
    // Now that permission is granted, ensure location monitoring is set up.
    await locationMonitor.initialize();
    return true;
  }

  if (showDeniedDialog && context.mounted) {
    await _showLocationDialog(
      context: context,
      msg: Strings.of(context).permissionCurrentLocationDescription,
    );
  }

  return false;
}

Future<void> _showLocationDialog({
  required BuildContext context,
  required String msg,
  VoidCallback? openSettingsAction,
}) {
  return showCancelDialog(
    context,
    title: Strings.of(context).permissionLocationTitle,
    description: msg,
    actionText: Strings.of(context).permissionOpenSettings,
    onTapAction:
        openSettingsAction ?? PermissionHandlerWrapper.of(context).openSettings,
  );
}
