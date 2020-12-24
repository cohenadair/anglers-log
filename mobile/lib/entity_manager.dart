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
  void Function(T) onDelete;
  VoidCallback onAddOrUpdate;
  VoidCallback onClear;

  EntityListener({
    this.onDelete,
    this.onAddOrUpdate,
    this.onClear,
  });
}

class SimpleEntityListener<T> extends EntityListener<T> {
  SimpleEntityListener({
    void Function(T entity) onDelete,
    VoidCallback onAddOrUpdate,
    VoidCallback onClear,
  }) : super(
          onDelete: onDelete ?? (_) {},
          onAddOrUpdate: onAddOrUpdate ?? () {},
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

  /// Adds or updates the given [Entity]. If [notify] is false (default true),
  /// listeners are not notified.
  Future<bool> addOrUpdate(
    T entity, {
    bool notify = true,
  }) async {
    var id = this.id(entity);
    if (await dataManager.insertOrUpdateEntity(
        id, _entityToMap(entity), tableName)) {
      entities[id] = entity;
      if (notify) {
        notifyOnAddOrUpdate();
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
  void notifyOnAddOrUpdate() {
    notify((listener) => listener.onAddOrUpdate());
  }

  @protected
  void notifyOnDelete(T entity) {
    notify((listener) => listener.onDelete(entity));
  }

  @protected
  void notifyOnClear() {
    notify((listener) => listener.onClear());
  }

  SimpleEntityListener addSimpleListener({
    void Function(T entity) onDelete,
    VoidCallback onAddOrUpdate,
    VoidCallback onClear,
  }) {
    var listener = SimpleEntityListener<T>(
      onDelete: onDelete,
      onAddOrUpdate: onAddOrUpdate,
      onClear: onClear,
    );
    addListener(listener);
    return listener;
  }
}

class EntityListenerBuilder extends StatefulWidget {
  final List<EntityManager> managers;
  final Widget Function(BuildContext) builder;

  /// Invoked _before_ the call to [setState].
  final VoidCallback onUpdate;

  /// If false, the widget is not rebuilt when data is deleted. This is useful
  /// when we need to pop an item from a [Navigator] when data is deleted
  /// without updating UI. Makes more a smoother transition.
  final bool onDeleteEnabled;

  EntityListenerBuilder({
    @required this.managers,
    @required this.builder,
    this.onUpdate,
    this.onDeleteEnabled = true,
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
        onDelete: widget.onDeleteEnabled ? (_) => _update() : null,
        onAddOrUpdate: _update,
        onClear: _update,
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

  void _update() {
    // Called outside of setState because it's likely the onUpdate callback
    // calls setState for the parent widget.
    widget.onUpdate?.call();
    setState(() {});
  }
}
