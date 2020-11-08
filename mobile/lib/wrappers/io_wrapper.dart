import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:provider/provider.dart';

class IoWrapper {
  static IoWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).ioWrapper;

  Directory directory(String path) => Directory(path);
  File file(String path) => File(path);

  Future<bool> isConnected() async {
    // A quick DNS lookup will tell us if there's a current internet connection.
    return (await InternetAddress.lookup("example.com")).isNotEmpty;
  }
}