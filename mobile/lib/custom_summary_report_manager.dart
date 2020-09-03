import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/custom_report_manager.dart';
import 'package:mobile/model/custom_summary_report.dart';
import 'package:provider/provider.dart';

class CustomSummaryReportManager extends CustomReportManager {
  static CustomSummaryReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false)
          .customSummaryReportManager;

  static const _tableName = "custom_summary_report";

  CustomSummaryReportManager(AppManager app) : super(app);

  @override
  CustomSummaryReport entityFromMap(Map<String, dynamic> map) =>
      CustomSummaryReport.fromMap(map);

  @override
  String get tableName => _tableName;
}