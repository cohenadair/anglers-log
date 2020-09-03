import 'package:flutter/material.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/one-to-many-row.dart';

/// An object that stores a [CustomReport] ID to [FishingSpot] ID pair.
@immutable
class CustomReportFishingSpot extends OneToManyRow {
  static const keyCustomReportId = "custom_report_id";
  static const keyFishingSpotId = "fishing_spot_id";

  CustomReportFishingSpot({
    @required String customReportId,
    @required String fishingSpotId,
  }) : super(
    firstColumn: keyCustomReportId,
    secondColumn: keyFishingSpotId,
    firstValue: customReportId,
    secondValue: fishingSpotId,
  );

  CustomReportFishingSpot.fromMap(Map<String, dynamic> map) : super.fromMap(
    firstColumn: keyCustomReportId,
    secondColumn: keyFishingSpotId,
    map: map,
  );

  String get customReportId => firstValue;
  String get fishingSpotId => secondValue;
}