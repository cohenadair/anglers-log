import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/utils/entity_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("Presenting save page shows ProPage when free", (tester) async {
    when(managers.subscriptionManager.isFree).thenReturn(true);
    when(managers.subscriptionManager.isPro).thenReturn(false);
    when(managers.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () => customFieldsEntitySpec.presentSavePage(context),
      ),
      managers: managers,
    );
    await tapAndSettle(tester, find.text("TEST"));

    expect(find.byType(AnglersLogProPage), findsOneWidget);
    expect(find.byType(SaveCustomEntityPage), findsNothing);
  });

  testWidgets("Presenting save page shows save page when pro", (tester) async {
    when(managers.subscriptionManager.isFree).thenReturn(false);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () => customFieldsEntitySpec.presentSavePage(context),
      ),
      managers: managers,
    );
    await tapAndSettle(tester, find.text("TEST"));

    expect(find.byType(AnglersLogProPage), findsNothing);
    expect(find.byType(SaveCustomEntityPage), findsOneWidget);
  });
}
