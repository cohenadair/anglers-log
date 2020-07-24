import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

/// Manages all reports created by the user.
class CustomReportManager extends NamedEntityManager<CustomReport> {
  static CustomReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).customReportManager;

  CustomReportManager(AppManager app) : super(app);

  @override
  CustomReport entityFromMap(Map<String, dynamic> map) =>
      CustomReport.fromMap(map);

  @override
  String get tableName => "custom_report";
}