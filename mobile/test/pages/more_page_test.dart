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

    when(appManager.baitCategoryManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn([]);

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.pollManager.canVote).thenReturn(false);
    when(appManager.pollManager.stream).thenAnswer((_) => const Stream.empty());

    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(appManager.urlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));
  });

  testWidgets("Page is pushed", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const MorePage(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.byType(BaitCategoryListPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets("Page is presented", (tester) async {
    when(appManager.userPreferenceManager.userName).thenReturn(null);
    when(appManager.userPreferenceManager.userEmail).thenReturn(null);

    await tester.pumpWidget(Testable(
      (_) => const MorePage(),
      appManager: appManager,
    ));

    await tester.ensureVisible(find.text("Send Feedback"));
    await tapAndSettle(tester, find.text("Send Feedback"));

    expect(find.byType(FeedbackPage), findsOneWidget);
    expect(find.byType(CloseButton), findsOneWidget);
  });

  testWidgets("Custom onTap", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const MorePage(),
      appManager: appManager,
    ));

    when(appManager.urlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));
    await tester.ensureVisible(find.text("Rate Anglers' Log"));
    await tapAndSettle(tester, find.text("Rate Anglers' Log"));
    verify(appManager.urlLauncherWrapper.launch(any)).called(1);
  });

  testWidgets("Rate and feedback are not highlighted", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const MorePage(),
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

  testWidgets("Menu item is hidden", (tester) async {
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => const MorePage(),
      appManager: appManager,
    ));

    expect(find.text("Baits"), findsNothing);
    expect(find.text("Bait Categories"), findsNothing);
  });

  testWidgets("Hashtag item opens app URL", (tester) async {
    when(appManager.urlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable(
      (_) => const MorePage(),
      appManager: appManager,
    ));

    await ensureVisibleAndSettle(tester, find.text("#AnglersLogApp").first);
    await tapAndSettle(tester, find.text("#AnglersLogApp").first);

    var result = verify(appManager.urlLauncherWrapper.launch(captureAny));
    result.called(1);
    expect(result.captured.first.contains("instagram://"), isTrue);
  });

  testWidgets("Hashtag item opens web URL", (tester) async {
    when(appManager.urlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(Testable(
      (_) => const MorePage(),
      appManager: appManager,
    ));

    await ensureVisibleAndSettle(tester, find.text("#AnglersLogApp").first);
    await tapAndSettle(tester, find.text("#AnglersLogApp").first);

    var result = verify(appManager.urlLauncherWrapper.launch(captureAny));
    result.called(1);
    expect(result.captured.first.contains("https://www.instagram.com"), isTrue);
  });

  testWidgets("Trailing widget is shown", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const MorePage(),
      appManager: appManager,
    ));
    expect(find.byIcon(Icons.open_in_new), findsNWidgets(2));
  });
}
