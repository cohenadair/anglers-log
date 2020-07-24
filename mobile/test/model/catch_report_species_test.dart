import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/catch_report_species.dart';

void main() {
  test("Mapping", () {
    var species = CatchReportSpecies(
      catchReportId: "catch_report_0",
      speciesId: "species_0",
    );

    var map = species.toMap();
    expect(map["catch_report_id"], "catch_report_0");
    expect(map["species_id"], "species_0");

    map = {
      "catch_report_id" : "catch_report_1",
      "species_id" : "species_1",
    };
    species = CatchReportSpecies.fromMap(map);
    expect(species.catchReportId, "catch_report_1");
    expect(species.speciesId, "species_1");
  });
}