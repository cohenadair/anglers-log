import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'data_source_facilitator.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/protobuf_utils.dart';
import 'wrappers/firestore_wrapper.dart';

class EntityListener<T> {
  /// Invoked with the instance of T that was added.
  void Function(T) onAdd;

  /// Invoked with the instance of T that was deleted.
  void Function(T) onDelete;

  /// Invoked with the instance of T that were updated.
  void Function(T) onUpdate;

  EntityListener({
    this.onAdd,
    this.onDelete,
    this.onUpdate,
  });
}

class SimpleEntityListener<T> extends EntityListener<T> {
  SimpleEntityListener({
    void Function(T entity) onAdd,
    void Function(T entity) onDelete,
    void Function(T entity) onUpdate,
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

  bool matchesFilter(Id id, String filter);

  /// Parses a Protobuf byte representation of T.
  T entityFromBytes(List<int> bytes);

  final _log = Log("EntityManager<$T>");
  final Set<EntityListener<T>> _listeners = {};

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
  void clearLocalData() {
    for (var entity in entities.values) {
      _deleteLocal(id(entity), notify: false);
    }
  }

  @override
  StreamSubscription<dynamic> initializeFirestore(Completer completer) {
    return firestore.collection(_collectionPath).snapshots().listen((snapshot) {
      if (snapshot == null) {
        return;
      }

      for (var change in snapshot.docChanges) {
        var bytes = change.doc.data()[_columnBytes] ?? [];
        var entity =
            bytes.isNotEmpty ? entityFromBytes(List<int>.from(bytes)) : null;
        if (entity == null) {
          _log.d("Couldn't parse bytes: ${change.doc.data()}");
          continue;
        }

        // Data has been processed by Firestore, update it locally.
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          _log.d("Doc change: ${change.type}");
          _addOrUpdateLocal(entity);
        } else if (change.type == DocumentChangeType.removed) {
          _log.d("Doc change: delete");
          _deleteLocal(id(entity));
        } else {
          _log.w("Unknown Firestore document change type: $change");
        }
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    });
  }

  @override
  void onLocalDatabaseDeleted() {
    for (var entity in entities.values) {
      delete(id(entity), notify: false);
    }
  }

  FirestoreWrapper get firestore => appManager.firestoreWrapper;

  String get _collectionPath => "${authManager.firestoreDocPath}/$tableName";

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

  int get entityCount => entities.length;

  T entity(Id id) => entities[id];

  bool entityExists(Id id) => entity(id) != null;

  Future<bool> addOrUpdate(
    T entity, {
    bool notify = true,
  }) async {
    if (shouldUseFirestore) {
      _log.d("addOrUpdate Firestore");
      return _addOrUpdateFirestore(entity);
    } else {
      _log.d("addOrUpdate locally");
      return _addOrUpdateLocal(entity, notify: notify);
    }
  }

  Future<bool> _addOrUpdateFirestore(T entity) async {
    await firestore
        .collection(_collectionPath)
        .doc(id(entity).uuid.toString())
        .set({
      _columnBytes: entity.writeToBuffer(),
    });
    return true;
  }

  /// Adds or updates the given entity. If [notify] is false (default true),
  /// listeners are not notified.
  Future<bool> _addOrUpdateLocal(
    T entity, {
    bool notify = true,
  }) async {
    var id = this.id(entity);
    var map = {
      _columnId: id.uint8List,
      _columnBytes: entity.writeToBuffer(),
    };

    if (await localDatabaseManager.insertOrUpdateEntity(id, map, tableName)) {
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
      _deleteFirestore(entityId, notify: notify);
    } else {
      _deleteLocal(entityId, notify: notify);
    }
    return true;
  }

  Future<void> _deleteFirestore(
    Id entityId, {
    bool notify = true,
  }) async {
    // Temporarily pause listener if we don't want to notify listeners.
    if (!notify) {
      firestoreListener.pause();
    }

    await firestore
        .collection(_collectionPath)
        .doc(entityId.uuid.toString())
        .delete();

    firestoreListener.resume();
  }

  Future<void> _deleteLocal(
    Id entityId, {
    bool notify = true,
  }) async {
    if (entityExists(entityId) &&
        await localDatabaseManager.deleteEntity(entityId, tableName)) {
      _log.d("Deleted locally");
      var deletedEntity = entity(entityId);
      if (entities.remove(entityId) != null && notify) {
        notifyOnDelete(deletedEntity);
      }
    }
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
    if (_listeners.remove(listener) == null) {
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
    _notify((listener) => listener.onAdd(entity));
  }

  @protected
  void notifyOnDelete(T entity) {
    _notify((listener) => listener.onDelete(entity));
  }

  @protected
  void notifyOnUpdate(T entity) {
    _notify((listener) => listener.onUpdate(entity));
  }

  SimpleEntityListener addSimpleListener({
    void Function(T entity) onAdd,
    void Function(T entity) onDelete,
    void Function(T entity) onUpdate,
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
  final List<EntityManager> managers;
  final Widget Function(BuildContext) builder;

  /// Called when an item is added to an [EntityManager] in [managers].
  final void Function(dynamic) onAdd;

  /// Called when an item is deleted from an [EntityManager] in [managers].
  final void Function(dynamic) onDelete;

  /// Called when an item is updated by an [EntityManager] in [managers].
  final void Function(dynamic) onUpdate;

  /// Invoked on add, delete, or update, in addition to [onAdd], [onDelete],
  /// [onUpdate]. Invoked _before_ the call to [setState].
  final VoidCallback onAnyChange;

  /// If false, the widget is not rebuilt when data is deleted. This is useful
  /// when we need to pop an item from a [Navigator] when data is deleted
  /// without updating UI. Setting this flag to false in cases like that makes
  /// for a smoother transition. Defaults to true.
  final bool onDeleteEnabled;

  EntityListenerBuilder({
    @required this.managers,
    @required this.builder,
    this.onAdd,
    this.onDelete,
    this.onDeleteEnabled = true,
    this.onUpdate,
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
        onUpdate: (entity) {
          widget.onUpdate?.call(entity);
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
