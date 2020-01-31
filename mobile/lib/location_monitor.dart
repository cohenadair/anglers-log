import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:provider/provider.dart';

class LocationMonitor {
  static LocationMonitor of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).locationMonitor;

  static final LocationMonitor _instance = LocationMonitor._internal();
  factory LocationMonitor.get() => _instance;
  LocationMonitor._internal();

  LatLng get currentLocation => LatLng(37.42796133580664, -122.085749655962);
}