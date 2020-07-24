import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/catch_report_bait.dart';

void main() {
  test("Mapping", () {
    var bait = CatchReportBait(
      catchReportId: "catch_report_0",
      baitId: "bait_0",
    );

    var map = bait.toMap();
    expect(map["catch_report_id"], "catch_report_0");
    expect(map["bait_id"], "bait_0");

    map = {
      "catch_report_id" : "catch_report_1",
      "bait_id" : "bait_1",
    };
    bait = CatchReportBait.fromMap(map);
    expect(bait.catchReportId, "catch_report_1");
    expect(bait.baitId, "bait_1");
  });
}