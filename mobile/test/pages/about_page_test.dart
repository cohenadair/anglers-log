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
    when(appManager.packageInfoWrapper.fromPlatform())
        .thenAnswer((realInvocation) => Future.value(packageInfo));
  });

  testWidgets("Apple EULA shown", (tester) async {
    when(appManager.ioWrapper.isIOS).thenReturn(true);

    await pumpContext(
      tester,
      (_) => const AboutPage(),
      appManager: appManager,
    );

    expect(find.text("Terms of Use (EULA)"), findsOneWidget);
  });

  testWidgets("Apple EULA hidden", (tester) async {
    when(appManager.ioWrapper.isIOS).thenReturn(false);

    await pumpContext(
      tester,
      (_) => const AboutPage(),
      appManager: appManager,
    );

    expect(find.text("Terms of Use (EULA)"), findsNothing);
  });
}
