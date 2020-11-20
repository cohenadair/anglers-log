import 'package:protobuf/protobuf.dart';

import 'app_manager.dart';
import 'entity_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';

abstract class ReportManager<T extends GeneratedMessage>
    extends NamedEntityManager<T> {
  void onDeleteBait(Bait bait);
  void onDeleteFishingSpot(FishingSpot fishingSpot);
  void onDeleteSpecies(Species species);

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
    onDeleteBait(bait);
    replaceDatabaseWithCache();
    notifyOnAddOrUpdate();
  }

  void _onDeleteFishingSpot(FishingSpot fishingSpot) async {
    onDeleteFishingSpot(fishingSpot);
    replaceDatabaseWithCache();
    notifyOnAddOrUpdate();
  }

  void _onDeleteSpecies(Species species) async {
    onDeleteSpecies(species);
    replaceDatabaseWithCache();
    notifyOnAddOrUpdate();
  }
}
