import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/property.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/strings.dart';

class CustomSummaryReport extends CustomReport {
  static const keyDisplayDateRangeId = "display_date_range_id";
  static const keyStartTimestamp = "start_timestamp";
  static const keyEndTimestamp = "end_timestamp";

  static List<Property> _propertyList({
    @required String displayDateRangeId,
    @required int startTimestamp,
    @required int endTimestamp,
  }) => [
    Property<String>(key: keyDisplayDateRangeId, value: displayDateRangeId,
        searchable: false),
    Property<int>(key: keyStartTimestamp, value: startTimestamp,
        searchable: false),
    Property<int>(key: keyEndTimestamp, value: endTimestamp,
        searchable: false),
  ];

  CustomSummaryReport({
    @required String name,
    String id,
    String description,
    @required EntityType entityType,
    @required String displayDateRangeId,
    int startTimestamp,
    int endTimestamp,
  }) : assert(isNotEmpty(name)),
       assert(entityType != null),
       assert(isNotEmpty(displayDateRangeId)),
       assert((startTimestamp == null && endTimestamp == null)
           || (startTimestamp != null && endTimestamp != null
               && startTimestamp <= endTimestamp)),
       assert(displayDateRangeId != DisplayDateRange.custom.id
           || (startTimestamp != null && endTimestamp != null)),
       super(
         properties: _propertyList(
           displayDateRangeId: displayDateRangeId,
           startTimestamp: startTimestamp,
           endTimestamp: endTimestamp,
         ),
         id: id,
         name: name,
         description: description,
         entityType: entityType,
       );

  CustomSummaryReport.fromMap(Map<String, dynamic> map) : super.fromMap(map,
      properties: _propertyList(
        displayDateRangeId: map[keyDisplayDateRangeId],
        startTimestamp: map[keyStartTimestamp],
        endTimestamp: map[keyEndTimestamp],
      ));

  @override
  CustomReportType get type => CustomReportType.summary;

  String get displayDateRangeId =>
      (propertyWithName(keyDisplayDateRangeId) as Property<String>).value;

  int get startTimestamp =>
      (propertyWithName(keyStartTimestamp) as Property<int>).value;

  int get endTimestamp =>
      (propertyWithName(keyEndTimestamp) as Property<int>).value;
}