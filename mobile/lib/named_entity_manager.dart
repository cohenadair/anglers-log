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
  /// Return the Protobuf name for the given entity, [T].
  @protected
  String name(T entity);

  NamedEntityManager(AppManager app) : super(app);

  int Function(T, T) displayNameComparator(BuildContext context) =>
      (lhs, rhs) => ignoreCaseAlphabeticalComparator(
          displayName(context, lhs), displayName(context, rhs));

  List<T> listSortedByDisplayName(
    BuildContext context, {
    String? filter,
    Iterable<Id> ids = const [],
  }) {
    var result = List<T>.from(filteredList(context, filter, ids));
    result.sort(displayNameComparator(context));
    return result;
  }

  @override
  String displayName(BuildContext context, T entity) => name(entity);

  @override
  bool matchesFilter(Id id, BuildContext context, String? filter) {
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
