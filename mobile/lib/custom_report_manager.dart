import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/named_entity_manager.dart';
import 'package:provider/provider.dart';

class CustomReportManager extends NamedEntityManager<CustomReport> {
  static CustomReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).customReportManager;

  CustomReportManager(AppManager app) : super(app);

  @override
  CustomReport entityFromMap(Map<String, dynamic> map) =>
      CustomReport.fromMap(map);

  @override
  String get tableName => "custom_report";

  @override
  int get entityCount => 3;

  @override
  List<CustomReport> entityListSortedByName({String filter}) {
    return [
      CustomReport(name: "Steelhead Summary", id: "2"),
      CustomReport(name: "Walleye Summary", id: "3"),
      CustomReport(name: "Previous Year Comparison", id: "4"),
    ];
  }
}