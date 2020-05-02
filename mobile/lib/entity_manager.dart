import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/utils/listener_manager.dart';
import 'package:quiver/strings.dart';

class EntityListener<T> {
  void Function(T) onDelete;
  VoidCallback onAddOrUpdate;

  EntityListener({
    this.onDelete,
    this.onAddOrUpdate,
  });
}

class SimpleEntityListener<T> extends EntityListener<T> {
  SimpleEntityListener({
    void Function(T entity) onDelete,
    VoidCallback onAddOrUpdate,
  }) : super(
    onDelete: onDelete ?? (_) {},
    onAddOrUpdate: onAddOrUpdate ?? () {},
  );
}

/// An abstract class for managing a collection of [Entity] objects.
abstract class EntityManager<T extends Entity> extends
    ListenerManager<EntityListener<T>>
{
  @protected
  final DataManager dataManager;

  @protected
  final Map<String, T> entities = {};

  String get tableName;
  T entityFromMap(Map<String, dynamic> map);

  EntityManager(AppManager app) : dataManager = app.dataManager, super();

  Future<void> initialize() async {
    (await _fetchAll()).forEach((e) => entities[e.id] = e);
  }

  List<T> get entityList => List.unmodifiable(entities.values);

  List<T> filteredEntityList(String filter) {
    return entityList.where((entity) => entity.meetsFilter(filter));
  }

  int get entityCount => entities.length;
  T entity({@required String id}) => isEmpty(id) ? null : entities[id];

  Future<bool> addOrUpdate(T entity) async {
    if (await dataManager.insertOrUpdateEntity(entity, tableName)) {
      entities[entity.id] = entity;
      notifyOnAddOrUpdate();
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
}

class EntityListenerBuilder<T> extends StatefulWidget {
  final ListenerManager<EntityListener<T>> manager;
  final Widget Function(BuildContext) builder;

  /// Invoked _before_ the call to [setState].
  final VoidCallback onUpdate;

  /// If false, the widget is not rebuilt when data is added or updated.
  final bool onAddOrUpdateEnabled;

  /// If false, the widget is not rebuilt when data is deleted.
  final bool onDeleteEnabled;

  EntityListenerBuilder({
    @required this.manager,
    @required this.builder,
    this.onUpdate,
    this.onAddOrUpdateEnabled = true,
    this.onDeleteEnabled = true,
  }) : assert(manager != null),
       assert(builder != null);

  @override
  _EntityListenerBuilderState<T> createState() =>
      _EntityListenerBuilderState<T>();
}

class _EntityListenerBuilderState<T> extends
    State<EntityListenerBuilder<T>>
{
  EntityListener _listener;

  @override
  void initState() {
    super.initState();

    _listener = SimpleEntityListener<T>(
      onDelete: widget.onDeleteEnabled ? (_) {
        widget.onUpdate?.call();
        setState(() {});
      } : null,
      onAddOrUpdate: widget.onAddOrUpdateEnabled ? () {
        widget.onUpdate?.call();
        setState(() {});
      } : null,
    );
    widget.manager.addListener(_listener);
  }

  @override
  void dispose() {
    widget.manager.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}