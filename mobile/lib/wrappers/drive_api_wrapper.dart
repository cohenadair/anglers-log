import 'package:googleapis/drive/v3.dart';
import 'package:http/http.dart';
import 'package:material_ui/material_ui.dart';

import '../app_manager.dart';

class DriveApiWrapper {
  static DriveApiWrapper of(BuildContext context) =>
      AppManager.get.driveApiWrapper;

  DriveApi newInstance(Client client) => DriveApi(client);
}
