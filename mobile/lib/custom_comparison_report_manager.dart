import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/custom_report_manager.dart';
import 'package:mobile/model/custom_comparison_report.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:provider/provider.dart';

class CustomComparisonReportManager extends CustomReportManager {
  static CustomComparisonReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false)
          .customComparisonReportManager;

  static const _tableName = "custom_comparison_report";

  CustomComparisonReportManager(AppManager app) : super(app);

  @override
  CustomReport entityFromMap(Map<String, dynamic> map) =>
      CustomComparisonReport.fromMap(map);

  @override
  String get tableName => _tableName;
}