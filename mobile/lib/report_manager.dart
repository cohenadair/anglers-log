import 'package:protobuf/protobuf.dart';

import 'app_manager.dart';
import 'entity_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';

abstract class ReportManager<T extends GeneratedMessage>
    extends NamedEntityManager<T> {
  bool removeBait(T report, Bait id);
  bool removeFishingSpot(T report, FishingSpot id);
  bool removeSpecies(T report, Species id);

  ReportManager(AppManager app) : super(app) {
    app.baitManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteBait,
    ));
    app.fishingSpotManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteFishingSpot,
    ));
    app.speciesManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteSpecies,
    ));
  }

  void _onDeleteBait(Bait bait) async {
    _onEntityDeleted((report) => removeBait(report, bait));
  }

  void _onDeleteFishingSpot(FishingSpot fishingSpot) async {
    _onEntityDeleted((report) => removeFishingSpot(report, fishingSpot));
  }

  void _onDeleteSpecies(Species species) async {
    _onEntityDeleted((report) => removeSpecies(report, species));
  }

  void _onEntityDeleted(bool Function(T report) remove) {
    for (var report in entities.values) {
      if (remove(report)) {
        addOrUpdate(report);
      }
    }
  }
}
