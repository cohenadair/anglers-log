import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/custom_report_fishing_spot.dart';

void main() {
  test("Mapping", () {
    var fishingSpot = CustomReportFishingSpot(
      customReportId: "catch_report_0",
      fishingSpotId: "fishing_spot_0",
    );

    var map = fishingSpot.toMap();
    expect(map["custom_report_id"], "catch_report_0");
    expect(map["fishing_spot_id"], "fishing_spot_0");

    map = {
      "custom_report_id" : "catch_report_1",
      "fishing_spot_id" : "fishing_spot_1",
    };
    fishingSpot = CustomReportFishingSpot.fromMap(map);
    expect(fishingSpot.customReportId, "catch_report_1");
    expect(fishingSpot.fishingSpotId, "fishing_spot_1");
  });
}