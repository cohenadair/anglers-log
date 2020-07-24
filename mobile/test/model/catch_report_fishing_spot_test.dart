import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/catch_report_fishing_spot.dart';

void main() {
  test("Mapping", () {
    var fishingSpot = CatchReportFishingSpot(
      catchReportId: "catch_report_0",
      fishingSpotId: "fishing_spot_0",
    );

    var map = fishingSpot.toMap();
    expect(map["catch_report_id"], "catch_report_0");
    expect(map["fishing_spot_id"], "fishing_spot_0");

    map = {
      "catch_report_id" : "catch_report_1",
      "fishing_spot_id" : "fishing_spot_1",
    };
    fishingSpot = CatchReportFishingSpot.fromMap(map);
    expect(fishingSpot.catchReportId, "catch_report_1");
    expect(fishingSpot.fishingSpotId, "fishing_spot_1");
  });
}