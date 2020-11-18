import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PathProviderWrapper {
  static PathProviderWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).pathProviderWrapper;

  Future<String> get appDocumentsPath async =>
      (await getApplicationDocumentsDirectory()).path;

  Future<String> get temporaryPath async =>
      (await getTemporaryDirectory()).path;
}