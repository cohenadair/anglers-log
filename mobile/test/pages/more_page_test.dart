import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/more_page.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
    );

    when(appManager.mockBaitCategoryManager.listSortedByName(
      filter: anyNamed("filter"),
    )).thenReturn([]);
  });

  testWidgets("Page is pushed", (WidgetTester tester) async {
    var observer = MockNavigatorObserver();
    await tester.pumpWidget(Testable(
      (_) => MorePage(),
      navigatorObserver: observer,
      appManager: appManager,
    ));
    // Verify initial navigator push when loading widget.
    verify(observer.didPush(captureAny, any)).called(1);

    await tapAndSettle(tester, find.text("Bait Categories"));

    VerificationResult result = verify(observer.didPush(captureAny, any));
    result.called(1);

    MaterialPageRoute route = result.captured.first;
    expect(route.fullscreenDialog, isFalse);
  });

  testWidgets("Page is presented", (WidgetTester tester) async {
    var observer = MockNavigatorObserver();
    await tester.pumpWidget(Testable(
      (_) => MorePage(),
      navigatorObserver: observer,
      appManager: appManager,
    ));
    // Verify initial navigator push when loading widget.
    verify(observer.didPush(captureAny, any)).called(1);

    await tapAndSettle(tester, find.text("Send Feedback"));

    VerificationResult result = verify(observer.didPush(captureAny, any));
    result.called(1);

    MaterialPageRoute route = result.captured.first;
    expect(route.fullscreenDialog, isTrue);
  });
}
