import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:provider/provider.dart';

class IoWrapper {
  static IoWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).ioWrapper;

  Directory directory(String path) => Directory(path);
  File file(String path) => File(path);
}