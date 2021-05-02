import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'entity_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';

class ReportManager extends NamedEntityManager<Report> {
  static ReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).reportManager;

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

  @override
  Report entityFromBytes(List<int> bytes) => Report.fromBuffer(bytes);

  @override
  Id id(Report report) => report.id;

  @override
  String name(Report report) => report.name;

  @override
  String get tableName => "custom_report";

  bool removeBait(Report report, Bait bait) => report.baitIds.remove(bait.id);

  bool removeFishingSpot(Report report, FishingSpot fishingSpot) =>
      report.fishingSpotIds.remove(fishingSpot.id);

  bool removeSpecies(Report report, Species species) =>
      report.speciesIds.remove(species.id);

  void _onDeleteBait(Bait bait) async {
    _onEntityDeleted((report) => removeBait(report, bait));
  }

  void _onDeleteFishingSpot(FishingSpot fishingSpot) async {
    _onEntityDeleted((report) => removeFishingSpot(report, fishingSpot));
  }

  void _onDeleteSpecies(Species species) async {
    _onEntityDeleted((report) => removeSpecies(report, species));
  }

  void _onEntityDeleted(bool Function(Report) remove) {
    for (var report in entities.values) {
      if (remove(report)) {
        addOrUpdate(report);
      }
    }
  }
}
