import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:provider/provider.dart';

class BaitManager {
  static BaitManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitManager;

  static final BaitManager _instance = BaitManager._internal();
  factory BaitManager.get() => _instance;
  BaitManager._internal();

  int get numberOfBaits => 0;
}