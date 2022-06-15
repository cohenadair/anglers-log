import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/change_log_page.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../mocks/stubbed_app_manager.dart';
import '../../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  testWidgets("Old version shows label", (tester) async {
    when(appManager.userPreferenceManager.appVersion).thenReturn("2.0.22");

    await pumpContext(
      tester,
      (_) => ChangeLogPage(onTapContinue: () {}),
      appManager: appManager,
    );

    expect(find.text("2.1.1"), findsOneWidget);
    expect(find.text("2.0.22 (Your Previous Version)"), findsOneWidget);
  });

  testWidgets("Empty old version shows version only", (tester) async {
    when(appManager.userPreferenceManager.appVersion).thenReturn(null);

    await pumpContext(
      tester,
      (_) => ChangeLogPage(onTapContinue: () {}),
      appManager: appManager,
    );

    expect(find.text("2.1.1"), findsOneWidget);
    expect(find.text("2.0.22"), findsOneWidget);
  });

  testWidgets("Preferences updated when Continue is pressed", (tester) async {
    when(appManager.userPreferenceManager.appVersion).thenReturn(null);
    when(appManager.userPreferenceManager.setAppVersion(any))
        .thenAnswer((_) => Future.value());
    when(appManager.packageInfoWrapper.fromPlatform()).thenAnswer(
      (_) => Future.value(
        PackageInfo(
          buildNumber: "5",
          appName: "Test",
          version: "2.1.0",
          packageName: "test.com",
        ),
      ),
    );

    var invoked = false;
    await pumpContext(
      tester,
      (_) => ChangeLogPage(onTapContinue: () => invoked = true),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("CONTINUE"));

    var result =
        verify(appManager.userPreferenceManager.setAppVersion(captureAny));
    result.called(1);
    expect(result.captured.first as String, "2.1.0");
    expect(invoked, isTrue);
  });
}
