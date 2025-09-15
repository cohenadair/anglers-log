import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/channels/migration_channel.dart';
import 'package:mobile/pages/onboarding/onboarding_migration_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../../mocks/mocks.mocks.dart';
import '../../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("Next button is enabled when migration finishes", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.legacyJsonResult).thenReturn(LegacyJsonResult());
    when(importer.start()).thenAnswer((_) => Future.value());

    await tester.pumpWidget(
      Testable(
        (_) => OnboardingMigrationPage(importer: importer, onNext: (_) {}),
      ),
    );

    expect(findFirstWithText<ActionButton>(tester, "NEXT").onPressed, isNull);
    await tapAndSettle(tester, find.text("START"));
    expect(
      findFirstWithText<ActionButton>(tester, "NEXT").onPressed,
      isNotNull,
    );
  });
}
