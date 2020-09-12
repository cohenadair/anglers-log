import 'package:mobile/app_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:protobuf/protobuf.dart';

abstract class ReportManager<T extends GeneratedMessage>
    extends NamedEntityManager<T>
{
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