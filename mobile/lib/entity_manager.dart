import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';
import 'package:sqflite/sqflite.dart';

import 'app_manager.dart';
import 'local_database_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';

class EntityListener<T> {
  /// Invoked with the instance of T that was added.
  void Function(T)? onAdd;

  /// Invoked with the instance of T that was deleted.
  void Function(T)? onDelete;

  /// Invoked with the instance of T that were updated.
  void Function(T)? onUpdate;

  /// Invoked when entities are reset, such as after restoring from a backup.
  void Function()? onReset;

  EntityListener({
    this.onAdd,
    this.onDelete,
    this.onUpdate,
    this.onReset,
  });
}

/// An abstract class for managing a collection of [Entity] objects.
///
/// There are two paths for data management. One for Pro users, and one for
/// Free users. Pro users' data is funnelled through Cloud Firestore before
/// updating the local data and notifying listeners. Free users' data, on the
/// other hand, goes directly to local storage.
abstract class EntityManager<T extends GeneratedMessage> {
  static const _columnId = "id";
  static const _columnBytes = "bytes";

  /// SQLite table and Cloud Firestore collection name for T.
  String get tableName;

  Id id(T entity);

  /// Returns a value for [T] to be displayed to the user.
  String displayName(BuildContext context, T entity);

  bool matchesFilter(Id id, String? filter);

  /// Parses a Protobuf byte representation of T.
  T entityFromBytes(List<int> bytes);

  final _log = Log("EntityManager<$T>");
  final Set<EntityListener<T>> _listeners = {};

  @protected
  final Map<Id, T> entities = {};

  @protected
  final AppManager appManager;

  EntityManager(this.appManager);

  Future<void> initialize() async {
    entities.clear();
    for (var e in (await _fetchAll())) {
      entities[id(e)] = e;
    }
    _notifyOnReset();
  }

  @protected
  LocalDatabaseManager get localDatabaseManager =>
      appManager.localDatabaseManager;

  bool idsMatchesFilter(List<Id> ids, String? filter) {
    for (var id in ids) {
      if (matchesFilter(id, filter)) {
        return true;
      }
    }
    return false;
  }

  /// Returns a [Set] of entity [Id] objects. If [ids] is not empty, the IDs
  /// returned are guaranteed to exist in the database.
  Set<Id> idSet({
    Iterable<T> entities = const [],
    Iterable<Id> ids = const [],
  }) =>
      (entities.isEmpty ? list(ids) : entities).map((e) => id(e)).toSet();

  List<T> list([Iterable<Id> ids = const []]) {
    if (ids.isEmpty) {
      return List.unmodifiable(entities.values);
    }
    return entities.values.where((e) => ids.contains(id(e))).toList();
  }

  List<T> filteredList(String? filter, [Iterable<Id> ids = const []]) {
    if (isEmpty(filter)) {
      return list(ids);
    }
    return list(ids).where((e) => matchesFilter(id(e), filter)).toList();
  }

  /// Returns true of any entity in [ids] matches [filter]. Returns false if
  /// either [ids] or [filter] is empty or null.
  bool idsMatchFilter(Iterable<Id> ids, String? filter) {
    if (ids.isEmpty || isEmpty(filter)) {
      return false;
    }
    for (var id in ids) {
      if (matchesFilter(id, filter)) {
        return true;
      }
    }
    return false;
  }

  int get entityCount => entities.length;

  bool get hasEntities => entities.isNotEmpty;

  T? entity(Id? id) => entities[id];

  bool entityExists(Id? id) => entity(id) != null;

  Future<bool> addOrUpdate(
    T entity, {
    bool notify = true,
  }) async {
    _log.d("addOrUpdate locally");
    return _addOrUpdateLocal(entity, notify: notify);
  }

  /// Adds or updates the given entity. If [notify] is false (default true),
  /// listeners are not notified.
  Future<bool> _addOrUpdateLocal(
    T entity, {
    bool notify = true,
    Batch? batch,
  }) async {
    var id = this.id(entity);
    var map = {
      _columnId: id.uint8List,
      _columnBytes: entity.writeToBuffer(),
    };

    if (await localDatabaseManager.insertOrReplace(tableName, map, batch)) {
      var updated = entities.containsKey(id);
      entities[id] = entity;
      if (notify) {
        if (updated) {
          notifyOnUpdate(entity);
        } else {
          notifyOnAdd(entity);
        }
      }
      return true;
    }

    return false;
  }

  /// Deletes entity with [ID], if one exists. If [notify] is false (default
  /// true), listeners are not notified.
  Future<bool> delete(
    Id entityId, {
    bool notify = true,
  }) async {
    await _deleteLocal(entityId, notify: notify);
    return true;
  }

  Future<void> _deleteLocal(
    Id entityId, {
    bool notify = true,
    Batch? batch,
  }) async {
    if (entityExists(entityId) &&
        await localDatabaseManager.deleteEntity(entityId, tableName, batch)) {
      _log.d("Deleted locally");
      _deleteMemory(entityId, notify: notify);
    }
  }

  void _deleteMemory(
    Id entityId, {
    bool notify = true,
  }) {
    var deletedEntity = entities.remove(entityId);
    if (deletedEntity != null && notify) {
      notifyOnDelete(deletedEntity);
    }
  }

