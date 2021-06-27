import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import 'gen/anglerslog.pb.dart';

/// A pre-defined report that gives an overview of a users log data.
@immutable
class OverviewReport {
  Id get id => Id()..uuid = "fbcc462b-139e-4a8e-9955-d0fb97071d58";

  String title(BuildContext context) =>
      Strings.of(context).statsPageReportOverview;

  @override
  bool operator ==(Object other) => other is OverviewReport && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
