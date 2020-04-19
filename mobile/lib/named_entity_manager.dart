import 'package:mobile/app_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/utils/string_utils.dart';

abstract class NamedEntityManager<T extends NamedEntity>
    extends EntityManager<T>
{
  NamedEntityManager(AppManager app) : super(app);

  List<T> get entityListSortedByName {
    List<T> result = List.from(entityList);
    result.sort((T lhs, T rhs) => lhs.compareNameTo(rhs));
    return result;
  }

  bool nameExists(String name) {
    return entities.values.firstWhere((entity) =>
        isEqualTrimmedLowercase(name, entity.name), orElse: () => null) != null;
  }
}