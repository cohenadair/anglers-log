import 'package:flutter/material.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch_report.dart';
import 'package:mobile/model/one-to-many-row.dart';

/// An object that stores a [CatchReport] ID to [Bait] ID pair.
@immutable
class CatchReportBait extends OneToManyRow {
  static const keyCatchReportId = "catch_report_id";
  static const keyBaitId = "bait_id";

  CatchReportBait({
    @required String catchReportId,
    @required String baitId,
  }) : super(
    firstColumn: keyCatchReportId,
    secondColumn: keyBaitId,
    firstValue: catchReportId,
    secondValue: baitId,
  );

  CatchReportBait.fromMap(Map<String, dynamic> map) : super.fromMap(
    firstColumn: keyCatchReportId,
    secondColumn: keyBaitId,
    map: map,
  );

  String get catchReportId => firstValue;
  String get baitId => secondValue;
}