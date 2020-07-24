import 'package:flutter/material.dart';
import 'package:mobile/model/catch_report.dart';
import 'package:mobile/model/one-to-many-row.dart';
import 'package:mobile/model/species.dart';

/// An object that stores a [CatchReport] ID to [Species] ID pair.
@immutable
class CatchReportSpecies extends OneToManyRow {
  static const keyCatchReportId = "catch_report_id";
  static const keySpeciesId = "species_id";

  CatchReportSpecies({
    @required String catchReportId,
    @required String speciesId,
  }) : super(
    firstColumn: keyCatchReportId,
    secondColumn: keySpeciesId,
    firstValue: catchReportId,
    secondValue: speciesId,
  );

  CatchReportSpecies.fromMap(Map<String, dynamic> map) : super.fromMap(
    firstColumn: keyCatchReportId,
    secondColumn: keySpeciesId,
    map: map,
  );

  String get catchReportId => firstValue;
  String get speciesId => secondValue;
}