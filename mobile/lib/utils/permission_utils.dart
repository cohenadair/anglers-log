import 'package:flutter/material.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/permission_handler_wrapper.dart';

import '../log.dart';
import '../utils/string_utils.dart';
import 'dialog_utils.dart';

const _log = Log("PermissionUtils");

enum RequestLocationResult {
  granted,
  deniedDialog,
  denied,
  inProgress,
  error,
}

Future<RequestLocationResult> requestLocationPermissionWithResultIfNeeded(
  BuildContext context, {
  String? deniedMessage,
  bool requestAlways = false,
}) async {
  try {
    return await _safeRequestLocationPermissionWithResultIfNeeded(
      context,
      deniedMessage: deniedMessage ??
          Strings.of(context).permissionCurrentLocationDescription,
      requestAlwaysMessage: requestAlways
          ? Strings.of(context).permissionGpsTrailDescription
          : null,
    );
  } catch (e) {
    if (e.toString().contains("permissions is already running")) {
      _log.w("Request is already in progress");
      return RequestLocationResult.inProgress;
    }
    _log.e(StackTrace.current, "Error requesting permission - $e");
    return RequestLocationResult.error;
  }
}

Future<RequestLocationResult> _safeRequestLocationPermissionWithResultIfNeeded(
  BuildContext context, {
  required String deniedMessage,
  String? requestAlwaysMessage,
}) async {
  var locationMonitor = LocationMonitor.of(context);
  var permissionWrapper = PermissionHandlerWrapper.of(context);
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
              isGranted = await permissionWrapper.requestLocationAlways(),
        );
      }
    } else {
      isGranted = await permissionWrapper.requestLocationAlways();

      // TODO: For now, don't show additional dialog on iOS due to
      //  https://github.com/Baseflow/flutter-permission-handler/issues/1152.
      showDeniedDialog = IoWrapper.get.isAndroid;
    }
  } else {
    // Android users must grant non-background location first (iOS while-in-use
    // first), before we're allowed to request background (always) location.
    isGranted = await permissionWrapper.requestLocation();
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
        openSettingsAction ?? PermissionHandlerWrapper.of(context).openSettings,
  );
}
