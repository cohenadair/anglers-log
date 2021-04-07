import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/data_source_facilitator.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

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
  void clearMemory() {
    clearLocalDataCount++;
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
  Future<void> initializeLocalData() async {
    initializeLocalDataCount++;
  }

  @override
  void onUpgradeToPro() {
    onUpgradeToProCount++;
  }
}

void main() {
  late StubbedAppManager appManager;

  late TestDataSourceFacilitator facilitator;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());

    facilitator = TestDataSourceFacilitator(appManager.app);
  });

  test("Firestore listener is cancelled on logout", () async {
    var controller = StreamController<void>();
    when(appManager.authManager.stream).thenAnswer((_) => controller.stream);
    when(appManager.appPreferenceManager.lastLoggedInEmail).thenReturn(null);
    when(appManager.subscriptionManager.isPro).thenReturn(true);
    when(appManager.authManager.state).thenReturn(AuthState.loggedOut);

    facilitator = TestDataSourceFacilitator(appManager.app);
    facilitator.firestoreEnabled = true;
    await facilitator.initialize();
    expect(facilitator.listener, isNotNull);
    expect(facilitator.initializeFirestoreCount, 1);

    controller.add(null);
    await Future.delayed(Duration(milliseconds: 50));
    verify(facilitator.listener.cancel()).called(1);
  });

  test("Firestore is initialized when pro and subclass enabled", () async {
    when(appManager.appPreferenceManager.lastLoggedInEmail).thenReturn(null);
    when(appManager.authManager.userId).thenReturn(null);
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    facilitator.firestoreEnabled = true;
    await facilitator.initialize();
    expect(facilitator.initializeFirestoreCount, 1);
    expect(facilitator.initializeLocalDataCount, 0);
  });

  test("Local data initialization only", () async {
    when(appManager.appPreferenceManager.lastLoggedInEmail).thenReturn(null);
    when(appManager.authManager.userId).thenReturn(null);
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    facilitator.firestoreEnabled = false;
    await facilitator.initialize();
    expect(facilitator.initializeFirestoreCount, 0);
    expect(facilitator.initializeLocalDataCount, 1);
  });

  test("When a user upgrades to pro, onUpgradeToPro is invoked", () async {
    var controller = StreamController.broadcast();
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => controller.stream);

    facilitator = TestDataSourceFacilitator(appManager.app);

    // Verify onUpgradeToPro isn't invoked when conditions aren't met.
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    controller.add(null);
    expect(facilitator.onUpgradeToProCount, 0);

    when(appManager.subscriptionManager.isPro).thenReturn(true);
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
