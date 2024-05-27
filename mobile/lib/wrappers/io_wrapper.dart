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

  bool get isAndroid => Platform.isAndroid;

  bool get isIOS => Platform.isIOS;

  Future<List<InternetAddress>> lookup(String host) async {
    try {
      return await InternetAddress.lookup(host);
    } catch (_) {
      return Future.value([]);
    }
  }
}
