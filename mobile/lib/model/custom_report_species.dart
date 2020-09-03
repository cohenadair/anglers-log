import 'package:flutter/material.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/one-to-many-row.dart';
import 'package:mobile/model/species.dart';

/// An object that stores a [CustomReport] ID to [Species] ID pair.
@immutable
class CustomReportSpecies extends OneToManyRow {
  static const keyCustomReportId = "custom_report_id";
  static const keySpeciesId = "species_id";

  CustomReportSpecies({
    @required String customReportId,
    @required String speciesId,
  }) : super(
    firstColumn: keyCustomReportId,
    secondColumn: keySpeciesId,
    firstValue: customReportId,
    secondValue: speciesId,
  );

  CustomReportSpecies.fromMap(Map<String, dynamic> map) : super.fromMap(
    firstColumn: keyCustomReportId,
    secondColumn: keySpeciesId,
    map: map,
  );

  String get customReportId => firstValue;
  String get speciesId => secondValue;
}