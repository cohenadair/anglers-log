import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/pages/more_page.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitCategoryManager.listSortedByName(
      filter: anyNamed("filter"),
    )).thenReturn([]);
  });

  testWidgets("Page is pushed", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MorePage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.byType(BaitCategoryListPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets("Page is presented", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MorePage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Send Feedback"));

    expect(find.byType(FeedbackPage), findsOneWidget);
    expect(find.byType(CloseButton), findsOneWidget);
  });

  testWidgets("Custom onTap", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MorePage(),
      appManager: appManager,
    ));

    when(appManager.urlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));
    await tapAndSettle(tester, find.text("Rate Anglers' Log"));
    verify(appManager.urlLauncherWrapper.launch(any)).called(1);
  });

  testWidgets("Rate and feedback are not highlighted", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MorePage(),
      appManager: appManager,
    ));

    expect(find.widgetWithText(Container, "Rate Anglers' Log"), findsNothing);
    expect(find.widgetWithText(Container, "Send Feedback"), findsNothing);
  });

  testWidgets("Rate and feedback are highlighted", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MorePage(
        feedbackKey: GlobalKey(),
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(Container, "Rate Anglers' Log"), findsOneWidget);
    expect(find.widgetWithText(Container, "Send Feedback"), findsOneWidget);
  });
}
