import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/translation_warning_page.dart';

import '../test_utils.dart';

void main() {
  testWidgets("onFinished is called", (tester) async {
    await pumpContext(
        tester, (_) => TranslationWarningPage(onFinished: expectAsync0(() {})));
    await tapAndSettle(tester, find.text("OK"));
  });
}
