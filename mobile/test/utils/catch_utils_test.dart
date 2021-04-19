import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/catch_utils.dart';

import '../test_utils.dart';

void main() {
  testWidgets("allCatchFieldsSorted", (tester) async {
    var fields = allCatchFieldsSorted(await buildContext(tester));
    expect(fields[0].id, catchFieldIdAngler());
    expect(fields[1].id, catchFieldIdBait());
    expect(fields[2].id, catchFieldIdTimestamp());
    expect(fields[3].id, catchFieldIdMethods());
    expect(fields[4].id, catchFieldIdFishingSpot());
    expect(fields[5].id, catchFieldIdImages());
    expect(fields[6].id, catchFieldIdSpecies());
    expect(fields[7].id, catchFieldIdPeriod());
  });
}
