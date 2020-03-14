import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/utils/future_stream_builder.dart';
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
  final VoidStreamController onCategoryUpdateController =
      VoidStreamController();

  int get numberOfBaits => 0;

  Future<bool> categoryNameExists(String name) {
    return _app.dataManager.exists(_categoryTableName, "name", name);
  }

  void createOrUpdateCategory(BaitCategory baitCategory) async {
    _app.dataManager.insertOrUpdateEntity(baitCategory, _categoryTableName,
        controller: onCategoryUpdateController);
  }

  void deleteCategory(BaitCategory baitCategory) async {
    _app.dataManager.deleteEntity(baitCategory, _categoryTableName,
        controller: onCategoryUpdateController);
  }

  Future<List<BaitCategory>> _fetchAllCategories() async {
    var results = await _app.dataManager.fetchAllEntities(_categoryTableName);
    return results.map((map) => BaitCategory.fromMap(map)).toList();
  }
}

/// A [FutureStreamHolder] subclass for [BaitCategory] objects.
class BaitCategoriesFutureStreamHolder extends FutureStreamHolder {
  BaitCategoriesFutureStreamHolder(BuildContext context, {
    void Function(List<BaitCategory>) onUpdate,
  }) : super.single(
    futureCallback: BaitManager.of(context)._fetchAllCategories,
    stream: BaitManager.of(context).onCategoryUpdateController.stream,
    onUpdate: (result) => onUpdate(result as List<BaitCategory>),
  );
}

/// A [FutureStreamBuilder] wrapper for listening for [BaitCategory] updates.
class BaitCategoriesBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final void Function(List<BaitCategory>) onUpdate;

  BaitCategoriesBuilder({
    @required this.builder,
    @required this.onUpdate,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    return FutureStreamBuilder(
      holder: BaitCategoriesFutureStreamHolder(context, onUpdate: onUpdate),
      builder: (context) => builder(context),
    );
  }
}