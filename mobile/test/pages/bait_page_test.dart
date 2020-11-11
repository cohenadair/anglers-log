import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
      mockBaitManager: true,
    );

    when(appManager.mockBaitManager.entity(any)).thenReturn(Bait()
      ..id = randomId()
      ..name = "Countdown Brown Trout");
  });

  testWidgets("Null bait category renders empty", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitPage(randomId()),
      appManager: appManager,
    ));
    expect(find.byType(HeadingLabel), findsNothing);
  });

  testWidgets("Non-null bait category", (WidgetTester tester) async {
    when(appManager.mockBaitCategoryManager.entity(any))
        .thenReturn(BaitCategory()
      ..id = randomId()
      ..name = "Rapala");
    await tester.pumpWidget(Testable(
      (_) => BaitPage(randomId()),
      appManager: appManager,
    ));

    expect(find.byType(HeadingLabel), findsOneWidget);
    expect(find.text("Rapala"), findsOneWidget);
    expect(find.text("Countdown Brown Trout"), findsOneWidget);
  });
}