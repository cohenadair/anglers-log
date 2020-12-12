import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/how_to_manage_fields_page.dart';
import 'package:mockito/mockito.dart';

import '../../mock_app_manager.dart';
import '../../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitManager: true,
      mockBaitCategoryManager: true,
      mockCustomEntityManager: true,
      mockPreferencesManager: true,
      mockSpeciesManager: true,
      mockTimeManager: true,
    );

    when(appManager.mockPreferencesManager.catchCustomEntityIds).thenReturn([]);
  });

  testWidgets("Menu hiding/showing", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => HowToManageFieldsPage(),
        appManager: appManager,
      ),
    );
    // One for title.
    expect(find.text("Manage Fields"), findsOneWidget);

    await tester.pump(Duration(milliseconds: 2000));
    expect(find.text("Manage Fields"), findsNWidgets(2));

    await tester.pump(Duration(milliseconds: 2000));
    expect(find.text("Manage Fields"), findsOneWidget);

    await tester.pump(Duration(milliseconds: 2000));
    expect(find.text("Manage Fields"), findsNWidgets(2));
  });
}
