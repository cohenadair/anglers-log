import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'report_manager.dart';

class SummaryReportManager extends ReportManager<SummaryReport> {
  static SummaryReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).summaryReportManager;

  SummaryReportManager(AppManager app) : super(app);

  @override
  SummaryReport entityFromBytes(List<int> bytes) =>
      SummaryReport.fromBuffer(bytes);

  @override
  Id id(SummaryReport report) => report.id;

  @override
  String name(SummaryReport report) => report.name;

  @override
  void onDeleteBait(Bait bait) {
    for (var report in entities.values) {
      report.baitIds.remove(bait.id);
    }
  }

  @override
  void onDeleteFishingSpot(FishingSpot fishingSpot) {
    for (var report in entities.values) {
      report.fishingSpotIds.remove(fishingSpot.id);
    }
  }

  @override
  void onDeleteSpecies(Species species) {
    for (var report in entities.values) {
      report.speciesIds.remove(species.id);
    }
  }

  @override
  String get tableName => "summary_report";
}
