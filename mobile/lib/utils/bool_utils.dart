import 'package:flutter/material.dart';

import '../utils/string_utils.dart';

extension Bools on bool {
  String displayValue(BuildContext context) =>
      this ? Strings.of(context).yes : Strings.of(context).no;
}
