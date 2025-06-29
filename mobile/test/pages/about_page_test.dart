import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/about_page.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    var packageInfo = MockPackageInfo();
    when(packageInfo.version).thenReturn("1.0.0");
    when(packageInfo.buildNumber).thenReturn("12345");
    when(managers.packageInfoWrapper.fromPlatform())
        .thenAnswer((realInvocation) => Future.value(packageInfo));
  });

  testWidgets("English privacy policy", (tester) async {
    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(managers.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => const AboutPage(),
      managers: managers,
      locale: const Locale("en"),
    );

    await tapAndSettle(tester, find.text("Privacy Policy"));

    var result = verify(managers.urlLauncherWrapper.launch(captureAny));
    result.called(1);

    expect(
      result.captured.first,
      "https://anglerslog.ca/privacy/2.0/privacy-policy.html",
    );
  });

  testWidgets("Non-English privacy policy", (tester) async {
    when(managers.ioWrapper.isIOS).thenReturn(false);
    when(managers.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(
      tester,
      (_) => const AboutPage(),
      managers: managers,
      locale: const Locale("es"),
    );

    await tapAndSettle(tester, find.text("Política de privacidad"));

    var result = verify(managers.urlLauncherWrapper.launch(captureAny));
    result.called(1);

    expect(
      result.captured.first,
      "https://anglerslog.ca/privacy/2.0/privacy-policy-es.html",
    );
  });
}
