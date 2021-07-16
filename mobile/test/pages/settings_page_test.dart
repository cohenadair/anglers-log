import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  testWidgets("Pro user sets auto fetch atmosphere", (tester) async {
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byType(PaddedCheckbox));

    var result = verify(
        appManager.userPreferenceManager.setAutoFetchAtmosphere(captureAny));
    result.called(1);

    bool autoFetch = result.captured.first;
    expect(autoFetch, isTrue);
  });

  testWidgets("Free user sets auto fetch atmosphere", (tester) async {
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.byType(PaddedCheckbox));

    var result = verify(
        appManager.userPreferenceManager.setAutoFetchAtmosphere(captureAny));
    result.called(1);

    bool autoFetch = result.captured.first;
    expect(autoFetch, isFalse);

    expect(find.byType(ProPage), findsOneWidget);
  });

  testWidgets("User sets auto fetch atmosphere to false", (tester) async {
    when(appManager.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => SettingsPage(),
      appManager: appManager,
    ));

    expect(findFirst<PaddedCheckbox>(tester).checked, isTrue);
    await tapAndSettle(tester, find.byType(PaddedCheckbox));

    var result = verify(
        appManager.userPreferenceManager.setAutoFetchAtmosphere(captureAny));
    result.called(1);

    bool autoFetch = result.captured.first;
    expect(autoFetch, isFalse);

    expect(find.byType(ProPage), findsNothing);
  });
}
