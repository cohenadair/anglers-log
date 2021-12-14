import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';
import 'package:sqflite/sqflite.dart';

import 'app_manager.dart';
import 'data_source_facilitator.dart';
import 'local_database_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';
import 'wrappers/firestore_wrapper.dart';

class EntityListener<T> {
  /// Invoked with the instance of T that was added.
  void Function(T)? onAdd;

  /// Invoked with the instance of T that was deleted.
  void Function(T)? onDelete;

  /// Invoked with the instance of T that were updated.
  void Function(T)? onUpdate;

  EntityListener({
    this.onAdd,
    this.onDelete,
    this.onUpdate,
  });
}

class SimpleEntityListener<T> extends EntityListener<T> {
  SimpleEntityListener({
    void Function(T entity)? onAdd,
    void Function(T entity)? onDelete,
    void Function(T entity)? onUpdate,
  }) : super(
          onAdd: onAdd ?? (_) {},
          onDelete: onDelete ?? (_) {},
          onUpdate: onUpdate ?? (_) {},
        );
}

/// An abstract class for managing a collection of [Entity] objects.
///
/// There are two paths for data management. One for Pro users, and one for
/// Free users. Pro users' data is funnelled through Cloud Firestore before
/// updating the local data and notifying listeners. Free users' data, on the
/// other hand, goes directly to local storage.
abstract class EntityManager<T extends GeneratedMessage>
    extends DataSourceFacilitator {
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

  /// Stores [Id]s for which notify actions should be skipped. Used to bridge
  /// the gap between updates and Firestore listeners.
  final List<Id> _firebaseSkipNotifyIds = [];

  @protected
  final Map<Id, T> entities = {};

  EntityManager(AppManager appManager) : super(appManager);

  @override
  bool get enableFirestore => true;

  @override
  Future<void> initializeLocalData() async {
    for (var e in (await _fetchAll())) {
      entities[id(e)] = e;
    }
  }

  @override
  void clearMemory() {
    entities.clear();
  }

  @override
  StreamSubscription<dynamic> initializeFirestore(Completer completer) {
    return firestore
        .collection(_collectionPath)
        .snapshots()
        .listen((snapshot) async {
      await localDatabaseManager.commitTransaction((batch) async =>
          await _processFirestoreChanges(batch, snapshot.docChanges));

      // Consider initialization done once all document changes have been
      // processed.
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
  }

  Future<void> _processFirestoreChanges(
      Batch batch, List<DocumentChange<Map<String, dynamic>>> changes) async {
    var logMap = {
      DocumentChangeType.added: 0,
      DocumentChangeType.modified: 0,
      DocumentChangeType.removed: 0,
    };

    for (var change in changes) {
      var bytes = change.doc.data()![_columnBytes] ?? [];
      var entity =
          bytes.isNotEmpty ? entityFromBytes(List<int>.from(bytes)) : null;
      if (entity == null) {
        _log.d("Couldn't parse bytes: ${change.doc.data()}");
        continue;
      }

      // Data has been processed by Firestore, update it locally.
      var id = this.id(entity);
      var notify = !_firebaseSkipNotifyIds.contains(id);

      logMap[change.type] = logMap[change.type]! + 1;

      switch (change.type) {
        case DocumentChangeType.added:
        // Fallthrough
        case DocumentChangeType.modified:
          await _addOrUpdateLocal(entity, notify: notify, batch: batch);
          break;
        case DocumentChangeType.removed:
          await _deleteLocal(id, notify: notify, batch: batch);
          break;
      }

      _firebaseSkipNotifyIds.remove(id);
    }

    _log.d("Doc added=${logMap[DocumentChangeType.added]}; "
        "modified=${logMap[DocumentChangeType.modified]}; "
        "removed=${logMap[DocumentChangeType.removed]}");
  }

  @override
  void onUpgradeToPro() {
    // Since initializeFirestore has already been called, all data has been
    // downloaded. All that's left to do is upload all local entities.
    //
    // No need to notify; these entities are already in the local database.
    list().forEach((entity) => _addOrUpdateFirestore(entity, notify: false));
  }

  FirestoreWrapper get firestore => appManager.firestoreWrapper;

  @protected
  LocalDatabaseManager get localDatabaseManager =>
      appManager.localDatabaseManager;

  String get _collectionPath => "${authManager.firestoreDocPath}/$tableName";

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
    if (shouldUseFirestore) {
      _log.d("addOrUpdate Firestore");
      return _addOrUpdateFirestore(entity, notify: notify);
    } else {
      _log.d("addOrUpdate locally");
      return _addOrUpdateLocal(entity, notify: notify);
    }
  }

  Future<bool> _addOrUpdateFirestore(
    T entity, {
    bool notify = true,
  }) async {
    var id = this.id(entity);

    if (!notify) {
      _firebaseSkipNotifyIds.add(id);
    }

    await firestore.collection(_collectionPath).doc(id.uuid.toString()).set({
      _columnBytes: entity.writeToBuffer(),
    });

    return true;
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
    if (shouldUseFirestore) {
      await _deleteFirestore(entityId, notify: notify);
    } else {
      await _deleteLocal(entityId, notify: notify);
    }
    return true;
  }

  Future<void> _deleteFirestore(
    Id entityId, {
    bool notify = true,
  }) async {
    if (!notify) {
      _firebaseSkipNotifyIds.add(entityId);
    }

    await firestore
        .collection(_collectionPath)
        .doc(entityId.uuid.toString())
        .delete();
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

  SimpleEntityListener<T> addSimpleListener({
    void Function(T entity)? onAdd,
    void Function(T entity)? onDelete,
    void Function(T entity)? onUpdate,
  }) {
    var listener = SimpleEntityListener<T>(
      onAdd: onAdd,
      onDelete: onDelete,
      onUpdate: onUpdate,
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
  /// [onUpdate]. Invoked _inside_ the call to [setState]. As such,
  /// [onAnyChange] should not return a [Future].
  final VoidCallback? onAnyChange;

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
      _listeners.add(manager.addSimpleListener(
        onAdd: (entity) => setState(() {
          widget.onAdd?.call(entity);
          widget.onAnyChange?.call();
        }),
        onDelete: widget.onDeleteEnabled
            ? (entity) {
                setState(() {
                  widget.onDelete?.call(entity);
                  widget.onAnyChange?.call();
                });
              }
            : null,
        onUpdate: (entity) => setState(() {
          widget.onUpdate?.call(entity);
          widget.onAnyChange?.call();
        }),
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
}
