import 'package:meta/meta.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/utils/string_utils.dart';

class Angler extends Entity {
  static const keyName = "name";

  Angler({
    @required String name,
  }) : assert(isNotEmpty(name)),
       super()
  {
    setProperty(key: keyName, value: name);
  }

  String get name => getProperty(key: keyName);
}