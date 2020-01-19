import 'package:flutter/cupertino.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/utils/future_listener.dart';
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

  final Log _log = Log("FishingSpotManager");
  final String _tableName = "fishing_spot";

  final AppManager _app;
  final VoidStreamController _onUpdateController = VoidStreamController();

  Future<int> numberOfFishingSpots() {
    return _app.dataManager.count(_tableName);
  }

  Future<bool> exists({String id}) {
    return _app.dataManager
        .exists("SELECT COUNT(*) FROM $_tableName WHERE id = ?", [id]);
  }

  void createOrUpdate(FishingSpot fishingSpot) async {
    if (await exists(id: fishingSpot.id)) {
      // Update if fishing spot with ID already exists.
      if (await _app.dataManager.updateId(
        tableName: _tableName,
        id: fishingSpot.id,
        values: fishingSpot.toMap(),
      )) {
        _onUpdateController.notify();
      } else {
        _log.e("Failed to update FishingSpot(${fishingSpot.id}");
      }
    } else {
      // Otherwise, create new fishing spot.
      if (await _app.dataManager.insert(_tableName, fishingSpot.toMap())) {
        _onUpdateController.notify();
      } else {
        _log.e("Failed to insert FishingSpot(${fishingSpot.id}");
      }
    }
  }

  void remove(FishingSpot fishingSpot) async {
    if (await _app.dataManager
        .delete("DELETE FROM $_tableName WHERE id = ?", [fishingSpot.id]))
    {
      _onUpdateController.notify();
    } else {
      _log.e("Failed to delete FishingSpot(${fishingSpot.id} "
          "from database");
    }
  }

  /// Queries the database and returns a list of all fishing spots in the log.
  Future<List<FishingSpot>> _fetchAll() async {
    return (await _app.dataManager.query("SELECT * FROM $_tableName"))
        .map((map) => FishingSpot.fromMap(map)).toList();
  }

  Future<FishingSpot> fetch({String id}) async {
    List<Map<String, dynamic>> result = await _app.dataManager
        .query("SELECT * FROM $_tableName WHERE id = ?", [id]);
    if (result.isEmpty) {
      return null;
    }
    return FishingSpot.fromMap(result.first);
  }
}

/// A [FutureListener] wrapper for listening for [FishingSpot] updates.
class FishingSpotsBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final void Function(List<FishingSpot>) onUpdate;

  FishingSpotsBuilder({
    @required this.builder,
    @required this.onUpdate,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    FishingSpotManager fishingSpotManager = FishingSpotManager.of(context);
    return FutureListener.single(
      future: fishingSpotManager._fetchAll,
      stream: fishingSpotManager._onUpdateController.stream,
      builder: (context) => builder(context),
      onUpdate: (dynamic result) => onUpdate(result as List<FishingSpot>),
    );
  }
}