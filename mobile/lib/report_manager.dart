import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';

class ReportManager extends NamedEntityManager<Report> {
  static ReportManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).reportManager;

  final _log = const Log("ReportManager");

  ReportManager(AppManager app) : super(app);

  TimeManager get _timeManager => appManager.timeManager;

  UserPreferenceManager get _userPreferenceManager =>
      appManager.userPreferenceManager;

  @override
  Future<void> initialize() async {
    await super.initialize();

    // TODO: Remove (#683)
    var numberOfChanges = await updateAll(
      where: (report) => !report.hasTimeZone(),
      apply: (report) => addOrUpdate(
        report..timeZone = _timeManager.currentTimeZone,
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

    if (_userPreferenceManager.isTrackingSpecies) {
      result.add(Report(id: reportIdSpeciesSummary));
    }

    if (_userPreferenceManager.isTrackingAnglers) {
      result.add(Report(id: reportIdAnglerSummary));
    }

    if (_userPreferenceManager.isTrackingBaits) {
      result.add(Report(id: reportIdBaitSummary));
    }

    if (_userPreferenceManager.isTrackingGear) {
      result.add(Report(id: reportIdGearSummary));
    }

    if (_userPreferenceManager.isTrackingFishingSpots) {
      result.add(Report(id: reportIdBodyOfWaterSummary));
      result.add(Report(id: reportIdFishingSpotSummary));
    }

    if (_userPreferenceManager.isTrackingMethods) {
      result.add(Report(id: reportIdMethodSummary));
    }

    if (_userPreferenceManager.isTrackingMoonPhases) {
      result.add(Report(id: reportIdMoonPhaseSummary));
    }

    if (_userPreferenceManager.isTrackingPeriods) {
      result.add(Report(id: reportIdPeriodSummary));
    }

    if (_userPreferenceManager.isTrackingSeasons) {
      result.add(Report(id: reportIdSeasonSummary));
    }

    if (_userPreferenceManager.isTrackingTides) {
      result.add(Report(id: reportIdTideTypeSummary));
    }

    if (_userPreferenceManager.isTrackingWaterClarities) {
      result.add(Report(id: reportIdWaterClaritySummary));
    }

    return result;
  }

  Report get defaultReport => defaultReports.first;
}
