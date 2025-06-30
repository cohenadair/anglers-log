import 'package:adair_flutter_lib/managers/properties_manager.dart' as lib;
import 'package:flutter/foundation.dart';

/// A class for accessing data in configuration files.
class PropertiesManager {
  static var _instance = PropertiesManager._();

  static PropertiesManager get get => _instance;

  @visibleForTesting
  static void set(PropertiesManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = PropertiesManager._();

  PropertiesManager._();

  final String _keyVisualCrossing = "visualCrossing.apiKey";
  final String _keyMapbox = "mapbox.apiKey";
  final String _keyWorldTides = "worldTides.apiKey";
  final String _keyFirebaseSecret = "firebase.secret";

  String get visualCrossingApiKey =>
      lib.PropertiesManager.get.stringForKey(_keyVisualCrossing);

  String get mapboxApiKey => lib.PropertiesManager.get.stringForKey(_keyMapbox);

  String get worldTidesApiKey =>
      lib.PropertiesManager.get.stringForKey(_keyWorldTides);

  String get firebaseSecret =>
      lib.PropertiesManager.get.stringForKey(_keyFirebaseSecret);
}
