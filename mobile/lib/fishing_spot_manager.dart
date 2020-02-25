import 'package:flutter/cupertino.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/utils/future_stream_builder.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:provider/provider.dart';

class FishingSpotManager {
  static FishingSpotManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).fishingSpotManager;

  static FishingSpotManager _instance;
  factory FishingSpotManager.get(AppManager app) {
    if (_instance == null) {
      _instance = FishingSpotManager._internal(app);
    }
    return _instance;
  }
  FishingSpotManager._internal(AppManager app) : _app = app;

  final String _tableName = "fishing_spot";

  final AppManager _app;
  final VoidStreamController _onUpdateController = VoidStreamController();

  Future<int> numberOfFishingSpots() {
    return _app.dataManager.count(_tableName);
  }

  void createOrUpdate(FishingSpot fishingSpot) async {
    _app.dataManager.insertOrUpdateEntity(fishingSpot, _tableName,
        controller: _onUpdateController);
  }

  void delete(FishingSpot fishingSpot) async {
    _app.dataManager.deleteEntity(fishingSpot, _tableName,
        controller: _onUpdateController);
  }

  /// Queries the database and returns a list of all fishing spots in the log.
  /// If [searchText] is not empty, only fishing spots whose `name` property
  /// includes [searchText] will be returned.
  Future<List<FishingSpot>> _fetchAll({String searchText}) async {
    var results =
        await _app.dataManager.fetchAllEntities(_tableName, searchText: searchText);
    return results.map((map) => FishingSpot.fromMap(map)).toList();
  }

  Future<FishingSpot> fetch({String id}) async {
    return FishingSpot
        .fromMap(await _app.dataManager.fetchEntity(_tableName, id));
  }
}

/// A [FutureStreamBuilder] wrapper for listening for [FishingSpot] updates.
class FishingSpotsBuilder extends StatelessWidget {
  final String searchText;
  final Widget Function(BuildContext) builder;
  final void Function(List<FishingSpot>) onUpdate;

  FishingSpotsBuilder({
    this.searchText,
    @required this.builder,
    @required this.onUpdate,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    FishingSpotManager fishingSpotManager = FishingSpotManager.of(context);
    return FutureStreamBuilder(
      holder: FutureStreamHolder.single(
        futureCallback: () => fishingSpotManager
            ._fetchAll(searchText: searchText),
        stream: fishingSpotManager._onUpdateController.stream,
        onUpdate: (result) => onUpdate(result as List<FishingSpot>),
      ),
      builder: (context) => builder(context),
    );
  }
}