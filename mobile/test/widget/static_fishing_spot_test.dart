import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/static_fishing_spot.dart';

import '../test_utils.dart';

main() {
  testWidgets("Fishing spot marker is shown", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => StaticFishingSpot(
      FishingSpot()
        ..id = randomId()
        ..lat = 1.234567
        ..lng = 2.345678,
    )));
    await tester.pumpAndSettle();
    expect(findFirst<GoogleMap>(tester).markers.length, 1);
  });
}