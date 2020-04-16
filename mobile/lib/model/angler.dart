import 'package:meta/meta.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:quiver/strings.dart';

@immutable
class Angler extends NamedEntity {
  Angler({
    @required String name,
    String id,
  }) : assert(isNotEmpty(name)),
       super(id: id, name: name);
}