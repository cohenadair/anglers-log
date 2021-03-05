import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class PurchasesWrapper {
  static PurchasesWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).purchasesWrapper;
}
