import 'package:flutter/material.dart';

import '../i18n/strings.dart';

extension Bools on bool {
  String displayValue(BuildContext context) =>
      this ? Strings.of(context).yes : Strings.of(context).no;
}
