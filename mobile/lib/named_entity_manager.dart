import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
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

  int Function(T, T) displayNameComparator(BuildContext context) =>
      (lhs, rhs) => ignoreCaseAlphabeticalComparator(name(lhs), name(rhs));

  int Function(T, T) get nameComparator =>
      (lhs, rhs) => ignoreCaseAlphabeticalComparator(name(lhs), name(rhs));

  List<T> listSortedByName({String? filter}) {
    var result = List<T>.from(filteredList(filter));
    result.sort(nameComparator);
    return result;
  }

  @override
  String displayName(BuildContext context, T entity) => name(entity);

  @override
  bool matchesFilter(Id id, String? filter) {
    if (isEmpty(filter)) {
      return true;
    }

    var entity = this.entity(id);
    if (entity == null) {
      return false;
    }

    return containsTrimmedLowerCase(name(entity), filter!);
  }

  bool nameExists(String name) => named(name) != null;

  /// Returns the entity with the given name, or null if one doesn't exist.
  /// [andCondition] is invoked for each value in [entities] and must evaluate
  /// to true for a non-null result.
  T? named(
    String? name, {
    bool Function(T)? andCondition,
  }) {
    if (isEmpty(name)) {
      return null;
    }
    return entities.values.firstWhereOrNull((e) {
      return equalsTrimmedIgnoreCase(name!, this.name(e)) &&
          (andCondition?.call(e) ?? true);
    });
  }
}
