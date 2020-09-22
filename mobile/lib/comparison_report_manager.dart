import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/report_manager.dart';
import 'package:provider/provider.dart';

class ComparisonReportManager extends ReportManager<ComparisonReport> {
  static ComparisonReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false)
          .customComparisonReportManager;

  ComparisonReportManager(AppManager app) : super(app);

  @override
  ComparisonReport entityFromBytes(List<int> bytes) =>
      ComparisonReport.fromBuffer(bytes);

  @override
  Id id(ComparisonReport report) => report.id;

  @override
  String name(ComparisonReport report) => report.name;

  @override
  void onDeleteBait(Bait bait) => entities.values
      .forEach((report) => report.baitIds.remove(bait.id));

  @override
  void onDeleteFishingSpot(FishingSpot fishingSpot) => entities.values
      .forEach((report) => report.baitIds.remove(fishingSpot.id));

  @override
  void onDeleteSpecies(Species species) => entities.values
      .forEach((report) => report.baitIds.remove(species.id));

  @override
  String get tableName => "custom_comparison_report";
}