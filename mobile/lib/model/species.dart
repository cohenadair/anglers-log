import 'package:meta/meta.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:quiver/strings.dart';

@immutable
class Species extends NamedEntity {
  Species({
    @required String name,
    String id,
  }) : assert(isNotEmpty(name)),
       super(id: id, name: name);

  Species.fromMap(Map<String, dynamic> map) : super.fromMap(map);
}