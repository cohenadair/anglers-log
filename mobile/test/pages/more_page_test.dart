import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/pages/more_page.dart';
import 'package:mobile/pages/species_counter_page.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    when(
      managers.baitCategoryManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn([]);

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    when(managers.pollManager.canVote).thenReturn(false);
    when(managers.pollManager.stream).thenAnswer((_) => const Stream.empty());

    when(managers.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingFishingSpots,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingWaterClarities,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      managers.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.urlLauncherWrapper.launch(any),
    ).thenAnswer((_) => Future.value(true));
  });

  testWidgets("Page is pushed", (tester) async {
    await tester.pumpWidget(Testable((_) => const MorePage()));

    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.byType(BaitCategoryListPage), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets("Page is presented", (tester) async {
    when(managers.userPreferenceManager.userName).thenReturn(null);
    when(managers.userPreferenceManager.userEmail).thenReturn(null);

    await tester.pumpWidget(Testable((_) => const MorePage()));

    await tester.ensureVisible(find.text("Send Feedback"));
    await tapAndSettle(tester, find.text("Send Feedback"));

    expect(find.byType(FeedbackPage), findsOneWidget);
    expect(find.byType(CloseButton), findsOneWidget);
  });

  testWidgets("Custom onTap", (tester) async {
    await tester.pumpWidget(Testable((_) => const MorePage()));

    when(
      managers.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.urlLauncherWrapper.launch(any),
    ).thenAnswer((_) => Future.value(true));
    await tester.ensureVisible(find.text("Rate Anglers' Log"));
    await tapAndSettle(tester, find.text("Rate Anglers' Log"));
    verify(managers.urlLauncherWrapper.launch(any)).called(1);
  });

  testWidgets("Rate and feedback are not highlighted", (tester) async {
    await tester.pumpWidget(Testable((_) => const MorePage()));

    expect(find.widgetWithText(Container, "Rate Anglers' Log"), findsNothing);
    expect(find.widgetWithText(Container, "Send Feedback"), findsNothing);
  });

  testWidgets("Rate and feedback are highlighted", (tester) async {
    await tester.pumpWidget(
      Testable((_) => MorePage(feedbackKey: GlobalKey())),
    );

    expect(find.widgetWithText(Container, "Rate Anglers' Log"), findsOneWidget);
    expect(find.widgetWithText(Container, "Send Feedback"), findsOneWidget);
  });

  testWidgets("Menu item is hidden", (tester) async {
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(false);

    await tester.pumpWidget(Testable((_) => const MorePage()));

    expect(find.text("Baits"), findsNothing);
    expect(find.text("Bait Categories"), findsNothing);
  });

  testWidgets("Hashtag item opens app URL", (tester) async {
    when(
      managers.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable((_) => const MorePage()));

    await ensureVisibleAndSettle(tester, find.text("#AnglersLogApp").first);
    await tapAndSettle(tester, find.text("#AnglersLogApp").first);

    var result = verify(managers.urlLauncherWrapper.launch(captureAny));
    result.called(1);
    expect(result.captured.first.contains("instagram://"), isTrue);
  });

  testWidgets("Hashtag item opens web URL", (tester) async {
    when(
      managers.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(Testable((_) => const MorePage()));

    await ensureVisibleAndSettle(tester, find.text("#AnglersLogApp").first);
    await tapAndSettle(tester, find.text("#AnglersLogApp").first);

    var result = verify(managers.urlLauncherWrapper.launch(captureAny));
    result.called(1);
    expect(result.captured.first.contains("https://www.instagram.com"), isTrue);
  });

  testWidgets("Trailing widget is shown", (tester) async {
    await tester.pumpWidget(Testable((_) => const MorePage()));
    expect(find.byIcon(Icons.open_in_new), findsNWidgets(2));
  });

  testWidgets("Backup badge updated on backup error", (tester) async {
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    var controller = StreamController<BackupRestoreProgress>.broadcast();
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(Testable((_) => const MorePage()));

    expect(
      findSiblingOfText<MyBadge>(tester, ListItem, "Backup").isVisible,
      isFalse,
    );

    // Add error to stream.
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(true);
    controller.add(BackupRestoreProgress(BackupRestoreProgressEnum.signedOut));
    await tester.pumpAndSettle();

    expect(
      findSiblingOfText<MyBadge>(tester, ListItem, "Backup").isVisible,
      isTrue,
    );

    // Remove error.
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);
    controller.add(BackupRestoreProgress(BackupRestoreProgressEnum.cleared));
    await tester.pumpAndSettle();

    expect(
      findSiblingOfText<MyBadge>(tester, ListItem, "Backup").isVisible,
      isFalse,
    );
  });

  testWidgets("ProPage shown on species counter", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(
      managers.lib.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable((_) => const MorePage()));

    await tester.ensureVisible(find.text("Species Counter"));

    // For reasons I cannot explain, doing a normal tapAndSettle here
    // fails the hit test, so invoke onTap directly. Note that everything
    // works when testing in the app.
    var counter = findFirstWithText<ListItem>(tester, "Species Counter");
    counter.onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(AnglersLogProPage), findsOneWidget);
    expect(find.byType(SpeciesCounterPage), findsNothing);
  });

  testWidgets("Species counter shown", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.speciesCounter).thenReturn({});
    when(
      managers.speciesManager.listSortedByDisplayName(
        any,
        ids: anyNamed("ids"),
      ),
    ).thenReturn([]);

    await tester.pumpWidget(Testable((_) => const MorePage()));

    await tester.ensureVisible(find.text("Species Counter"));

    // For reasons I cannot explain, doing a normal tapAndSettle here
    // fails the hit test, so invoke onTap directly. Note that everything
    // works when testing in the app.
    var counter = findFirstWithText<ListItem>(tester, "Species Counter");
    counter.onTap!();
    await tester.pumpAndSettle();

    expect(find.byType(AnglersLogProPage), findsNothing);
    expect(find.byType(SpeciesCounterPage), findsOneWidget);
  });
}
