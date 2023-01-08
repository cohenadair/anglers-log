import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/gps_trail_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  testWidgets("GpsTrailListItemModel shows in progress label", (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn(null);
    when(appManager.gpsTrailManager.displayName(any, any)).thenReturn("");

    var context = await buildContext(tester, appManager: appManager);
    var model = GpsTrailListItemModel(
      context,
      GpsTrail(
        startTimestamp: Int64(50000),
      ),
    );

    expect(model.subtitle, "In Progress");
  });

  testWidgets("GpsTrailListItemModel normal case", (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn("Lake Huron");
    when(appManager.gpsTrailManager.displayName(any, any))
        .thenReturn("GPS Trail");

    var context = await buildContext(tester, appManager: appManager);
    var model = GpsTrailListItemModel(context,
        GpsTrail(startTimestamp: Int64(50000), endTimestamp: Int64(500000)));

    expect(model.title, "GPS Trail");
    expect(model.subtitle, "Lake Huron");
    expect((model.trailing as MinChip).label, "0 Points");
  });
}
