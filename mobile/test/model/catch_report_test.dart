import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/catch_report.dart';

void main() {
  test("Mapping", () {
    var report = CatchReport(
      id: "id0",
      customReportId: "report_0",
      displayDateRangeId: "date_range_0",
      startTimestamp: 0,
      endTimestamp: 5000,
    );

    var map = report.toMap();
    expect(map["id"], "id0");
    expect(map["custom_report_id"], "report_0");
    expect(map["display_date_range_id"], "date_range_0");
    expect(map["start_timestamp"], 0);
    expect(map["end_timestamp"], 5000);

    map = {
      "id": "id1",
      "custom_report_id": "report_1",
      "display_date_range_id": "date_range_1",
      "start_timestamp": 10000,
      "end_timestamp": 15000,
    };
    report = CatchReport.fromMap(map);
    expect(report.id, "id1");
    expect(report.customReportId, "report_1");
    expect(report.displayDateRangeId, "date_range_1");
    expect(report.startTimestamp, 10000);
    expect(report.endTimestamp, 15000);
  });
}