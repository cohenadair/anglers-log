import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mobile/pages/backup_restore_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.backupRestoreManager.progressStream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.backupRestoreManager.hasLastProgressError)
        .thenReturn(false);

    when(appManager.baitCategoryManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn([]);

    when(appManager.catchManager.imageNamesSortedByTimestamp(any))
        .thenReturn([]);
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([]);
    when(appManager.catchManager.hasEntities).thenReturn(false);
    when(appManager.catchManager.listen(any))
        .thenAnswer((_) => MockStreamSubscription());

    when(appManager.gpsTrailManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.gpsTrailManager.hasActiveTrail).thenReturn(false);
    when(appManager.gpsTrailManager.activeTrial).thenReturn(null);

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.notificationManager.stream)
        .thenAnswer((_) => const Stream.empty());

    when(appManager.pollManager.canVote).thenReturn(false);
    when(appManager.pollManager.stream).thenAnswer((_) => const Stream.empty());

    when(appManager.reportManager.entityExists(any)).thenReturn(false);
    when(appManager.reportManager.defaultReport).thenReturn(Report());
    when(appManager.reportManager.displayName(any, any)).thenReturn("Test");

    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(appManager.locationMonitor.currentLatLng).thenReturn(null);

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    when(appManager.timeManager.currentDateTime).thenReturn(now());

    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(appManager.userPreferenceManager.selectedReportId).thenReturn(null);
    when(appManager.userPreferenceManager.setSelectedReportId(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.mapType).thenReturn(null);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.userPreferenceManager.autoBackup).thenReturn(false);

    when(appManager.tripManager.listen(any))
        .thenAnswer((_) => MockStreamSubscription());
  });

  testWidgets("Tapping nav item opens page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
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
      appManager: appManager,
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
      appManager: appManager,
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
    when(appManager.pollManager.canVote).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
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
    when(appManager.pollManager.canVote).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
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
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    when(appManager.userPreferenceManager.didRateApp).thenReturn(true);
    when(appManager.userPreferenceManager.proTimerStartedAt).thenReturn(1000);
    when(appManager.userPreferenceManager.setProTimerStartedAt(any))
        .thenAnswer((_) => Future.value(null));

    when(appManager.timeManager.currentTimestamp)
        .thenReturn((Duration.millisecondsPerDay * 7 + 1500).round());

    var catchController =
        StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    var tripController =
        StreamController<EntityEvent<Trip>>.broadcast(sync: true);
    when(appManager.catchManager.listen(any)).thenAnswer((invocation) =>
        catchController.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(appManager.catchManager.entityCount).thenReturn(5);
    when(appManager.tripManager.listen(any)).thenAnswer((invocation) =>
        tripController.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(appManager.tripManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the catch listener.
    catchController.add(EntityEvent<Catch>(EntityEventType.add, Catch()));

    await tester.pumpAndSettle();
    expect(find.byType(ProPage), findsOneWidget);
    verify(appManager.userPreferenceManager.setProTimerStartedAt(any))
        .called(1);
    await tapAndSettle(tester, find.byType(CloseButton));
    expect(find.byType(ProPage), findsNothing);

    // Trigger the trip listener.
    tripController.add(EntityEvent<Trip>(EntityEventType.add, Trip()));

    await tester.pumpAndSettle();
    expect(find.byType(ProPage), findsOneWidget);
    verify(appManager.userPreferenceManager.setProTimerStartedAt(any))
        .called(1);
    await tapAndSettle(tester, find.byType(CloseButton));
    expect(find.byType(ProPage), findsNothing);
  });

  testWidgets("Feedback dialogs not shown if not enough activity",
      (tester) async {
    var catchController =
        StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    var tripController =
        StreamController<EntityEvent<Trip>>.broadcast(sync: true);
    when(appManager.catchManager.listen(any)).thenAnswer((invocation) =>
        catchController.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(appManager.catchManager.entityCount).thenReturn(0);
    when(appManager.tripManager.listen(any)).thenAnswer((invocation) =>
        tripController.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(appManager.tripManager.entityCount).thenReturn(0);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the catch listener.
    catchController.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    verify(appManager.catchManager.entityCount).called(1);
    verifyNever(appManager.subscriptionManager.isFree);

    // Trigger the trip listener.
    tripController.add(EntityEvent<Trip>(EntityEventType.add, Trip()));
    verify(appManager.tripManager.entityCount).called(1);
    verifyNever(appManager.subscriptionManager.isFree);
  });

  testWidgets("Review requested if already pro", (tester) async {
    when(appManager.inAppReviewWrapper.isAvailable())
        .thenAnswer((_) => Future.value(true));
    when(appManager.inAppReviewWrapper.requestReview())
        .thenAnswer((_) => Future.value());

    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.userPreferenceManager.didRateApp).thenReturn(true);

    var controller = StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    when(appManager.catchManager.listen(any)).thenAnswer((invocation) =>
        controller.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(appManager.catchManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the listener.
    controller.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ProPage), findsNothing);
    verifyNever(appManager.userPreferenceManager.setProTimerStartedAt(any));
    verify(appManager.inAppReviewWrapper.isAvailable()).called(1);
    verify(appManager.inAppReviewWrapper.requestReview()).called(1);
  });

  testWidgets("Review not requested if not available", (tester) async {
    when(appManager.inAppReviewWrapper.isAvailable())
        .thenAnswer((_) => Future.value(false));

    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.userPreferenceManager.didRateApp).thenReturn(true);

    var controller = StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    when(appManager.catchManager.listen(any)).thenAnswer((invocation) =>
        controller.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(appManager.catchManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the listener.
    controller.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ProPage), findsNothing);
    verifyNever(appManager.userPreferenceManager.setProTimerStartedAt(any));
    verify(appManager.inAppReviewWrapper.isAvailable()).called(1);
    verifyNever(appManager.inAppReviewWrapper.requestReview());
  });

  testWidgets("ProPage not shown if not enough time has passed",
      (tester) async {
    when(appManager.inAppReviewWrapper.isAvailable())
        .thenAnswer((_) => Future.value(false));
    when(appManager.subscriptionManager.isFree).thenReturn(true);

    when(appManager.userPreferenceManager.didRateApp).thenReturn(true);
    when(appManager.userPreferenceManager.proTimerStartedAt).thenReturn(1000);

    when(appManager.timeManager.currentTimestamp)
        .thenReturn((Duration.millisecondsPerDay * 7 - 1500).round());

    var controller = StreamController<EntityEvent<Catch>>.broadcast(sync: true);
    when(appManager.catchManager.listen(any)).thenAnswer((invocation) =>
        controller.stream.listen(
            (event) => invocation.positionalArguments[0].onAdd(event.entity)));
    when(appManager.catchManager.entityCount).thenReturn(5);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Trigger the listener.
    controller.add(EntityEvent<Catch>(EntityEventType.add, Catch()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ProPage), findsNothing);
    verify(appManager.userPreferenceManager.proTimerStartedAt).called(1);
    verifyNever(appManager.userPreferenceManager.setProTimerStartedAt(any));
  });

  testWidgets("Notification shown via listener", (tester) async {
    var controller = StreamController<LocalNotificationType>.broadcast();
    when(appManager.notificationManager.stream)
        .thenAnswer((_) => controller.stream);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    controller.add(LocalNotificationType.backupProgressError);
    await untilCalled(appManager.notificationManager.show(
      title: anyNamed("title"),
      body: anyNamed("body"),
      details: anyNamed("details"),
    ));
    verify(appManager.notificationManager.show(
      title: anyNamed("title"),
      body: anyNamed("body"),
      details: anyNamed("details"),
    )).called(1);
  });

  testWidgets("BackupPage shown on notification tap", (tester) async {
    when(appManager.backupRestoreManager.authStream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.backupRestoreManager.lastProgressError).thenReturn(null);
    when(appManager.backupRestoreManager.isInProgress).thenReturn(false);
    when(appManager.backupRestoreManager.isSignedIn).thenReturn(false);
    when(appManager.backupRestoreManager.isBackupRestorePageShowing)
        .thenReturn(false);
    when(appManager.userPreferenceManager.lastBackupAt).thenReturn(null);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Invoke callback set by MainPage.
    var result = verify(appManager
        .notificationManager.onDidReceiveNotificationResponse = captureAny);
    result.called(1);
    result.captured.first();

    await tester.pumpAndSettle();
    expect(find.byType(BackupPage), findsOneWidget);
  });

  testWidgets("BackupPage not shown if already showing", (tester) async {
    when(appManager.backupRestoreManager.isBackupRestorePageShowing)
        .thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Invoke callback set by MainPage.
    var result = verify(appManager
        .notificationManager.onDidReceiveNotificationResponse = captureAny);
    result.called(1);
    result.captured.first();

    await tester.pumpAndSettle();
    verify(appManager.backupRestoreManager.isBackupRestorePageShowing)
        .called(1);
    expect(find.byType(BackupPage), findsNothing);
  });

  testWidgets("Permission requested on app start", (tester) async {
    when(appManager.userPreferenceManager.autoBackup).thenReturn(true);
    when(appManager.notificationManager.requestPermissionIfNeeded(any, any))
        .thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(appManager.notificationManager.requestPermissionIfNeeded(any, any))
        .called(1);
  });

  testWidgets("Notification on app start", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(appManager.backupRestoreManager.notifySignedOutIfNeeded()).called(1);
  });

  testWidgets("NotificationManager state reset on dispose", (tester) async {
    await pumpContext(
      tester,
      (_) => DisposableTester(
        child: Testable(
          (_) => MainPage(),
          appManager: appManager,
        ),
      ),
    );
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    var state =
        tester.firstState<DisposableTesterState>(find.byType(DisposableTester));
    state.removeChild();
    await tester.pumpAndSettle();

    verify(appManager.notificationManager.onDidReceiveNotificationResponse =
            null)
        .called(1);
  });

  testWidgets("Backup badge shown on startup", (tester) async {
    when(appManager.backupRestoreManager.hasLastProgressError).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isTrue);
  });

  testWidgets("Backup badge hidden on startup", (tester) async {
    when(appManager.backupRestoreManager.hasLastProgressError)
        .thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isFalse);
  });

  testWidgets("Backup badge updated on backup error", (tester) async {
    when(appManager.backupRestoreManager.hasLastProgressError)
        .thenReturn(false);

    var controller = StreamController<BackupRestoreProgress>.broadcast();
    when(appManager.backupRestoreManager.progressStream)
        .thenAnswer((_) => controller.stream);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isFalse);

    // Add error to stream.
    when(appManager.backupRestoreManager.hasLastProgressError).thenReturn(true);
    controller.add(BackupRestoreProgress(BackupRestoreProgressEnum.signedOut));
    await tester.pumpAndSettle();

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isTrue);

    // Remove error.
    when(appManager.backupRestoreManager.hasLastProgressError)
        .thenReturn(false);
    controller.add(BackupRestoreProgress(BackupRestoreProgressEnum.cleared));
    await tester.pumpAndSettle();

    // First one is on the Map icon.
    expect(findLast<BadgeContainer>(tester).isBadgeVisible, isFalse);
  });
}
