import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mobile/app_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/utils/properties_file.dart';
import 'package:provider/provider.dart';

/// A class for accessing data in configuration files.
class PropertiesManager {
  static PropertiesManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).propertiesManager;

  final String _clientSenderEmailKey = "clientsender.email";
  final String _clientSenderPasswordKey = "clientsender.password";
  final String _supportEmailKey = "support.email";

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
      _properties.stringForKey(_clientSenderEmailKey);

  String get clientSenderPassword =>
      _properties.stringForKey(_clientSenderPasswordKey);

  String get supportEmail => _properties.stringForKey(_supportEmailKey);

  String get feedbackTemplate => _feedbackTemplate;
}