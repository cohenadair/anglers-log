import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/report.dart';

/// A pre-defined report that gives an overview of a users log data.
///
/// See:
/// * [OverviewReportView].
class OverviewReport implements Report {
  @override
  String get id => "overview_report";

  @override
  String title(BuildContext context) =>
      Strings.of(context).statsPageReportOverview;

  @override
  bool get custom => false;

  @override
  bool operator ==(Object other) => other is OverviewReport && id == other.id;

  @override
  int get hashCode => id.hashCode;
}