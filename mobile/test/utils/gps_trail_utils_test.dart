import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/gps_trail_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("GpsTrailListItemModel shows in progress label", (tester) async {
    when(
      managers.bodyOfWaterManager.displayNameFromId(any, any),
    ).thenReturn(null);
    when(managers.gpsTrailManager.displayName(any, any)).thenReturn("");

    var context = await buildContext(tester);
    var model = GpsTrailListItemModel(
      context,
      GpsTrail(startTimestamp: Int64(50000)),
    );

    expect(model.subtitle, "In Progress");
  });

  testWidgets("GpsTrailListItemModel normal case", (tester) async {
    when(
      managers.bodyOfWaterManager.displayNameFromId(any, any),
    ).thenReturn("Lake Huron");
    when(
      managers.gpsTrailManager.displayName(any, any),
    ).thenReturn("GPS Trail");

    var context = await buildContext(tester);
    var model = GpsTrailListItemModel(
      context,
      GpsTrail(startTimestamp: Int64(50000), endTimestamp: Int64(500000)),
    );

    expect(model.title, "GPS Trail");
    expect(model.subtitle, "Lake Huron");
    expect((model.trailing as MinChip).label, "0 Points");
  });
}