  @protected
  int numberOf<E extends GeneratedMessage>(
      Id? id, List<E> items, bool Function(E) matches) {
    if (id == null) {
      return 0;
    }

    var result = 0;
    for (var entity in items) {
      result += matches(entity) ? 1 : 0;
    }

    return result;
  }

  Future<List<T>> _fetchAll() async {
    return (await localDatabaseManager.fetchAll(tableName))
        .map(
          (map) => entityFromBytes((map[_columnBytes] as Uint8List).toList()),
        )
        .toList();
  }

  void addListener(EntityListener<T> listener) {
    _listeners.add(listener);
  }

  void removeListener(EntityListener<T> listener) {
    if (!_listeners.remove(listener)) {
      _log.w("Attempt to remove listener that isn't in stored in manager");
    }
  }

  void _notify(void Function(EntityListener<T>) notify) {
    for (var listener in _listeners) {
      notify(listener);
    }
  }

  @protected
  void notifyOnAdd(T entity) {
    _notify((listener) => listener.onAdd?.call(entity));
  }

  @protected
  void notifyOnDelete(T entity) {
    _notify((listener) => listener.onDelete?.call(entity));
  }

  @protected
  void notifyOnUpdate(T entity) {
    _notify((listener) => listener.onUpdate?.call(entity));
  }

  void _notifyOnReset() {
    _notify((listener) => listener.onReset?.call());
  }

  // Required to create a listener of type T, so EntityListenerBuilder doesn't
  // need to have a generic parameter.
  EntityListener<T> addTypedListener({
    void Function(T entity)? onAdd,
    void Function(T entity)? onDelete,
    void Function(T entity)? onUpdate,
    void Function()? onReset,
  }) {
    var listener = EntityListener<T>(
      onAdd: onAdd,
      onDelete: onDelete,
      onUpdate: onUpdate,
      onReset: onReset,
    );
    addListener(listener);
    return listener;
  }
}

class EntityListenerBuilder extends StatefulWidget {
  final List<EntityManager<GeneratedMessage>> managers;
  final Widget Function(BuildContext) builder;

  /// Called when an item is added to an [EntityManager] in [managers]. Invoked
  /// _inside_ the call to [setState]. As such, [onAdd] should not return a
  /// [Future].
  final void Function(dynamic)? onAdd;

  /// Called when an item is deleted from an [EntityManager] in [managers].
  /// Invoked _inside_ the call to [setState]. As such, [onDelete] should not
  /// return a [Future].
  final void Function(dynamic)? onDelete;

  /// Called when an item is updated by an [EntityManager] in [managers].
  /// Invoked _inside_ the call to [setState]. As such, [onUpdate] should not
  /// return a [Future].
  final void Function(dynamic)? onUpdate;

  /// Invoked on add, delete, or update, in addition to [onAdd], [onDelete],
  /// [onUpdate]. Also invoked when data is reset. Invoked _inside_ the call
  /// to [setState]. As such, [onAnyChange] should not return a [Future].
  final VoidCallback? onAnyChange;

  /// When true, [setState] is invoked when [onAdd], [onDelete], or
  /// [onAnyChange] is invoked. If false, [setState] is not invoked, and it is
  /// the responsibility of the caller to invoke [setState]. Default to true.
  ///
  /// This exists for cases where async work needs to be done when data changes.
  /// Calls to [setState] cannot return futures, and must be done after the
  /// async work has finished.
  final bool changesUpdatesState;

  /// If false, the widget is not rebuilt when data is deleted. This is useful
  /// when we need to pop an item from a [Navigator] when data is deleted
  /// without updating UI. Setting this flag to false in cases like that makes
  /// for a smoother transition. Defaults to true.
  final bool onDeleteEnabled;

  const EntityListenerBuilder({
    required this.managers,
    required this.builder,
    this.onAdd,
    this.onDelete,
    this.onDeleteEnabled = true,
    this.onUpdate,
    this.onAnyChange,
    this.changesUpdatesState = true,
  });

  @override
  _EntityListenerBuilderState createState() => _EntityListenerBuilderState();
}

class _EntityListenerBuilderState extends State<EntityListenerBuilder> {
  final List<EntityListener<GeneratedMessage>> _listeners = [];

  @override
  void initState() {
    super.initState();

    for (var manager in widget.managers) {
      _listeners.add(manager.addTypedListener(
        onAdd: _onAdd,
        onDelete: _onDelete,
        onUpdate: _onUpdate,
        onReset: _onReset,
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

  void _onAdd(dynamic entity) {
    _notify(() {
      widget.onAdd?.call(entity);
      widget.onAnyChange?.call();
    });
  }

  void _onDelete(dynamic entity) {
    if (!widget.onDeleteEnabled) {
      return;
    }

    _notify(() {
      widget.onDelete?.call(entity);
      widget.onAnyChange?.call();
    });
  }

  void _onUpdate(dynamic entity) {
    _notify(() {
      widget.onUpdate?.call(entity);
      widget.onAnyChange?.call();
    });
  }

  void _onReset() {
    _notify(() => widget.onAnyChange?.call());
  }

  void _notify(VoidCallback callback) {
    if (widget.changesUpdatesState) {
      setState(() => callback());
    } else {
      callback();
    }
  }
}
