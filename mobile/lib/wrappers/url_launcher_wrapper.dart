import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

import '../app_manager.dart';

class UrlLauncherWrapper {
  static UrlLauncherWrapper of(BuildContext context) =>
      AppManager.get.urlLauncherWrapper;

  Future<bool> canLaunch(String url) => launcher.canLaunchUrl(Uri.parse(url));

  Future<bool> launch(
    String url, {
    LaunchMode mode = LaunchMode.platformDefault,
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
    BrowserConfiguration browserConfiguration = const BrowserConfiguration(),
    String? webOnlyWindowName,
  }) {
    return launcher.launchUrl(
      Uri.parse(url),
      mode: mode,
      webViewConfiguration: webViewConfiguration,
      browserConfiguration: browserConfiguration,
      webOnlyWindowName: webOnlyWindowName,
    );
  }
}
