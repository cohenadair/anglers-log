import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:provider/provider.dart';

class CatchManager {
  static CatchManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchManager;

  static final CatchManager _instance = CatchManager._internal();
  factory CatchManager.get() => _instance;
  CatchManager._internal();

  int get numberOfCatches => 0;
  int get numberOfCatchPhotos => 0;
}