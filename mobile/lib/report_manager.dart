import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';

class ReportManager extends NamedEntityManager<Report> {
  static ReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).reportManager;

  /// IDs for default report types. These IDs should not change as they are
  /// stored in preferences to persist the user's last selected report.
  static final _idPersonalBests =
      Id(uuid: "e364edbe-fee9-4f75-a6a6-92f1a840e157");
  static final _idCatchSummary =
      Id(uuid: "fbcc462b-139e-4a8e-9955-d0fb97071d58");
  static final _idTripSummary =
      Id(uuid: "78201e1d-800b-4c3b-9b62-22082d15cafa");
  static final _idAnglerSummary =
      Id(uuid: "e8d419fc-8545-4bac-9010-641279515b27");
  static final _idBaitSummary =
      Id(uuid: "812ffbc4-78e5-44f6-8c41-eb0c53e7016b");
  static final _idBodyOfWaterSummary =
      Id(uuid: "e385371a-173d-47aa-9b04-7ff15b353dda");
  static final _idFishingSpotSummary =
      Id(uuid: "635490d5-8828-4c72-a8ce-28e601b0c2ce");
  static final _idMethodSummary =
      Id(uuid: "50cca2dc-9cc3-452a-8366-4bc5c781a550");
  static final _idMoonPhaseSummary =
      Id(uuid: "5b24a0c1-1736-4431-8325-33f1c760fc41");
  static final _idPeriodSummary =
      Id(uuid: "ac248a97-d3c5-4de6-9e98-55a75069e64e");
  static final _idSeasonSummary =
      Id(uuid: "46780154-cbf5-4d78-8323-c22c311fd78c");
  static final _idSpeciesSummary =
      Id(uuid: "4466fe5c-f02a-46ad-bea7-cda4d52310a7");
  static final _idTideTypeSummary =
      Id(uuid: "740d3baa-e51f-46dc-a469-c5d64b53cdba");
  static final _idWaterClaritySummary =
      Id(uuid: "2bcb07b5-fa20-4c66-825b-f81a01886913");

  UserPreferenceManager get _userPreferenceManager =>
      appManager.userPreferenceManager;

  ReportManager(AppManager app) : super(app);

  @override
  Report entityFromBytes(List<int> bytes) => Report.fromBuffer(bytes);

  @override
  Id id(Report entity) => entity.id;

  @override
  String name(Report entity) => entity.name;

  @override
  String displayName(BuildContext context, Report entity) =>
      entity.displayName(context) ?? name(entity);

  @override
  String get tableName => "custom_report";

  @override
  Report? entity(Id? id) =>
      defaultReports.firstWhereOrNull((e) => e.id == id) ?? super.entity(id);

  /// Returns a list of default, static, reports for the user.
  List<Report> get defaultReports {
    var result = [
      Report(id: _idPersonalBests, type: Report_Type.personal_bests),
      Report(id: _idCatchSummary, type: Report_Type.catch_summary),
      Report(id: _idTripSummary, type: Report_Type.trip_summary),
    ];

    if (_userPreferenceManager.isTrackingSpecies) {
      result.add(Report(
        id: _idSpeciesSummary,
        type: Report_Type.species_summary,
      ));
    }

    if (_userPreferenceManager.isTrackingAnglers) {
      result.add(Report(
        id: _idAnglerSummary,
        type: Report_Type.angler_summary,
      ));
    }

    if (_userPreferenceManager.isTrackingBaits) {
      result.add(Report(
        id: _idBaitSummary,
        type: Report_Type.bait_summary,
      ));
    }

    result.add(Report(
      id: _idBodyOfWaterSummary,
      type: Report_Type.body_of_water_summary,
    ));

    if (_userPreferenceManager.isTrackingFishingSpots) {
      result.add(Report(
        id: _idFishingSpotSummary,
        type: Report_Type.fishing_spot_summary,
      ));
    }

    if (_userPreferenceManager.isTrackingMethods) {
      result.add(Report(
        id: _idMethodSummary,
        type: Report_Type.method_summary,
      ));
    }

    if (_userPreferenceManager.isTrackingMoonPhases) {
      result.add(Report(
        id: _idMoonPhaseSummary,
        type: Report_Type.moon_phase_summary,
      ));
    }

    if (_userPreferenceManager.isTrackingPeriods) {
      result.add(Report(
        id: _idPeriodSummary,
        type: Report_Type.period_summary,
      ));
    }

    if (_userPreferenceManager.isTrackingSeasons) {
      result.add(Report(
        id: _idSeasonSummary,
        type: Report_Type.season_summary,
      ));
    }

    if (_userPreferenceManager.isTrackingTides) {
      result.add(Report(
        id: _idTideTypeSummary,
        type: Report_Type.tide_summary,
      ));
    }

    if (_userPreferenceManager.isTrackingWaterClarities) {
      result.add(Report(
        id: _idWaterClaritySummary,
        type: Report_Type.water_clarity_summary,
      ));
    }

    return result;
  }

  Report get defaultReport => defaultReports.first;
}
