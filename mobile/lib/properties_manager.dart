import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'log.dart';
import 'utils/properties_file.dart';

/// A class for accessing data in configuration files.
class PropertiesManager {
  static PropertiesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).propertiesManager;

  final String _keyClientSenderEmail = "clientsender.email";
  final String _keySupportEmail = "support.email";
  final String _keySendGridApiKey = "sendgrid.apikey";

  final Log _log = Log("PropertiesManager");

  final String _path = "assets/sensitive.properties";
  final String _feedbackTemplatePath = "assets/feedback_template";

  PropertiesFile _properties;
  String _feedbackTemplate;

  Future<void> initialize() async {
    _properties = PropertiesFile(await rootBundle.loadString(_path));

    try {
      _feedbackTemplate = await rootBundle.loadString(_feedbackTemplatePath);
    } on Exception catch (e) {
      _log.e("Error loading feedback tempate file: $e");
      return;
    }
  }

  String get clientSenderEmail =>
      _properties.stringForKey(_keyClientSenderEmail);

  String get supportEmail => _properties.stringForKey(_keySupportEmail);

  String get sendGridApiKey => _properties.stringForKey(_keySendGridApiKey);

  String get feedbackTemplate => _feedbackTemplate;
}
