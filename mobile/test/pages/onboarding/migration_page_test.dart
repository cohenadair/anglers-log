import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/migration_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../../test_utils.dart';

void main() {
  testWidgets("Next button is enabled when migration finishes", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.start()).thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable(
      (_) => MigrationPage(
        importer: importer,
        onNext: () {},
      ),
    ));

    expect(findFirstWithText<ActionButton>(tester, "NEXT").onPressed, isNull);
    await tapAndSettle(tester, find.text("START"));
    expect(
        findFirstWithText<ActionButton>(tester, "NEXT").onPressed, isNotNull);
  });
}
