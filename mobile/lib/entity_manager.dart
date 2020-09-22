import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/listener_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

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
    extends ListenerManager<EntityListener<T>>
{
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

  EntityManager(AppManager app) : appManager = app, super() {
    dataManager.addListener(DataListener(
      onReset: clear,
    ));
  }

  Future<void> initialize() async {
    (await _fetchAll()).forEach((e) => entities[id(e)] = e);
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
    return list().where((e) => isEmpty(filter) || matchesFilter(id(e), filter))
        .toList();
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
  Future<bool> addOrUpdate(T entity, {
    bool notify = true,
  }) async {
    Id id = this.id(entity);
    if (await dataManager.insertOrUpdateEntity(id, _entityToMap(entity),
        tableName))
    {
      entities[id] = entity;
      if (notify) {
        notifyOnAddOrUpdate();
      }
      return true;
    }
    return false;
  }

  Future<bool> delete(Id entityId) async {
    if (await dataManager.deleteEntity(entityId, tableName)) {
      T deletedEntity = entity(entityId);
      if (entities.remove(entityId) != null) {
        notifyOnDelete(deletedEntity);
      }
      return true;
    }
    return false;
  }

  Future<List<T>> _fetchAll() async {
    return (await dataManager.fetchAll(tableName)).map((map) =>
        entityFromBytes((map[_columnBytes] as Uint8List).toList())).toList();
  }

  Map<String, dynamic> _entityToMap(T entity) => {
    _columnId: id(entity).uint8List,
    _columnBytes: entity.writeToBuffer(),
  };

  /// Replaces the database table contents with the manager's memory cache.
  @protected
  Future<void> replaceDatabaseWithCache() async {
    await dataManager
        .replaceRows(tableName, list().map((e) => _entityToMap(e)).toList());
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

  SimpleEntityListener _addSimpleListener({
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
  }) : assert(managers != null && managers.isNotEmpty),
       assert(builder != null);

  @override
  _EntityListenerBuilderState createState() => _EntityListenerBuilderState();
}

class _EntityListenerBuilderState extends State<EntityListenerBuilder> {
  List<EntityListener> _listeners = [];

  @override
  void initState() {
    super.initState();

    widget.managers.forEach((manager) => {
      _listeners.add(manager._addSimpleListener(
        onDelete: widget.onDeleteEnabled ? (_) => _update() : null,
        onAddOrUpdate: _update,
        onClear: _update,
      ))
    });
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
    widget.onUpdate?.call();
    setState(() {});
  }
}