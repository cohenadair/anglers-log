import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/custom_entity_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  List<CustomEntity> entities = [
    CustomEntity()
      ..id = randomId()
      ..name = "Water Depth"
      ..type = CustomEntity_Type.NUMBER
      ..description = "How deep the water is, in feet.",
    CustomEntity()
      ..id = randomId()
      ..name = "Note"
      ..type = CustomEntity_Type.TEXT,
    CustomEntity()
      ..id = randomId()
      ..name = "Released"
      ..type = CustomEntity_Type.BOOL,
  ];

  setUp(() {
    appManager = MockAppManager(
      mockBaitManager: true,
      mockCatchManager: true,
      mockCustomEntityManager: true,
    );

    when(appManager.mockCustomEntityManager
        .listSortedByName(filter: anyNamed("filter"))).thenReturn(entities);
  });

  testWidgets("CustomEntity description rendered correctly",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable(
      (_) => CustomEntityListPage(),
      appManager: appManager,
    ));
    expect(find.text("How deep the water is, in feet."), findsOneWidget);
    expect(find.text("Water Depth"), findsOneWidget);
    expect(find.text("Note"), findsOneWidget);
    expect(find.text("Released"), findsOneWidget);
  });
}