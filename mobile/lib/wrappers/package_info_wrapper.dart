import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class PackageInfoWrapper {
  static PackageInfoWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).packageInfoWrapper;

  Future<PackageInfo> fromPlatform() => PackageInfo.fromPlatform();
}
