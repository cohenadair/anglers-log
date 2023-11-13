import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class CsvWrapper {
  static CsvWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).csvWrapper;

  const CsvWrapper();

  String convert(List<List?>? rows) => const ListToCsvConverter().convert(rows);
}
