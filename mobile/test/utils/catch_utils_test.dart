import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/catch_utils.dart';

import '../test_utils.dart';

void main() {
  testWidgets("allCatchFieldsSorted", (tester) async {
    var fields = allCatchFieldsSorted(await buildContext(tester));
    expect(fields[0].id, catchFieldIdBait());
    expect(fields[1].id, catchFieldIdTimestamp());
    expect(fields[2].id, catchFieldIdFishingSpot());
    expect(fields[3].id, catchFieldIdImages());
    expect(fields[4].id, catchFieldIdSpecies());
  });
}