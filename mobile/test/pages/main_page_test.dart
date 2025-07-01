import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mobile/pages/backup_restore_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.backupRestoreManager.progressStream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    when(managers.baitCategoryManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn([]);

    when(managers.catchManager.imageNamesSortedByTimestamp(any)).thenReturn([]);
    when(managers.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([]);
    when(managers.catchManager.hasEntities).thenReturn(false);
    when(managers.catchManager.listen(any))
        .thenAnswer((_) => MockStreamSubscription());

    when(managers.gpsTrailManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(false);
    when(managers.gpsTrailManager.activeTrial).thenReturn(null);

    when(managers.ioWrapper.isAndroid).thenReturn(false);

    when(managers.notificationManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(managers.pollManager.canVote).thenReturn(false);
    when(managers.pollManager.stream).thenAnswer((_) => const Stream.empty());

    when(managers.reportManager.entityExists(any)).thenReturn(false);
    when(managers.reportManager.defaultReport).thenReturn(Report());
    when(managers.reportManager.displayName(any, any)).thenReturn("Test");

    when(managers.fishingSpotManager.list()).thenReturn([]);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    when(managers.propertiesManager.mapboxApiKey).thenReturn("");

    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(true);

    when(managers.lib.timeManager.currentDateTime).thenReturn(now());

    when(managers.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(managers.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(managers.userPreferenceManager.selectedReportId).thenReturn(null);
    when(managers.userPreferenceManager.setSelectedReportId(any))
        .thenAnswer((_) => Future.value());
    when(managers.userPreferenceManager.mapType).thenReturn(null);
    when(managers.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.autoBackup).thenReturn(false);

    when(managers.tripManager.listen(any))
        .thenAnswer((_) => MockStreamSubscription());
  });

  testWidgets("Tapping nav item opens page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Starts on Catches page.
    expect(findFirst<IndexedStack>(tester).index, 1);

    await tapAndSettle(tester, find.text("Catches"));
    expect(findFirst<IndexedStack>(tester).index, 1);

    await tapAndSettle(tester, find.text("Map"));
    expect(findFirst<IndexedStack>(tester).index, 0);

    await tapAndSettle(tester, find.text("Stats"));
    expect(findFirst<IndexedStack>(tester).index, 3);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    expect(findFirst<IndexedStack>(tester).index, 4);

    await tapAndSettle(tester, find.text("Add"));
    // Indexed stack should stay at the same index.
    expect(findFirst<IndexedStack>(tester).index, 4);
    expect(find.text("Add New"), findsOneWidget);
  });

  testWidgets("Navigation state is persisted when switching tabs",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.text("Bait Categories (0)"), findsOneWidget);

    await tapAndSettle(tester, find.text("Catches"));
    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    expect(find.text("Bait Categories (0)"), findsOneWidget);
  });

  testWidgets("Tapping current nav item again pops all pages on current stack",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.text("Bait Categories (0)"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    expect(find.text("Bait Categories (0)"), findsNothing);
  });

  testWidgets("Poll badge shown", (tester) async {
    when(managers.pollManager.canVote).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(
      findFirstWithIcon<BadgeContainer>(tester, Icons.more_horiz)
          .isBadgeVisible,
      isTrue,
    );
  });

  testWidgets("Poll badge hidden", (tester) async {
    when(managers.pollManager.canVote).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(
      findFirstWithIcon<BadgeContainer>(tester, Icons.more_horiz)
          .isBadgeVisible,
      isFalse,
    );
  });

  testWidgets("ProPage shown", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(managers.lib.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    when(managers.userPreferenceManager.didRateApp).thenReturn(true);
    when(managers.userPreferenceManager.proTimerStartedAt).thenReturn(1000);
    when(managers.userPreferenceManager.setProTimerStartedAt(any))
        .thenAnswer((_) => Future.value(null));

    when(managers.lib.timeManager.currentTimestamp)
        .thenReturn((Duration.millisecondsPerDay * 7 + 1500).round());

    var catchController =
        StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    var tripController =
        StreamController<EntityEvent<Trip>>.broadcast(sync: true);
    when(managers.catchManager.listen(any)).thenAnswer((invocation) =>
        catchController.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(managers.catchManager.entityCount).thenReturn(5);
    when(managers.tripManager.listen(any)).thenAnswer((invocation) =>
        tripController.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(managers.tripManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the catch listener.
    catchController.add(EntityEvent<Catch>(EntityEventType.add, Catch()));

    await tester.pumpAndSettle();
    expect(find.byType(AnglersLogProPage), findsOneWidget);
    verify(managers.userPreferenceManager.setProTimerStartedAt(any)).called(1);
    await tapAndSettle(tester, find.byType(CloseButton));
    expect(find.byType(AnglersLogProPage), findsNothing);

    // Trigger the trip listener.
    tripController.add(EntityEvent<Trip>(EntityEventType.add, Trip()));

    await tester.pumpAndSettle();
    expect(find.byType(AnglersLogProPage), findsOneWidget);
    verify(managers.userPreferenceManager.setProTimerStartedAt(any)).called(1);
    await tapAndSettle(tester, find.byType(CloseButton));
    expect(find.byType(AnglersLogProPage), findsNothing);
  });

  testWidgets("Feedback dialogs not shown if not enough activity",
      (tester) async {
    var catchController =
        StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    var tripController =
        StreamController<EntityEvent<Trip>>.broadcast(sync: true);
    when(managers.catchManager.listen(any)).thenAnswer((invocation) =>
        catchController.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(managers.catchManager.entityCount).thenReturn(0);
    when(managers.tripManager.listen(any)).thenAnswer((invocation) =>
        tripController.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(managers.tripManager.entityCount).thenReturn(0);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the catch listener.
    catchController.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    verify(managers.catchManager.entityCount).called(1);
    verifyNever(managers.lib.subscriptionManager.isFree);

    // Trigger the trip listener.
    tripController.add(EntityEvent<Trip>(EntityEventType.add, Trip()));
    verify(managers.tripManager.entityCount).called(1);
    verifyNever(managers.lib.subscriptionManager.isFree);
  });

  testWidgets("Review requested if already pro", (tester) async {
    when(managers.inAppReviewWrapper.isAvailable())
        .thenAnswer((_) => Future.value(true));
    when(managers.inAppReviewWrapper.requestReview())
        .thenAnswer((_) => Future.value());

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.didRateApp).thenReturn(true);

    var controller = StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    when(managers.catchManager.listen(any)).thenAnswer((invocation) =>
        controller.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(managers.catchManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the listener.
    controller.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AnglersLogProPage), findsNothing);
    verifyNever(managers.userPreferenceManager.setProTimerStartedAt(any));
    verify(managers.inAppReviewWrapper.isAvailable()).called(1);
    verify(managers.inAppReviewWrapper.requestReview()).called(1);
  });

  testWidgets("Review not requested if not available", (tester) async {
    when(managers.inAppReviewWrapper.isAvailable())
        .thenAnswer((_) => Future.value(false));

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.didRateApp).thenReturn(true);

    var controller = StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    when(managers.catchManager.listen(any)).thenAnswer((invocation) =>
        controller.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(managers.catchManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the listener.
    controller.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AnglersLogProPage), findsNothing);
    verifyNever(managers.userPreferenceManager.setProTimerStartedAt(any));
    verify(managers.inAppReviewWrapper.isAvailable()).called(1);
    verifyNever(managers.inAppReviewWrapper.requestReview());
  });

  testWidgets("ProPage not shown if not enough time has passed",
      (tester) async {
    when(managers.inAppReviewWrapper.isAvailable())
        .thenAnswer((_) => Future.value(false));
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);

    when(managers.userPreferenceManager.didRateApp).thenReturn(true);
    when(managers.userPreferenceManager.proTimerStartedAt).thenReturn(1000);

    when(managers.lib.timeManager.currentTimestamp)
        .thenReturn((Duration.millisecondsPerDay * 7 - 1500).round());

    var controller = StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    when(managers.catchManager.listen(any)).thenAnswer((invocation) =>
        controller.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(managers.catchManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the listener.
    controller.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AnglersLogProPage), findsNothing);
    verify(managers.userPreferenceManager.proTimerStartedAt).called(1);
    verifyNever(managers.userPreferenceManager.setProTimerStartedAt(any));
  });

  testWidgets("Notification shown via listener", (tester) async {
    var controller = StreamController<LocalNotificationType>.broadcast();
    when(managers.notificationManager.stream)
        .thenAnswer((_) => controller.stream);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    controller.add(LocalNotificationType.backupProgressError);
    await untilCalled(managers.notificationManager.show(
      title: anyNamed("title"),
      body: anyNamed("body"),
      details: anyNamed("details"),
    ));
    verify(managers.notificationManager.show(
      title: anyNamed("title"),
      body: anyNamed("body"),
      details: anyNamed("details"),
    )).called(1);
  });

  testWidgets("BackupPage shown on notification tap", (tester) async {
    when(managers.backupRestoreManager.authStream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.lastProgressError).thenReturn(null);
    when(managers.backupRestoreManager.isInProgress).thenReturn(false);
    when(managers.backupRestoreManager.isSignedIn).thenReturn(false);
    when(managers.backupRestoreManager.isBackupRestorePageShowing)
        .thenReturn(false);
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(null);
    when(managers.ioWrapper.isIOS).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Invoke callback set by MainPage.
    var result = verify(managers
        .notificationManager.onDidReceiveNotificationResponse = captureAny);
    result.called(1);
    result.captured.first();

    await tester.pumpAndSettle();
    expect(find.byType(BackupPage), findsOneWidget);
  });

  testWidgets("BackupPage not shown if already showing", (tester) async {
    when(managers.backupRestoreManager.isBackupRestorePageShowing)
        .thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Invoke callback set by MainPage.
    var result = verify(managers
        .notificationManager.onDidReceiveNotificationResponse = captureAny);
    result.called(1);
    result.captured.first();

    await tester.pumpAndSettle();
    verify(managers.backupRestoreManager.isBackupRestorePageShowing).called(1);
    expect(find.byType(BackupPage), findsNothing);
  });

  testWidgets("Permission requested on app start", (tester) async {
    when(managers.userPreferenceManager.autoBackup).thenReturn(true);
    when(managers.notificationManager.requestPermissionIfNeeded(any, any))
        .thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(managers.notificationManager.requestPermissionIfNeeded(any, any))
        .called(1);
  });

  testWidgets("Notification on app start", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(managers.backupRestoreManager.notifySignedOutIfNeeded()).called(1);
  });

  testWidgets("NotificationManager state reset on dispose", (tester) async {
    await pumpContext(
      tester,
      (_) => DisposableTester(child: Testable((_) => MainPage())),
    );
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    var state =
        tester.firstState<DisposableTesterState>(find.byType(DisposableTester));
    state.removeChild();
    await tester.pumpAndSettle();

    verify(managers.notificationManager.onDidReceiveNotificationResponse = null)
        .called(1);
  });

  testWidgets("Backup badge shown on startup", (tester) async {
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isTrue);
  });

  testWidgets("Backup badge hidden on startup", (tester) async {
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isFalse);
  });

  testWidgets("Backup badge updated on backup error", (tester) async {
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    var controller = StreamController<BackupRestoreProgress>.broadcast();
    when(managers.backupRestoreManager.progressStream)
        .thenAnswer((_) => controller.stream);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isFalse);

    // Add error to stream.
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(true);
    controller.add(BackupRestoreProgress(BackupRestoreProgressEnum.signedOut));
    await tester.pumpAndSettle();

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isTrue);

    // Remove error.
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);
    controller.add(BackupRestoreProgress(BackupRestoreProgressEnum.cleared));
    await tester.pumpAndSettle();

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isFalse);
  });
}
