import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitManager.deleteMessage(any, any)).thenReturn("Delete");
    when(appManager.baitManager.entity(any)).thenReturn(Bait()
      ..id = randomId()
      ..name = "Countdown Brown Trout");
  });

  testWidgets("Null bait category renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitPage(Bait()),
      appManager: appManager,
    ));
    expect(find.byType(HeadingLabel), findsNothing);
  });

  testWidgets("Non-null bait category", (tester) async {
    when(appManager.baitCategoryManager.entity(any)).thenReturn(
      BaitCategory()
        ..id = randomId()
        ..name = "Rapala",
    );
    await tester.pumpWidget(Testable(
      (_) => BaitPage(Bait()),
      appManager: appManager,
    ));

    expect(find.byType(HeadingLabel), findsOneWidget);
    expect(find.text("Rapala"), findsOneWidget);
    expect(find.text("Countdown Brown Trout"), findsOneWidget);
  });
}
