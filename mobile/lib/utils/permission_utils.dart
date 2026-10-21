import 'package:adair_flutter_lib/utils/dialog.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/permission.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:adair_flutter_lib/wrappers/permission_handler_wrapper.dart';
import 'package:adair_flutter_lib/wrappers/shared_preferences_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/location_monitor.dart';

import '../utils/string_utils.dart';

const _log = Log("PermissionUtils");

/// The `NSUserDefaults` key permission_handler_apple sets after it requests
/// "Always" location permission on iOS. Once set, the plugin returns
/// immediately without showing a system prompt, since iOS only allows the
/// "Always" upgrade prompt to be shown once. See
/// `LocationPermissionStrategy.m` in permission_handler_apple.
@visibleForTesting
const permissionHandlerLocationAlwaysRequestedKey =
    "org.baseflow.permission_handler_apple.permission_requested";

enum RequestLocationResult { granted, deniedDialog, denied, error }

Future<RequestLocationResult> requestLocationPermissionWithResultIfNeeded(
  BuildContext context, {
  String? deniedMessage,
  bool requestAlways = false,
}) async {
  try {
    return await _safeRequestLocationPermissionWithResultIfNeeded(
      context,
      deniedMessage:
          deniedMessage ??
          Strings.of(context).permissionCurrentLocationDescription,
      requestAlwaysMessage: requestAlways
          ? Strings.of(context).permissionGpsTrailDescription
          : null,
    );
  } catch (e) {
    _log.e("Error requesting permission - $e");
    return RequestLocationResult.error;
  }
}

Future<RequestLocationResult> _safeRequestLocationPermissionWithResultIfNeeded(
  BuildContext context, {
  required String deniedMessage,
  String? requestAlwaysMessage,
}) async {
  var locationMonitor = LocationMonitor.of(context);
  var permissionWrapper = PermissionHandlerWrapper.get;
  var requestAlways = requestAlwaysMessage != null;

  // Permission is granted, nothing more to do.
  if ((requestAlways && await permissionWrapper.isLocationAlwaysGranted) ||
      (!requestAlways && await permissionWrapper.isLocationGranted)) {
    // Permission is granted, ensure location monitoring is set up. It's
    // possible for the OS to automatically prompt the user for permission on
    // app start (for example, if they previously selected "Only Once").
    // There's no listeners for permission changes, so we need to make sure
    // everything is set up when we need a location.
    await locationMonitor.initialize();
    return RequestLocationResult.granted;
  }

  var isGranted = false;
  var showDeniedDialog = false;

  if ((await permissionWrapper.isLocationGranted && requestAlways)) {
    if (IoWrapper.get.isAndroid) {
      if (context.mounted) {
        await _showLocationDialog(
          context,
          msg: requestAlwaysMessage,
          openSettingsAction: () async =>
              isGranted = await requestLocationAlwaysPermission(),
        );
      }
    } else if (await _didRequestLocationAlwaysOnIos()) {
      // iOS won't show the "Always" prompt again, so the only way to grant
      // the permission is via the device's settings.
      if (!context.mounted) {
        return RequestLocationResult.denied;
      }
      await _showLocationDialog(context, msg: requestAlwaysMessage);
      return RequestLocationResult.deniedDialog;
    } else {
      // Don't show a denied dialog after the iOS system prompt. The request
      // can return before the user responds, so the dialog would appear on
      // top of the system prompt. See
      // https://github.com/Baseflow/flutter-permission-handler/issues/1152.
      isGranted = await requestLocationAlwaysPermission();
    }
  } else {
    // Android users must grant non-background location first (iOS while-in-use
    // first), before we're allowed to request background (always) location.
    isGranted = await requestLocationPermission();
    showDeniedDialog = true;
  }

  if (isGranted) {
    // Now that permission is granted, ensure location monitoring is set up.
    await locationMonitor.initialize();
    return RequestLocationResult.granted;
  }

  if (showDeniedDialog && context.mounted) {
    await _showLocationDialog(context, msg: deniedMessage);
    return RequestLocationResult.deniedDialog;
  }

  return RequestLocationResult.denied;
}

Future<bool> _didRequestLocationAlwaysOnIos() async {
  try {
    return await SharedPreferencesWrapper.get.sharedPreferencesAsync().getBool(
          permissionHandlerLocationAlwaysRequestedKey,
        ) ??
        false;
  } catch (e) {
    _log.e(e, reason: "Failed to read location always requested flag");
    return false;
  }
}

Future<bool> requestLocationPermissionIfNeeded(
  BuildContext context, {
  bool requestAlways = true,
}) async {
  var result = await requestLocationPermissionWithResultIfNeeded(
    context,
    deniedMessage: Strings.of(context).permissionCurrentLocationDescription,
    requestAlways: requestAlways,
  );
  return result == RequestLocationResult.granted;
}

Future<void> _showLocationDialog(
  BuildContext context, {
  required String msg,
  VoidCallback? openSettingsAction,
}) {
  return showCancelDialog(
    context,
    title: Strings.of(context).permissionLocationTitle,
    description: msg,
    actionText: Strings.of(context).permissionOpenSettings,
    onTapAction:
        openSettingsAction ?? PermissionHandlerWrapper.get.openSettings,
  );
}
