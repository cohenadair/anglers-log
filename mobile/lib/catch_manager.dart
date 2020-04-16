import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/utils/future_stream_builder.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:provider/provider.dart';

class CatchManager {
  static CatchManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchManager;

  static CatchManager _instance;
  factory CatchManager.get(AppManager app) {
    if (_instance == null) {
      _instance = CatchManager._internal(app);
    }
    return _instance;
  }
  CatchManager._internal(AppManager app) : _app = app;

  final String _tableName = "catch";

  final AppManager _app;
  final VoidStreamController _onUpdate = VoidStreamController();

  Future<int> get numberOfCatches => _app.dataManager.count(_tableName);
  int get numberOfCatchPhotos => 0;

  void createOrUpdate(Catch cat) async {
    _app.dataManager.insertOrUpdateEntity(cat, _tableName,
        controller: _onUpdate);
  }

  Future<List<Catch>> _fetchAll() async {
    var results = await _app.dataManager.query(
        "SELECT * FROM $_tableName ORDER BY ${Catch.keyTimestamp} DESC");
    return results.map((map) => Catch.fromMap(map)).toList();
  }
}

/// A [FutureStreamBuilder] wrapper for listening for [Catch] updates.
class CatchesBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final void Function(List<Catch>) onUpdate;

  CatchesBuilder({
    @required this.builder,
    @required this.onUpdate,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    CatchManager catchManager = CatchManager.of(context);
    return FutureStreamBuilder(
      holder: FutureStreamHolder.single(
        futureCallback: catchManager._fetchAll,
        stream: catchManager._onUpdate.stream,
        onUpdate: (result) => onUpdate(result as List<Catch>),
      ),
      builder: (context) => builder(context),
    );
  }
}