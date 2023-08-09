import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'utils/properties_file.dart';

/// A class for accessing data in configuration files.
class PropertiesManager {
  static PropertiesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).propertiesManager;

  final String _keyClientSenderEmail = "clientSender.email";
  final String _keySupportEmail = "support.email";
  final String _keySendGridApiKey = "sendGrid.apikey";
  final String _keyRevenueCatApiKey = "revenueCat.apiKey";
  final String _keyVisualCrossing = "visualCrossing.apiKey";
  final String _keyMapbox = "mapbox.apiKey";
  final String _keyWorldTides = "worldTides.apiKey";
  final String _keyFirebaseSecret = "firebase.secret";

  final String _path = "assets/sensitive.properties";
  final String _feedbackTemplatePath = "assets/feedback_template";

  late PropertiesFile _properties;
  late String _feedbackTemplate;

  Future<void> initialize() async {
    _properties = PropertiesFile(await rootBundle.loadString(_path));
    _feedbackTemplate = await rootBundle.loadString(_feedbackTemplatePath);
  }

  String get clientSenderEmail =>
      _properties.stringForKey(_keyClientSenderEmail);

  String get supportEmail => _properties.stringForKey(_keySupportEmail);

  String get sendGridApiKey => _properties.stringForKey(_keySendGridApiKey);

  String get revenueCatApiKey => _properties.stringForKey(_keyRevenueCatApiKey);

  String get visualCrossingApiKey =>
      _properties.stringForKey(_keyVisualCrossing);

  String get mapboxApiKey => _properties.stringForKey(_keyMapbox);

  String get worldTidesApiKey => _properties.stringForKey(_keyWorldTides);

  String get firebaseSecret => _properties.stringForKey(_keyFirebaseSecret);

  String get feedbackTemplate => _feedbackTemplate;
}
