import 'package:meta/meta.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/utils/string_utils.dart';

class Angler extends Entity {
  static const key = "angler";
  static const _keyName = "name";

  Angler({
    @required String name,
  }) : assert(isNotEmpty(name)),
       super()
  {
    setProperty(key: _keyName, value: name);
  }

  String get name => property(key: name);
}