import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/translation_warning_page.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("onFinished is called", (tester) async {
    await pumpContext(
      tester,
      (_) => TranslationWarningPage(onFinished: expectAsync0(() {})),
    );
    await tapAndSettle(tester, find.text("OK"));
  });
}
