import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/utils/listener_manager.dart';
import 'package:quiver/strings.dart';

enum EntityType {
  baitCategory,
  bait,
  custom,
  fishCatch, // "catch" is a reserved keyword
  fishingSpot,
  species,
}

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
abstract class EntityManager<T extends Entity> extends
    ListenerManager<EntityListener<T>>
{
  @protected
  final AppManager appManager;

  @protected
  final Map<String, T> entities = {};

  String get tableName;
  T entityFromMap(Map<String, dynamic> map);

  EntityManager(AppManager app) : appManager = app, super() {
    appManager.dataManager.addListener(DataListener(
      onReset: _clear,
    ));
  }

  Future<void> initialize() async {
    (await _fetchAll()).forEach((e) => entities[e.id] = e);
  }

  @protected
  DataManager get dataManager => appManager.dataManager;

  List<T> get entityList => List.unmodifiable(entities.values);

  /// Clears the [Entity] memory collection. This method assumes the database
  /// has already been cleared.
  Future<void> _clear() async {
    entities.clear();
    await initialize();
    notifyOnClear();
  }

  List<T> filteredEntityList(String filter) {
    return entityList.where((entity) => entity.matchesFilter(filter)).toList();
  }

  int get entityCount => entities.length;
  T entity({@required String id}) => isEmpty(id) ? null : entities[id];

  /// Adds or updates the given [Entity]. If [notify] is false (default true),
  /// listeners are not notified.
  Future<bool> addOrUpdate(T entity, {
    bool notify = true,
  }) async {
    if (await dataManager.insertOrUpdateEntity(entity, tableName)) {
      entities[entity.id] = entity;
      if (notify) {
        notifyOnAddOrUpdate();
      }
      return true;
    }
    return false;
  }

  Future<bool> delete(T entity) async {
    if (await dataManager.deleteEntity(entity, tableName)) {
      entities.remove(entity.id);
      notifyOnDelete(entity);
      return true;
    }
    return false;
  }

  Future<List<T>> _fetchAll() async {
    var results = await dataManager.fetchAll(tableName);
    return results.map((map) => entityFromMap(map)).toList();
  }

  void notifyOnAddOrUpdate() {
    notify((listener) => listener.onAddOrUpdate());
  }

  void notifyOnDelete(T entity) {
    notify((listener) => listener.onDelete(entity));
  }

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
      _listeners.add(manager.addSimpleListener(
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