import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class PackageInfoWrapper {
  static PackageInfoWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).packageInfoWrapper;

  Future<PackageInfo> fromPlatform() => PackageInfo.fromPlatform();
}