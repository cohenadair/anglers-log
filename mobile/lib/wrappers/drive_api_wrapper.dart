import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class DriveApiWrapper {
  static DriveApiWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).driveApiWrapper;

  DriveApi newInstance(Client client) => DriveApi(client);
}
