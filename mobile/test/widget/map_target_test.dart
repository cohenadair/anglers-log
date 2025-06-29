import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/map_target.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(managers.userPreferenceManager.mapType).thenReturn(MapType.light.id);
  });

  testWidgets("Defaults to preferences map type", (tester) async {
    await pumpContext(tester, (context) => const MapTarget(),
        managers: managers);
    expect(findFirst<Icon>(tester).color, Colors.black);
  });

  testWidgets("Uses input map type", (tester) async {
    await pumpContext(
      tester,
      (context) => const MapTarget(mapType: MapType.satellite),
      managers: managers,
    );
    expect(findFirst<Icon>(tester).color, Colors.white);
  });
}
