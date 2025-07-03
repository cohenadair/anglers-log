import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/translation_warning_page.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("onFinished is called", (tester) async {
    await pumpContext(
        tester, (_) => TranslationWarningPage(onFinished: expectAsync0(() {})));
    await tapAndSettle(tester, find.text("OK"));
  });
}
