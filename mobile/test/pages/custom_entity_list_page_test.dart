import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/custom_entity_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  var entities = <CustomEntity>[
    CustomEntity()
      ..id = randomId()
      ..name = "Water Depth"
      ..type = CustomEntity_Type.number
      ..description = "How deep the water is, in feet.",
    CustomEntity()
      ..id = randomId()
      ..name = "Note"
      ..type = CustomEntity_Type.text,
    CustomEntity()
      ..id = randomId()
      ..name = "Released"
      ..type = CustomEntity_Type.boolean,
  ];

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.customEntityManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(entities);
  });

  testWidgets("CustomEntity description rendered correctly", (tester) async {
    await tester.pumpWidget(Testable((_) => const CustomEntityListPage()));
    expect(find.text("How deep the water is, in feet."), findsOneWidget);
    expect(find.text("Water Depth"), findsOneWidget);
    expect(find.text("Note"), findsOneWidget);
    expect(find.text("Released"), findsOneWidget);
  });

  testWidgets("Delete message includes all entity counts", (tester) async {
    when(managers.catchManager.numberOfCustomEntityValues(any)).thenReturn(1);
    when(managers.baitManager.numberOfCustomEntityValues(any)).thenReturn(2);
    when(managers.tripManager.numberOfCustomEntityValues(any)).thenReturn(3);
    when(managers.gearManager.numberOfCustomEntityValues(any)).thenReturn(4);

    await pumpContext(tester, (_) => const CustomEntityListPage());
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
    await tapAndSettle(tester, find.byIcon(Icons.delete).first);

    expect(
      find.text(
        "The custom field Water Depth will no longer be associated with catches (1), baits (2), trips (3) or gear (4), are you sure you want to delete it? This cannot be undone.",
      ),
      findsOneWidget,
    );
  });
}
