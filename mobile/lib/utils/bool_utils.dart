import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:flutter/material.dart';

extension Bools on bool {
  String displayValue(BuildContext context) =>
      this ? L10n.get.lib.yes : L10n.get.lib.no;
}
