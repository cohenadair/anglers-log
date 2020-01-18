import 'package:meta/meta.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';
import 'package:quiver/strings.dart';

@immutable
class Angler extends Entity {
  static const _keyName = "name";

  Angler({
    @required String name,
  }) : assert(isNotEmpty(name)),
       super([
         Property<String>(key: _keyName, value: name),
       ]);

  String get name =>
      (propertyWithName(_keyName) as Property<String>).value;
}