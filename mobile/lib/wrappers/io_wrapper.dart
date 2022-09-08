import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class IoWrapper {
  static IoWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).ioWrapper;

  bool isFileSync(String path) => FileSystemEntity.isFileSync(path);

  Directory directory(String path) => Directory(path);

  File file(String path) => File(path);

  Future<bool> isConnected() async {
    try {
      // A quick DNS lookup will tell us if there's a current internet
      // connection. InternetAddress.lookup throws an exception if internet is
      // off, such as when in Airplane Mode.
      return (await InternetAddress.lookup("example.com")).isNotEmpty;
    } on Exception catch (ex, _) {
      return false;
    }
  }

  bool get isAndroid => Platform.isAndroid;

  bool get isIOS => Platform.isIOS;
}
