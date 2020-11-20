import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class PhotoManagerWrapper {
  static PhotoManagerWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).photoManagerWrapper;

  Future<List<AssetPathEntity>> getAssetPathList(RequestType type) async =>
      (await PhotoManager.getAssetPathList(type: type)) ?? [];
}
