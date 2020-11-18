import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class PhotoManagerWrapper {
  static PhotoManagerWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).photoManagerWrapper;

  Future<List<AssetPathEntity>> getAssetPathList(RequestType type) async =>
      (await PhotoManager.getAssetPathList(type: type)) ?? [];
}