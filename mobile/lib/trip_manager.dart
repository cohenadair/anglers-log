import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:provider/provider.dart';

class TripManager {
  static TripManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).tripManager;

  int get numberOfTrips => 0;
}