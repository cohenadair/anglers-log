import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/change_log_page.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/stubbed_managers.dart';
import '../../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("Old version shows label", (tester) async {
    when(managers.userPreferenceManager.appVersion).thenReturn("2.0.22");

    await pumpContext(
      tester,
      (_) => ChangeLogPage(onTapContinue: (_) {}),
    );

    expect(find.text("2.1.1"), findsOneWidget);
    expect(find.text("2.0.22 (Your Previous Version)"), findsOneWidget);
  });

  testWidgets("Empty old version shows version only", (tester) async {
    when(managers.userPreferenceManager.appVersion).thenReturn(null);

    await pumpContext(
      tester,
      (_) => ChangeLogPage(onTapContinue: (_) {}),
    );

    expect(find.text("2.1.1"), findsOneWidget);
    expect(find.text("2.0.22"), findsOneWidget);
  });

  testWidgets("Preferences updated when Continue is pressed", (tester) async {
    when(managers.userPreferenceManager.appVersion).thenReturn(null);
    when(managers.userPreferenceManager.updateAppVersion())
        .thenAnswer((_) => Future.value());

    var invoked = false;
    await pumpContext(
      tester,
      (_) => ChangeLogPage(onTapContinue: (_) => invoked = true),
    );

    await tapAndSettle(tester, find.text("CONTINUE"));

    verify(managers.userPreferenceManager.updateAppVersion()).called(1);
    expect(invoked, isTrue);
  });
}
