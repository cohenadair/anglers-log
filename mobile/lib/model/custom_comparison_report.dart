import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/property.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/strings.dart';

class CustomComparisonReport extends CustomReport {
  static const keyFromDisplayDateRangeId = "from_display_date_range_id";
  static const keyFromStartTimestamp = "from_start_timestamp";
  static const keyFromEndTimestamp = "from_end_timestamp";
  static const keyToDisplayDateRangeId = "to_display_date_range_id";
  static const keyToStartTimestamp = "to_start_timestamp";
  static const keyToEndTimestamp = "to_end_timestamp";

  static List<Property> _propertyList({
    @required String fromDisplayDateRangeId,
    @required int fromStartTimestamp,
    @required int fromEndTimestamp,
    @required String toDisplayDateRangeId,
    @required int toStartTimestamp,
    @required int toEndTimestamp,
  }) => [
    Property<String>(key: keyFromDisplayDateRangeId, value: fromDisplayDateRangeId,
        searchable: false),
    Property<int>(key: keyFromStartTimestamp, value: fromStartTimestamp,
        searchable: false),
    Property<int>(key: keyFromEndTimestamp, value: fromEndTimestamp,
        searchable: false),
    Property<String>(key: keyToDisplayDateRangeId, value: toDisplayDateRangeId,
        searchable: false),
    Property<int>(key: keyToStartTimestamp, value: toStartTimestamp,
        searchable: false),
    Property<int>(key: keyToEndTimestamp, value: toEndTimestamp,
        searchable: false),
  ];

  CustomComparisonReport({
    @required String name,
    String id,
    String description,
    @required EntityType entityType,
    @required String fromDisplayDateRangeId,
    int fromStartTimestamp,
    int fromEndTimestamp,
    @required String toDisplayDateRangeId,
    int toStartTimestamp,
    int toEndTimestamp,
  }) : assert(isNotEmpty(name)),
       assert(entityType != null),
       assert(isNotEmpty(fromDisplayDateRangeId)),
       assert(isNotEmpty(toDisplayDateRangeId)),
       assert((fromStartTimestamp == null && fromEndTimestamp == null)
           || (fromStartTimestamp != null && fromEndTimestamp != null
               && fromStartTimestamp <= fromEndTimestamp)),
       assert((toStartTimestamp == null && toEndTimestamp == null)
           || (toStartTimestamp != null && toEndTimestamp != null
               && toStartTimestamp <= toEndTimestamp)),
       assert(fromDisplayDateRangeId != DisplayDateRange.custom.id
           || (fromStartTimestamp != null && fromEndTimestamp != null)),
       assert(toDisplayDateRangeId != DisplayDateRange.custom.id
           || (toStartTimestamp != null && toEndTimestamp != null)),
       super(
         properties: _propertyList(
           fromDisplayDateRangeId: fromDisplayDateRangeId,
           fromStartTimestamp: fromStartTimestamp,
           fromEndTimestamp: fromEndTimestamp,
           toDisplayDateRangeId: toDisplayDateRangeId,
           toStartTimestamp: toStartTimestamp,
           toEndTimestamp: toEndTimestamp,
         ),
         id: id,
         name: name,
         description: description,
         entityType: entityType,
       );

  CustomComparisonReport.fromMap(Map<String, dynamic> map) : super.fromMap(map,
      properties: _propertyList(
        fromDisplayDateRangeId: map[keyFromDisplayDateRangeId],
        fromStartTimestamp: map[keyFromStartTimestamp],
        fromEndTimestamp: map[keyFromEndTimestamp],
        toDisplayDateRangeId: map[keyToDisplayDateRangeId],
        toStartTimestamp: map[keyToStartTimestamp],
        toEndTimestamp: map[keyToEndTimestamp],
      ));

  @override
  CustomReportType get type => CustomReportType.comparison;

  String get fromDisplayDateRangeId =>
      (propertyWithName(keyFromDisplayDateRangeId) as Property<String>).value;

  int get fromStartTimestamp =>
      (propertyWithName(keyFromStartTimestamp) as Property<int>).value;

  int get fromEndTimestamp =>
      (propertyWithName(keyFromEndTimestamp) as Property<int>).value;

  String get toDisplayDateRangeId =>
      (propertyWithName(keyToDisplayDateRangeId) as Property<String>).value;

  int get toStartTimestamp =>
      (propertyWithName(keyToStartTimestamp) as Property<int>).value;

  int get toEndTimestamp =>
      (propertyWithName(keyToEndTimestamp) as Property<int>).value;
}