import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/custom_entity_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

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

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.customEntityManager
            .listSortedByDisplayName(any, filter: anyNamed("filter")))
        .thenReturn(entities);
  });

  testWidgets("CustomEntity description rendered correctly", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const CustomEntityListPage(),
      appManager: appManager,
    ));
    expect(find.text("How deep the water is, in feet."), findsOneWidget);
    expect(find.text("Water Depth"), findsOneWidget);
    expect(find.text("Note"), findsOneWidget);
    expect(find.text("Released"), findsOneWidget);
  });
}
