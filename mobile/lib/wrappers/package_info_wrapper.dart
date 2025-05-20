import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app_manager.dart';

class PackageInfoWrapper {
  static PackageInfoWrapper of(BuildContext context) =>
      AppManager.get.packageInfoWrapper;

  Future<PackageInfo> fromPlatform() => PackageInfo.fromPlatform();
}
