import 'package:flutter/material.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/one-to-many-row.dart';

/// An object that stores a [CustomReport] ID to [Bait] ID pair.
@immutable
class CustomReportBait extends OneToManyRow {
  static const keyCustomReportId = "catch_report_id";
  static const keyBaitId = "bait_id";

  CustomReportBait({
    @required String customReportId,
    @required String baitId,
  }) : super(
    firstColumn: keyCustomReportId,
    secondColumn: keyBaitId,
    firstValue: customReportId,
    secondValue: baitId,
  );

  CustomReportBait.fromMap(Map<String, dynamic> map) : super.fromMap(
    firstColumn: keyCustomReportId,
    secondColumn: keyBaitId,
    map: map,
  );

  String get customReportId => firstValue;
  String get baitId => secondValue;
}