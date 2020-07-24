import 'package:flutter/material.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/property.dart';
import 'package:quiver/strings.dart';

/// A structure that stores data for a [CustomReport] created for [Catch]
/// objects.
@immutable
class CatchReport extends Entity {
  static const keyCustomReportId = "custom_report_id";
  static const keyDisplayDateRangeId = "display_date_range_id";
  static const keyStartTimestamp = "start_timestamp";
  static const keyEndTimestamp = "end_timestamp";

  static List<Property> _propertyList({
    @required String customReportId,
    @required String displayDateRangeId,
    @required int startTimestamp,
    @required int endTimestamp,
  }) => [
    Property<String>(key: keyCustomReportId, value: customReportId),
    Property<String>(key: keyDisplayDateRangeId, value: displayDateRangeId,
        searchable: false),
    Property<int>(key: keyStartTimestamp, value: startTimestamp,
        searchable: false),
    Property<int>(key: keyEndTimestamp, value: endTimestamp, searchable: false),
  ];

  CatchReport({
    @required String customReportId,
    @required String displayDateRangeId,
    int startTimestamp,
    int endTimestamp,
    String id,
  }) : assert(isNotEmpty(customReportId)),
       assert(isNotEmpty(displayDateRangeId)),
       super(
         properties: _propertyList(
           customReportId: customReportId,
           displayDateRangeId: displayDateRangeId,
           startTimestamp: startTimestamp,
           endTimestamp: endTimestamp,
         ),
         id: id,
       );

  CatchReport.fromMap(Map<String, dynamic> map) : super.fromMap(map,
      properties: _propertyList(
        customReportId: map[keyCustomReportId],
        displayDateRangeId: map[keyDisplayDateRangeId],
        startTimestamp: map[keyStartTimestamp],
        endTimestamp: map[keyEndTimestamp],
      ));

  String get customReportId =>
      (propertyWithName(keyCustomReportId) as Property<String>).value;

  String get displayDateRangeId =>
      (propertyWithName(keyDisplayDateRangeId) as Property<String>).value;

  int get startTimestamp =>
      (propertyWithName(keyStartTimestamp) as Property<int>).value;

  int get endTimestamp =>
      (propertyWithName(keyEndTimestamp) as Property<int>).value;
}