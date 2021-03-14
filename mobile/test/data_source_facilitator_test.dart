import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/data_source_facilitator.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

class TestDataSourceFacilitator extends DataSourceFacilitator {
  bool firestoreEnabled = false;
  int clearLocalDataCount = 0;
  int initializeFirestoreCount = 0;
  int initializeLocalDataCount = 0;
  int onLocalDatabaseDeletedCount = 0;
  int onUpgradeToProCount = 0;

  MockStreamSubscription listener = MockStreamSubscription();

  TestDataSourceFacilitator(AppManager appManager) : super(appManager);

  @override
  Future<void> clearLocalData() {
    clearLocalDataCount++;
    return null;
  }

  @override
  bool get enableFirestore => firestoreEnabled;

  @override
  StreamSubscription initializeFirestore(Completer completer) {
    initializeFirestoreCount++;
    completer.complete();
    return listener;
  }

  @override
  Future<void> initializeLocalData() {
    initializeLocalDataCount++;
    return null;
  }

  @override
  void onUpgradeToPro() {
    onUpgradeToProCount++;
  }
}

void main() {
  MockAppManager appManager;

  TestDataSourceFacilitator facilitator;

  setUp(() {
    appManager = MockAppManager(
      mockAppPreferenceManager: true,
      mockAuthManager: true,
      mockLocalDatabaseManager: true,
      mockSubscriptionManager: true,
    );

    when(appManager.mockAuthManager.stream).thenAnswer((_) => MockStream());
    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => MockStream());

    facilitator = TestDataSourceFacilitator(appManager);
  });

  test("Firestore listener is cancelled on logout", () async {
    var controller = StreamController<void>();
    when(appManager.mockAuthManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.mockAppPreferenceManager.lastLoggedInUserId)
        .thenReturn(null);
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedOut);

    facilitator = TestDataSourceFacilitator(appManager);
    facilitator.firestoreEnabled = true;
    await facilitator.initialize();
    expect(facilitator.listener, isNotNull);
    expect(facilitator.initializeFirestoreCount, 1);

    controller.add(null);
    await Future.delayed(Duration(milliseconds: 50));
    verify(facilitator.listener.cancel()).called(1);
  });

  test("Local data is cleared when logged in user changes", () async {
    when(appManager.mockAppPreferenceManager.lastLoggedInUserId)
        .thenReturn(null);
    when(appManager.mockAuthManager.userId).thenReturn("USER_ID");
    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => MockStream<void>());
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    await facilitator.initialize();
    await Future.delayed(Duration(milliseconds: 50));
    expect(facilitator.clearLocalDataCount, 1);
  });

  test("Firestore is initialized when pro and subclass enabled", () async {
    when(appManager.mockAppPreferenceManager.lastLoggedInUserId)
        .thenReturn(null);
    when(appManager.mockAuthManager.userId).thenReturn(null);
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);

    facilitator.firestoreEnabled = true;
    await facilitator.initialize();
    expect(facilitator.initializeFirestoreCount, 1);
    expect(facilitator.initializeLocalDataCount, 0);
  });

  test("Local data initialization only", () async {
    when(appManager.mockAppPreferenceManager.lastLoggedInUserId)
        .thenReturn(null);
    when(appManager.mockAuthManager.userId).thenReturn(null);
    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => MockStream<void>());
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    facilitator.firestoreEnabled = false;
    await facilitator.initialize();
    expect(facilitator.initializeFirestoreCount, 0);
    expect(facilitator.initializeLocalDataCount, 1);
  });

  test("When a user upgrades to pro, onUpgradeToPro is invoked", () async {
    var controller = StreamController.broadcast();
    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => controller.stream);

    facilitator = TestDataSourceFacilitator(appManager);

    // Verify onUpgradeToPro isn't invoked when conditions aren't met.
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);
    controller.add(null);
    expect(facilitator.onUpgradeToProCount, 0);

    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);
    controller.add(null);
    expect(facilitator.onUpgradeToProCount, 0);

    // Verify onUpgradeToPro is invoked.
    facilitator.firestoreEnabled = true;
    controller.add(null);

    // Need to wait for Firebase initialization Future to finish.
    await Future.delayed(Duration(milliseconds: 50));
    expect(facilitator.onUpgradeToProCount, 1);

    // Verify onUpgradeToPro is not invoked again if another event is fired.
    controller.add(null);
    await Future.delayed(Duration(milliseconds: 50));
    expect(facilitator.onUpgradeToProCount, 1);
  });
}
