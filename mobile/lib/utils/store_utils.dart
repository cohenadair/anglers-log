import 'dart:io';

import 'package:flutter/cupertino.dart';
import '../wrappers/url_launcher_wrapper.dart';

import 'snackbar_utils.dart';

String _storeUrl() => Platform.isAndroid
    ? "https://play.google.com/store/apps/details?id=com.cohenadair.anglerslog"
    : "https://apps.apple.com/app/id959989008?action=write-review";

Future<void> launchStore(BuildContext context) async {
  var launcher = UrlLauncherWrapper.of(context);
  var url = _storeUrl();
  if (await launcher.canLaunch(url)) {
    launcher.launch(url);
  } else {
    showErrorSnackBar(context, "Device has no web browser app.");
  }
}
