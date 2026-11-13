import 'package:csv/csv.dart';
import 'package:material_ui/material_ui.dart';

import '../app_manager.dart';

class CsvWrapper {
  static CsvWrapper of(BuildContext context) => AppManager.get.csvWrapper;

  const CsvWrapper();

  String convert(List<List?>? rows) => const ListToCsvConverter().convert(rows);
}
