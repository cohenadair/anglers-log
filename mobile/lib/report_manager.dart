import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';

import 'app_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';

class ReportManager extends NamedEntityManager<Report> {
  static ReportManager of(BuildContext context) => AppManager.get.reportManager;

  final _log = const Log("ReportManager");

  ReportManager(super.app);

  @override
  Future<void> initialize() async {
    await super.initialize();

    // TODO: Remove (#683)
    var numberOfChanges = await updateAll(
      where: (report) => !report.hasTimeZone(),
      apply: (report) => addOrUpdate(
        report..timeZone = TimeManager.get.currentTimeZone,
        notify: false,
      ),
    );
    _log.d("Added time zones to $numberOfChanges reports");
  }

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

  /// Returns a list of default, static, reports for the user. These reports
  /// are _not_ included in the underlying entity model.
  List<Report> get defaultReports {
    var result = [
      Report(id: reportIdPersonalBests),
      Report(id: reportIdCatchSummary),
      Report(id: reportIdTripSummary),
    ];

    if (UserPreferenceManager.get.isTrackingSpecies) {
      result.add(Report(id: reportIdSpeciesSummary));
    }

    if (UserPreferenceManager.get.isTrackingAnglers) {
      result.add(Report(id: reportIdAnglerSummary));
    }

    if (UserPreferenceManager.get.isTrackingBaits) {
      result.add(Report(id: reportIdBaitSummary));
    }

    if (UserPreferenceManager.get.isTrackingGear) {
      result.add(Report(id: reportIdGearSummary));
    }

    if (UserPreferenceManager.get.isTrackingFishingSpots) {
      result.add(Report(id: reportIdBodyOfWaterSummary));
      result.add(Report(id: reportIdFishingSpotSummary));
    }

    if (UserPreferenceManager.get.isTrackingMethods) {
      result.add(Report(id: reportIdMethodSummary));
    }

    if (UserPreferenceManager.get.isTrackingMoonPhases) {
      result.add(Report(id: reportIdMoonPhaseSummary));
    }

    if (UserPreferenceManager.get.isTrackingPeriods) {
      result.add(Report(id: reportIdPeriodSummary));
    }

    if (UserPreferenceManager.get.isTrackingSeasons) {
      result.add(Report(id: reportIdSeasonSummary));
    }

    if (UserPreferenceManager.get.isTrackingTides) {
      result.add(Report(id: reportIdTideTypeSummary));
    }

    if (UserPreferenceManager.get.isTrackingWaterClarities) {
      result.add(Report(id: reportIdWaterClaritySummary));
    }

    return result;
  }

  Report get defaultReport => defaultReports.first;
}
