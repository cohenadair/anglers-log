import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_summary_report.dart';
import 'package:mobile/utils/date_time_utils.dart';

void main() {
  test("Initializing", () {
    expect(() => CustomSummaryReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      displayDateRangeId: null,
    ), throwsAssertionError);

    expect(() => CustomSummaryReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      displayDateRangeId: "",
    ), throwsAssertionError);

    expect(() => CustomSummaryReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      displayDateRangeId: DisplayDateRange.last7Days.id,
      startTimestamp: 1000,
    ), throwsAssertionError);

    expect(() => CustomSummaryReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      displayDateRangeId: DisplayDateRange.last7Days.id,
      endTimestamp: 1000,
    ), throwsAssertionError);

    expect(() => CustomSummaryReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      displayDateRangeId: DisplayDateRange.custom.id,
    ), throwsAssertionError);

    expect(() => CustomSummaryReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      displayDateRangeId: DisplayDateRange.custom.id,
      startTimestamp: 0,
    ), throwsAssertionError);

    expect(() => CustomSummaryReport(
      name: "Test",
      entityType: EntityType.fishCatch,
      displayDateRangeId: DisplayDateRange.custom.id,
      endTimestamp: 1000,
    ), throwsAssertionError);
  });

  test("Mapping", () {
    var report = CustomSummaryReport(
      name: "Report",
      id: "report_0",
      description: "A test report.",
      entityType: EntityType.bait,
      displayDateRangeId: DisplayDateRange.last7Days.id,
    );

    var map = report.toMap();
    expect(map["id"], "report_0");
    expect(map["description"], "A test report.");
    expect(map["entity_type"], 1);
    expect(map["display_date_range_id"], "last7Days");

    report = CustomSummaryReport(
      name: "Report",
      entityType: EntityType.fishCatch,
      displayDateRangeId: DisplayDateRange.custom.id,
      startTimestamp: 1000,
      endTimestamp: 2000,
    );

    map = report.toMap();
    expect(map["id"], isNotEmpty);
    expect(map["description"], isNull);
    expect(map["entity_type"], 3);
    expect(map["display_date_range_id"], "custom");
    expect(map["start_timestamp"], 1000);
    expect(map["end_timestamp"], 2000);

    map = {
      "id": "report_1",
      "description": "A test report 2.",
      "entity_type": 2,
      "display_date_range_id": "custom",
      "start_timestamp": 5000,
      "end_timestamp": 10000,
    };
    report = CustomSummaryReport.fromMap(map);
    expect(report.id, "report_1");
    expect(report.description, "A test report 2.");
    expect(report.entityType, EntityType.custom);
    expect(report.displayDateRangeId, "custom");
    expect(report.startTimestamp, 5000);
    expect(report.endTimestamp, 10000);
  });
}