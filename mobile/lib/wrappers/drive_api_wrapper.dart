import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart';

import '../app_manager.dart';

class DriveApiWrapper {
  static DriveApiWrapper of(BuildContext context) =>
      AppManager.get.driveApiWrapper;

  DriveApi newInstance(Client client) => DriveApi(client);
}
