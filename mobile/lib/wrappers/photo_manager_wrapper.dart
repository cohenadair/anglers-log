import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class PhotoManagerWrapper {
  static PhotoManagerWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).photoManagerWrapper;

  Future<AssetPathEntity?> getAllAssetPathEntity(RequestType type) async {
    var paths = await PhotoManager.getAssetPathList(
      type: type,
      onlyAll: true,
      filterOption: FilterOptionGroup()..addOrderOption(const OrderOption()),
    );
    return paths.isEmpty ? null : paths.first;
  }
}
