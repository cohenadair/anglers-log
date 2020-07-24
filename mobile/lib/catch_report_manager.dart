import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/catch_report.dart';
import 'package:provider/provider.dart';

/// Manages catch reports created by the user.
class CatchReportManager extends EntityManager<CatchReport> {
  static CatchReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).catchReportManager;

  static const _tableNameCatchReport = "catch_report";
  static const _tableNameBait = "catch_report_bait";
  static const _tableNameFishingSpot = "catch_report_fishing_spot";
  static const _tableNameSpecies = "catch_report_species";

  CatchReportManager(AppManager app) : super(app);

  @override
  CatchReport entityFromMap(Map<String, dynamic> map) =>
      CatchReport.fromMap(map);

  @override
  String get tableName => _tableNameCatchReport;
}