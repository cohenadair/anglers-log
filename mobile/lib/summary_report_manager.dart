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
  String get tableName => "summary_report";

  @override
  bool removeBait(SummaryReport report, Bait bait) =>
      report.baitIds.remove(bait.id);

  @override
  bool removeFishingSpot(SummaryReport report, FishingSpot fishingSpot) =>
      report.fishingSpotIds.remove(fishingSpot.id);

  @override
  bool removeSpecies(SummaryReport report, Species species) =>
      report.speciesIds.remove(species.id);
}
