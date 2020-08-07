import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_comparison_report.dart';
import 'package:mobile/utils/date_time_utils.dart';

void main() {
  test("Initialing", () {
    expect(() => CustomComparisonReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      fromDisplayDateRangeId: null,
      toDisplayDateRangeId: null,
    ), throwsAssertionError);

    expect(() => CustomComparisonReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      fromDisplayDateRangeId: "",
      toDisplayDateRangeId: "",
    ), throwsAssertionError);

    expect(() => CustomComparisonReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      fromDisplayDateRangeId: DisplayDateRange.custom.id,
      fromStartTimestamp: 2000,
      fromEndTimestamp: 1000,
      toDisplayDateRangeId: DisplayDateRange.last7Days.id,
    ), throwsAssertionError);

    expect(() => CustomComparisonReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      toDisplayDateRangeId: DisplayDateRange.custom.id,
      toStartTimestamp: 2000,
      toEndTimestamp: 1000,
      fromDisplayDateRangeId: DisplayDateRange.last7Days.id,
    ), throwsAssertionError);

    expect(() => CustomComparisonReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      toDisplayDateRangeId: DisplayDateRange.custom.id,
      toEndTimestamp: 1000,
      fromDisplayDateRangeId: DisplayDateRange.last7Days.id,
    ), throwsAssertionError);

    expect(() => CustomComparisonReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      toDisplayDateRangeId: DisplayDateRange.custom.id,
      toStartTimestamp: 2000,
      fromDisplayDateRangeId: DisplayDateRange.last7Days.id,
    ), throwsAssertionError);

    expect(() => CustomComparisonReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      fromDisplayDateRangeId: DisplayDateRange.custom.id,
      fromEndTimestamp: 1000,
      toDisplayDateRangeId: DisplayDateRange.last7Days.id,
    ), throwsAssertionError);

    expect(() => CustomComparisonReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      fromDisplayDateRangeId: DisplayDateRange.custom.id,
      fromStartTimestamp: 2000,
      toDisplayDateRangeId: DisplayDateRange.last7Days.id,
    ), throwsAssertionError);
  });

  test("Mapping", () {
    var report = CustomComparisonReport(
      name: "Report",
      id: "report_0",
      description: "A test report.",
      entityType: EntityType.bait,
      fromDisplayDateRangeId: DisplayDateRange.last7Days.id,
      toDisplayDateRangeId: DisplayDateRange.thisWeek.id,
    );

    var map = report.toMap();
    expect(map["id"], "report_0");
    expect(map["description"], "A test report.");
    expect(map["entity_type"], 1);
    expect(map["from_display_date_range_id"], "last7Days");
    expect(map["to_display_date_range_id"], "thisWeek");
    expect(map["from_start_timestamp"], isNull);
    expect(map["from_end_timestamp"], isNull);
    expect(map["to_start_timestamp"], isNull);
    expect(map["to_end_timestamp"], isNull);

    report = CustomComparisonReport(
      name: "Report",
      entityType: EntityType.fishCatch,
      fromDisplayDateRangeId: DisplayDateRange.custom.id,
      fromStartTimestamp: 15000,
      fromEndTimestamp: 20000,
      toDisplayDateRangeId: DisplayDateRange.custom.id,
      toStartTimestamp: 5000,
      toEndTimestamp: 10000,
    );

    map = report.toMap();
    expect(map["id"], isNotEmpty);
    expect(map["description"], isNull);
    expect(map["entity_type"], 3);
    expect(map["from_display_date_range_id"], "custom");
    expect(map["to_display_date_range_id"], "custom");
    expect(map["from_start_timestamp"], 15000);
    expect(map["from_end_timestamp"], 20000);
    expect(map["to_start_timestamp"], 5000);
    expect(map["to_end_timestamp"], 10000);

    map = {
      "id": "report_1",
      "description": "A test report 2.",
      "entity_type": 2,
      "from_display_date_range_id" : "custom",
      "to_display_date_range_id" : "custom",
      "from_start_timestamp" : 5000,
      "from_end_timestamp" : 10000,
      "to_start_timestamp" : 15000,
      "to_end_timestamp" : 20000,
    };
    report = CustomComparisonReport.fromMap(map);
    expect(report.id, "report_1");
    expect(report.description, "A test report 2.");
    expect(report.entityType, EntityType.custom);
    expect(report.fromDisplayDateRangeId, "custom");
    expect(report.fromStartTimestamp, 5000);
    expect(report.fromEndTimestamp, 10000);
    expect(report.toDisplayDateRangeId, "custom");
    expect(report.toStartTimestamp, 15000);
    expect(report.toEndTimestamp, 20000);
  });
}