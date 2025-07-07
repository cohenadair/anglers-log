import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/save_gps_trail_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("No changes copies old values", (tester) async {
    when(managers.bodyOfWaterManager.displayName(any, any))
        .thenReturn("Lake Huron");
    when(managers.bodyOfWaterManager.entityExists(any)).thenReturn(false);
    when(managers.gpsTrailManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    var trail = GpsTrail(
      points: [
        GpsTrailPoint(),
        GpsTrailPoint(),
        GpsTrailPoint(),
      ],
      bodyOfWaterId: randomId(),
    );

    await pumpContext(
      tester,
      (_) => SaveGpsTrailPage.edit(trail),
    );
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.gpsTrailManager.addOrUpdate(captureAny));
    result.called(1);

    expect(trail, result.captured.first);
  });

  testWidgets("Saving without body of water", (tester) async {
    when(managers.bodyOfWaterManager.displayName(any, any)).thenReturn("");
    when(managers.bodyOfWaterManager.entityExists(any)).thenReturn(false);
    when(managers.gpsTrailManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => SaveGpsTrailPage.edit(GpsTrail()),
    );
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(managers.gpsTrailManager.addOrUpdate(captureAny));
    result.called(1);

    expect((result.captured.first as GpsTrail).hasBodyOfWaterId(), isFalse);
  });
}
