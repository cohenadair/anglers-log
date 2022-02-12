import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/utils/entity_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  testWidgets("Presenting save page shows ProPage when free", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () => customFieldsEntitySpec.presentSavePage(context),
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("TEST"));

    expect(find.byType(ProPage), findsOneWidget);
    expect(find.byType(SaveCustomEntityPage), findsNothing);
  });

  testWidgets("Presenting save page shows save page when pro", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(false);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () => customFieldsEntitySpec.presentSavePage(context),
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("TEST"));

    expect(find.byType(ProPage), findsNothing);
    expect(find.byType(SaveCustomEntityPage), findsOneWidget);
  });
}
