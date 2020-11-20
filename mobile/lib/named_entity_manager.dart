import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'entity_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/string_utils.dart';

abstract class NamedEntityManager<T extends GeneratedMessage>
    extends EntityManager<T> {
  String name(T entity);

  NamedEntityManager(AppManager app) : super(app);

  List<T> listSortedByName({String filter}) {
    var result = List<T>.from(filteredList(filter));
    result.sort((lhs, rhs) => compareIgnoreCase(name(lhs), name(rhs)));
    return result;
  }

  @override
  bool matchesFilter(Id id, String filter) {
    if (id == null || isEmpty(filter)) {
      return true;
    }

    var entity = this.entity(id);
    if (entity == null) {
      return false;
    }

    return name(entity).toLowerCase().contains(filter.toLowerCase());
  }

  bool nameExists(String name) {
    return named(name) != null;
  }

  T named(String name) {
    if (isEmpty(name)) {
      return null;
    }
    return entities.values.firstWhere(
        (e) => equalsTrimmedIgnoreCase(name, this.name(e)),
        orElse: () => null);
  }
}
