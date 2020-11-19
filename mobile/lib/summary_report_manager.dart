import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:provider/provider.dart';

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
  void onDeleteBait(Bait bait) =>
      entities.values.forEach((report) => report.baitIds.remove(bait.id));

  @override
  void onDeleteFishingSpot(FishingSpot fishingSpot) => entities.values
      .forEach((report) => report.fishingSpotIds.remove(fishingSpot.id));

  @override
  void onDeleteSpecies(Species species) =>
      entities.values.forEach((report) => report.speciesIds.remove(species.id));

  @override
  String get tableName => "summary_report";
}
