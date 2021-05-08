import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/catch_utils.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  testWidgets("allCatchFieldsSorted", (tester) async {
    var fields = allCatchFieldsSorted(
        await buildContext(tester), StubbedAppManager().timeManager);
    expect(fields[0].id, catchFieldIdAngler());
    expect(fields[1].id, catchFieldIdBait());
    expect(fields[2].id, catchFieldIdCatchAndRelease());
    expect(fields[3].id, catchFieldIdTimestamp());
    expect(fields[4].id, catchFieldIdFavorite());
    expect(fields[5].id, catchFieldIdMethods());
    expect(fields[6].id, catchFieldIdFishingSpot());
    expect(fields[7].id, catchFieldIdImages());
    expect(fields[8].id, catchFieldIdSeason());
    expect(fields[9].id, catchFieldIdSpecies());
    expect(fields[10].id, catchFieldIdPeriod());
    expect(fields[11].id, catchFieldIdWaterClarity());
  });
}
