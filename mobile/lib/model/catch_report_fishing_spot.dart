import 'package:flutter/material.dart';
import 'package:mobile/model/catch_report.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/one-to-many-row.dart';

/// An object that stores a [CatchReport] ID to [FishingSpot] ID pair.
@immutable
class CatchReportFishingSpot extends OneToManyRow {
  static const keyCatchReportId = "catch_report_id";
  static const keyFishingSpotId = "fishing_spot_id";

  CatchReportFishingSpot({
    @required String catchReportId,
    @required String fishingSpotId,
  }) : super(
    firstColumn: keyCatchReportId,
    secondColumn: keyFishingSpotId,
    firstValue: catchReportId,
    secondValue: fishingSpotId,
  );

  CatchReportFishingSpot.fromMap(Map<String, dynamic> map) : super.fromMap(
    firstColumn: keyCatchReportId,
    secondColumn: keyFishingSpotId,
    map: map,
  );

  String get catchReportId => firstValue;
  String get fishingSpotId => secondValue;
}