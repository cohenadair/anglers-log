import 'package:mobile/log.dart';
import 'package:quiver/strings.dart';

class PropertiesFile {
  final Log _log = Log("LocationMonitor");

  Map<String, String> _properties = {};

  PropertiesFile(String propertiesString) {
    if (isEmpty(propertiesString)) {
      return;
    }

    try {
      propertiesString.split("\n").forEach((line) {
        List<String> pair = line.split("=");
        if (pair.length != 2) {
          return;
        }
        if (isNotEmpty(pair.last)) {
          _properties[pair.first] = pair.last;
        }
      });
    } on Exception catch (e) {
      _log.e("Error loading properties file: $e");
    }
  }

  String stringForKey(String key) => _properties[key];
}
