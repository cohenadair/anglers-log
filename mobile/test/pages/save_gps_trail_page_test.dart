import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_gps_trail_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  testWidgets("No changes copies old values", (tester) async {
    when(appManager.bodyOfWaterManager.displayName(any, any))
        .thenReturn("Lake Huron");
    when(appManager.bodyOfWaterManager.entityExists(any)).thenReturn(false);
    when(appManager.gpsTrailManager.addOrUpdate(any))
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
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.gpsTrailManager.addOrUpdate(captureAny));
    result.called(1);

    expect(trail, result.captured.first);
  });

  testWidgets("Saving without body of water", (tester) async {
    when(appManager.bodyOfWaterManager.displayName(any, any)).thenReturn("");
    when(appManager.bodyOfWaterManager.entityExists(any)).thenReturn(false);
    when(appManager.gpsTrailManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => SaveGpsTrailPage.edit(GpsTrail()),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.gpsTrailManager.addOrUpdate(captureAny));
    result.called(1);

    expect((result.captured.first as GpsTrail).hasBodyOfWaterId(), isFalse);
  });
}
