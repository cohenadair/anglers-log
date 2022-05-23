import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../app_manager.dart';

class UrlLauncherWrapper {
  static UrlLauncherWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).urlLauncherWrapper;

  Future<bool> canLaunch(String url) => launcher.canLaunchUrl(Uri.parse(url));

  Future<bool> launch(String url) => launcher.launchUrl(Uri.parse(url));
}
