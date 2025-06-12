import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/about_page.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    var packageInfo = MockPackageInfo();
    when(packageInfo.version).thenReturn("1.0.0");
    when(packageInfo.buildNumber).thenReturn("12345");
    when(appManager.packageInfoWrapper.fromPlatform())
        .thenAnswer((realInvocation) => Future.value(packageInfo));
  });

  testWidgets("English privacy policy", (tester) async {
    when(appManager.ioWrapper.isIOS).thenReturn(false);
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => const AboutPage(),
      appManager: appManager,
      locale: const Locale("en"),
    );

    await tapAndSettle(tester, find.text("Privacy Policy"));

    var result = verify(appManager.urlLauncherWrapper.launch(captureAny));
    result.called(1);

    expect(
      result.captured.first,
      "https://anglerslog.ca/privacy/2.0/privacy-policy.html",
    );
  });

  testWidgets("Non-English privacy policy", (tester) async {
    when(appManager.ioWrapper.isIOS).thenReturn(false);
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => const AboutPage(),
      appManager: appManager,
      locale: const Locale("es"),
    );

    await tapAndSettle(tester, find.text("Política de privacidad"));

    var result = verify(appManager.urlLauncherWrapper.launch(captureAny));
    result.called(1);

    expect(
      result.captured.first,
      "https://anglerslog.ca/privacy/2.0/privacy-policy-es.html",
    );
  });
}
