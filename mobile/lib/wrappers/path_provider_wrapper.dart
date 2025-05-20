import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../app_manager.dart';

class PathProviderWrapper {
  static PathProviderWrapper of(BuildContext context) =>
      AppManager.get.pathProviderWrapper;

  Future<String> get appDocumentsPath async =>
      (await getApplicationDocumentsDirectory()).path;

  Future<String> get temporaryPath async =>
      (await getTemporaryDirectory()).path;
}
