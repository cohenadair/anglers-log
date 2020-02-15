import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/utils/future_listener.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:provider/provider.dart';

class BaitManager {
  static BaitManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitManager;

  static BaitManager _instance;
  factory BaitManager.get(AppManager app) {
    if (_instance == null) {
      _instance = BaitManager._internal(app);
    }
    return _instance;
  }
  BaitManager._internal(AppManager app) : _app = app;

  final String _categoryTableName = "bait_category";

  final AppManager _app;
  final VoidStreamController _onCategoryUpdateController =
      VoidStreamController();

  int get numberOfBaits => 0;

  Future<List<BaitCategory>> _fetchAllCategories() async {
    var results = await _app.dataManager.fetchAllEntities(_categoryTableName);
    return results.map((map) => BaitCategory.fromMap(map)).toList();
  }
}

/// A [FutureListener] wrapper for listening for [BaitCategory] updates.
class BaitCategoriesBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final void Function(List<BaitCategory>) onUpdate;

  BaitCategoriesBuilder({
    @required this.builder,
    @required this.onUpdate,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    BaitManager baitManager = BaitManager.of(context);
    return FutureListener.single(
      future: baitManager._fetchAllCategories,
      stream: baitManager._onCategoryUpdateController.stream,
      builder: (context) => builder(context),
      onUpdate: (dynamic result) => onUpdate(result as List<BaitCategory>),
    );
  }
}