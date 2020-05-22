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
  final AppManager appManager;

  @protected
  final DataManager dataManager;

  @protected
  final Map<String, T> entities = {};

  String get tableName;
  T entityFromMap(Map<String, dynamic> map);

  EntityManager(AppManager app)
      : appManager = app,
        dataManager = app.dataManager,
        super();

  Future<void> initialize() async {
    (await _fetchAll()).forEach((e) => entities[e.id] = e);
  }

  List<T> get entityList => List.unmodifiable(entities.values);

  List<T> filteredEntityList(String filter) {
    return entityList.where((entity) => entity.matchesFilter(filter)).toList();
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

  SimpleEntityListener addSimpleListener({
    void Function(T entity) onDelete,
    VoidCallback onAddOrUpdate,
  }) {
    var listener = SimpleEntityListener<T>(
      onDelete: onDelete,
      onAddOrUpdate: onAddOrUpdate,
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
        onDelete: widget.onDeleteEnabled ? (_) {
          widget.onUpdate?.call();
          setState(() {});
        } : null,
        onAddOrUpdate: () {
          widget.onUpdate?.call();
          setState(() {});
        },
      ))
    });
  }

  @override
  void dispose() {
    for (var i = 0; i < _listeners.length; i++) {
      widget.managers[i].removeListener(_listeners[i]);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}