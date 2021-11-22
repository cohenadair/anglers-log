import 'package:mobile/app_manager.dart';
import 'package:protobuf/protobuf.dart';

import 'catch_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';

abstract class CatchFieldEntityManager<T extends GeneratedMessage>
    extends NamedEntityManager<T> {
  /// Returns a collection of IDs for [T] on the given [Catch] object.
  Iterable<Id> idFromCatch(Catch cat);

  CatchFieldEntityManager(AppManager appManager) : super(appManager);

  CatchManager get _catchManager => appManager.catchManager;

  int numberOfCatches(Id? entityId) => numberOf<Catch>(entityId,
      _catchManager.list(), (cat) => idFromCatch(cat).contains(entityId));

  /// Returns the entity with the most catches, or null if there are no
  /// entity in the log.
  T? get favorite {
    var entities = List.of(list());
    entities.sort(
        (a, b) => numberOfCatches(id(b)).compareTo(numberOfCatches(id(a))));
    return entities.first;
  }
}
