import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'data_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/listener_manager.dart';
import 'utils/protobuf_utils.dart';

class EntityListener<T> {
  /// Invoked with the instance of T that was added.
  void Function(T) onAdd;

  /// Invoked with the instance of T that was deleted.
  void Function(T) onDelete;

  /// Invoked with all instances of T that were updated.
  void Function(List<T>) onUpdate;

  VoidCallback onClear;

  EntityListener({
    this.onAdd,
    this.onDelete,
    this.onUpdate,
    this.onClear,
  });
}

class SimpleEntityListener<T> extends EntityListener<T> {
  SimpleEntityListener({
    void Function(T entity) onAdd,
    void Function(T entity) onDelete,
    void Function(List<T> entity) onUpdate,
    VoidCallback onClear,
  }) : super(
          onAdd: onAdd ?? (_) {},
          onDelete: onDelete ?? (_) {},
          onUpdate: onUpdate ?? (_) {},
          onClear: onClear ?? () {},
        );
}

/// An abstract class for managing a collection of [Entity] objects.
abstract class EntityManager<T extends GeneratedMessage>
    extends ListenerManager<EntityListener<T>> {
  static const _columnId = "id";
  static const _columnBytes = "bytes";

  @protected
  final AppManager appManager;

  @protected
  final Map<Id, T> entities = {};

  String get tableName;
  Id id(T entity);
  bool matchesFilter(Id id, String filter);

  /// Parses a Protobuf byte representation.
  T entityFromBytes(List<int> bytes);

  EntityManager(this.appManager) : super() {
    dataManager.addListener(DataListener(
      onReset: clear,
    ));
  }

  Future<void> initialize() async {
    for (var e in (await _fetchAll())) {
      entities[id(e)] = e;
    }
  }

  @protected
  DataManager get dataManager => appManager.dataManager;

  List<T> list([List<Id> ids]) {
    if (ids == null || ids.isEmpty) {
      return List.unmodifiable(entities.values);
    }
    return entities.values.where((e) => ids.contains(id(e))).toList();
  }

  List<T> filteredList(String filter) {
    if (isEmpty(filter)) {
      return list();
    }
    return list().where((e) => matchesFilter(id(e), filter)).toList();
  }

  /// Clears the [Entity] memory collection. This method assumes the database
  /// has already been cleared.
  @protected
  Future<void> clear() async {
    entities.clear();
    await initialize();
    notifyOnClear();
  }

  int get entityCount => entities.length;

  T entity(Id id) => entities[id];

  bool entityExists(Id id) => entity(id) != null;

  /// Adds or updates the given entity. If [notify] is false (default true),
  /// listeners are not notified.
  Future<bool> addOrUpdate(
    T entity, {
    bool notify = true,
  }) async {
    var id = this.id(entity);
    if (await dataManager.insertOrUpdateEntity(
        id, _entityToMap(entity), tableName)) {
      var updated = entities.containsKey(id);
      entities[id] = entity;
      if (notify) {
        if (updated) {
          notifyOnUpdate([entity]);
        } else {
          notifyOnAdd(entity);
        }
      }
      return true;
    }
    return false;
  }

  Future<bool> delete(
    Id entityId, {
    bool notify = true,
  }) async {
    if (await dataManager.deleteEntity(entityId, tableName)) {
      var deletedEntity = entity(entityId);
      if (entities.remove(entityId) != null && notify) {
        notifyOnDelete(deletedEntity);
      }
      return true;
    }
    return false;
  }

  Future<List<T>> _fetchAll() async {
    return (await dataManager.fetchAll(tableName))
        .map(
          (map) => entityFromBytes((map[_columnBytes] as Uint8List).toList()),
        )
        .toList();
  }

  Map<String, dynamic> _entityToMap(T entity) {
    return {
      _columnId: id(entity).uint8List,
      _columnBytes: entity.writeToBuffer(),
    };
  }

  /// Replaces the database table contents with the manager's memory cache.
  @protected
  Future<void> replaceDatabaseWithCache() async {
    await dataManager.replaceRows(tableName, list().map(_entityToMap).toList());
  }

  @protected
  void notifyOnAdd(T entity) {
    notify((listener) => listener.onAdd(entity));
  }

  @protected
  void notifyOnDelete(T entity) {
    notify((listener) => listener.onDelete(entity));
  }

  @protected
  void notifyOnUpdate(List<T> entities) {
    notify((listener) => listener.onUpdate(entities));
  }

  @protected
  void notifyOnClear() {
    notify((listener) => listener.onClear());
  }

  SimpleEntityListener addSimpleListener({
    void Function(T entity) onAdd,
    void Function(T entity) onDelete,
    void Function(List<T> entity) onUpdate,
    VoidCallback onClear,
  }) {
    var listener = SimpleEntityListener<T>(
      onAdd: onAdd,
      onDelete: onDelete,
      onUpdate: onUpdate,
      onClear: onClear,
    );
    addListener(listener);
    return listener;
  }
}

class EntityListenerBuilder extends StatefulWidget {
  final List<EntityManager> managers;
  final Widget Function(BuildContext) builder;

  /// Called when an item is added to an [EntityManager] in [managers].
  final void Function(dynamic) onAdd;

  /// Called when an item is deleted from an [EntityManager] in [managers].
  final void Function(dynamic) onDelete;

  /// Called when an item in an [EntityManager] in [managers] is updated.
  final void Function(List<dynamic>) onUpdate;

  /// Called when an [EntityManager] in [managers] data is cleared.
  final VoidCallback onClear;

  /// Invoked on add, delete, or update, in addition to [onAdd], [onDelete],
  /// [onUpdate], and [onClear]. Invoked _before_ the call to [setState].
  final VoidCallback onAnyChange;

  /// If false, the widget is not rebuilt when data is deleted. This is useful
  /// when we need to pop an item from a [Navigator] when data is deleted
  /// without updating UI. Setting this flag to false in cases like that makes
  /// for more a smoother transition. Defaults to true.
  final bool onDeleteEnabled;

  EntityListenerBuilder({
    @required this.managers,
    @required this.builder,
    this.onAdd,
    this.onDelete,
    this.onDeleteEnabled = true,
    this.onUpdate,
    this.onClear,
    this.onAnyChange,
  })  : assert(managers != null && managers.isNotEmpty),
        assert(builder != null);

  @override
  _EntityListenerBuilderState createState() => _EntityListenerBuilderState();
}

class _EntityListenerBuilderState extends State<EntityListenerBuilder> {
  final List<EntityListener> _listeners = [];

  @override
  void initState() {
    super.initState();

    for (var manager in widget.managers) {
      _listeners.add(manager.addSimpleListener(
        onAdd: (entity) {
          widget.onAdd?.call(entity);
          _onAnyChange();
        },
        onDelete: widget.onDeleteEnabled
            ? (entity) {
                widget.onDelete?.call(entity);
                _onAnyChange();
              }
            : null,
        onUpdate: (entities) {
          widget.onUpdate?.call(entities);
          _onAnyChange();
        },
        onClear: () {
          widget.onClear?.call();
          _onAnyChange();
        },
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();

    for (var i = 0; i < _listeners.length; i++) {
      widget.managers[i].removeListener(_listeners[i]);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);

  void _onAnyChange() {
    // Callbacks are called outside of setState below because it's likely the
    // callbacks already call setState for the parent widget.
    widget.onAnyChange?.call();
    setState(() {});
  }
}
