import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';

/// A pre-defined report that gives an overview of a users log data.
///
/// See:
/// * [OverviewReportView].
class OverviewReport {
  String get id => "overview_report";

  String title(BuildContext context) =>
      Strings.of(context).statsPageReportOverview;

  @override
  bool operator ==(Object other) => other is OverviewReport && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
