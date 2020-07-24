import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_report.dart';

void main() {
  test("Mapping", () {
    var report = CustomReport(
      name: "Report",
      id: "report_0",
      description: "A test report.",
      type: CustomReportType.summary,
      entityType: EntityType.bait,
    );

    var map = report.toMap();
    expect(map["id"], "report_0");
    expect(map["description"], "A test report.");
    expect(map["type"], 0);
    expect(map["entity_type"], 1);

    map = {
      "id": "report_1",
      "description": "A test report 2.",
      "type": CustomReportType.comparison,
      "entity_type": EntityType.custom,
    };
    report = CustomReport.fromMap(map);
    expect(report.id, "report_1");
    expect(report.description, "A test report 2.");
    expect(report.type, CustomReportType.comparison);
    expect(report.entityType, EntityType.custom);
  });
}