import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'report_manager.dart';

class ComparisonReportManager extends ReportManager<ComparisonReport> {
  static ComparisonReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).comparisonReportManager;

  ComparisonReportManager(AppManager app) : super(app);

  @override
  ComparisonReport entityFromBytes(List<int> bytes) =>
      ComparisonReport.fromBuffer(bytes);

  @override
  Id id(ComparisonReport report) => report.id;

  @override
  String name(ComparisonReport report) => report.name;

  @override
  String get tableName => "comparison_report";

  @override
  bool removeBait(ComparisonReport report, Bait bait) =>
      report.baitIds.remove(bait.id);

  @override
  bool removeFishingSpot(ComparisonReport report, FishingSpot fishingSpot) =>
      report.fishingSpotIds.remove(fishingSpot.id);

  @override
  bool removeSpecies(ComparisonReport report, Species species) =>
      report.speciesIds.remove(species.id);
}
