import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../app_manager.dart';

class PhotoManagerWrapper {
  static PhotoManagerWrapper of(BuildContext context) =>
      AppManager.get.photoManagerWrapper;

  Future<AssetPathEntity?> getAllAssetPathEntity(RequestType type) async {
    var paths = await PhotoManager.getAssetPathList(
      type: type,
      onlyAll: true,
      filterOption: FilterOptionGroup()..addOrderOption(const OrderOption()),
    );
    return paths.isEmpty ? null : paths.first;
  }
}
