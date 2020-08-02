import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/custom_report.dart';

class TestCustomReport extends CustomReport {
  TestCustomReport({
    String name,
    String id,
    String description,
    EntityType entityType,
  }) : super(
    name: name,
    id: id,
    description: description,
    entityType: entityType,
  );

  TestCustomReport.fromMap(Map<String, dynamic> map) : super.fromMap(map);

  @override
  CustomReportType get type => CustomReportType.comparison;
}

void main() {
  test("Initializing", () {
    expect(() => TestCustomReport(
      name: "",
      entityType: EntityType.fishCatch,
    ), throwsAssertionError);

    expect(() => TestCustomReport(
      name: "Test",
      entityType: null,
    ), throwsAssertionError);
  });

  test("Mapping", () {
    var report = TestCustomReport(
      name: "Report",
      id: "report_0",
      description: "A test report.",
      entityType: EntityType.bait,
    );

    var map = report.toMap();
    expect(map["id"], "report_0");
    expect(map["description"], "A test report.");
    expect(map["entity_type"], 1);

    report = TestCustomReport(
      name: "Report",
      entityType: EntityType.fishCatch,
    );

    map = report.toMap();
    expect(map["id"], isNotEmpty);
    expect(map["description"], isNull);
    expect(map["entity_type"], 3);

    map = {
      "id": "report_1",
      "description": "A test report 2.",
      "entity_type": EntityType.custom,
    };
    report = TestCustomReport.fromMap(map);
    expect(report.id, "report_1");
    expect(report.description, "A test report 2.");
    expect(report.entityType, EntityType.custom);
  });
}