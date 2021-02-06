import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';

class SubscriptionManager {
  static SubscriptionManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).subscriptionManager;

  bool get isPro => true;
}
