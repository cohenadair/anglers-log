import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;

  late SubscriptionManager subscriptionManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.userId).thenReturn("");
    when(appManager.authManager.stream).thenAnswer((_) => const Stream.empty());

    when(appManager.propertiesManager.revenueCatApiKey).thenReturn("");

    when(appManager.purchasesWrapper.logIn(any))
        .thenAnswer((_) => Future.value(MockLogInResult()));
    when(appManager.purchasesWrapper.logOut())
        .thenAnswer((_) => Future.value(MockPurchaserInfo()));

    when(appManager.userPreferenceManager.isPro).thenReturn(false);

    subscriptionManager = SubscriptionManager(appManager.app);
  });

  test("RevenueCat user identified on login", () async {
    var controller = VoidStreamController();
    when(appManager.authManager.stream).thenAnswer((_) => controller.stream);
    when(appManager.authManager.state).thenReturn(AuthState.loggedIn);

    await subscriptionManager.initialize();

    controller.notify();
    await Future.delayed(const Duration(milliseconds: 50));

    verify(appManager.purchasesWrapper.logIn(any)).called(1);
    verifyNever(appManager.purchasesWrapper.logOut());
  });

  test("RevenueCat user reset on logout", () async {
    var controller = VoidStreamController();
    when(appManager.authManager.stream).thenAnswer((_) => controller.stream);
    when(appManager.authManager.state).thenReturn(AuthState.loggedOut);

    await subscriptionManager.initialize();

    controller.notify();
    await Future.delayed(const Duration(milliseconds: 50));

    verifyNever(appManager.purchasesWrapper.logIn(any));
    verify(appManager.purchasesWrapper.logOut()).called(1);
  });

  test("Successful restore error sets state to pro", () async {
    var entitlementInfo = MockEntitlementInfo();
    when(entitlementInfo.isActive).thenReturn(true);

    var entitlementInfos = MockEntitlementInfos();
    when(entitlementInfos.all).thenReturn({
      "pro": entitlementInfo,
    });

    var purchaserInfo = MockPurchaserInfo();
    when(purchaserInfo.entitlements).thenReturn(entitlementInfos);

    when(appManager.purchasesWrapper.restoreTransactions())
        .thenAnswer((_) => Future.value(purchaserInfo));

    var restoreResult = await subscriptionManager.restoreSubscription();
    expect(restoreResult, RestoreSubscriptionResult.success);
    expect(subscriptionManager.isPro, isTrue);
  });

  test("Restore error sets state to free", () async {
    when(appManager.purchasesWrapper.restoreTransactions())
        .thenThrow(PlatformException(code: "0"));

    var restoreResult = await subscriptionManager.restoreSubscription();
    expect(restoreResult, RestoreSubscriptionResult.error);
    expect(subscriptionManager.isFree, isTrue);
  });

  test("Restore no subs found sets state to free", () async {
    var entitlementInfo = MockEntitlementInfo();
    when(entitlementInfo.isActive).thenReturn(false);

    var entitlementInfos = MockEntitlementInfos();
    when(entitlementInfos.all).thenReturn({
      "pro": entitlementInfo,
    });

    var purchaserInfo = MockPurchaserInfo();
    when(purchaserInfo.entitlements).thenReturn(entitlementInfos);

    when(appManager.purchasesWrapper.restoreTransactions())
        .thenAnswer((_) => Future.value(purchaserInfo));

    var restoreResult = await subscriptionManager.restoreSubscription();
    expect(restoreResult, RestoreSubscriptionResult.noSubscriptionsFound);
    expect(subscriptionManager.isFree, isTrue);
  });

  test("No current RevenueCat offering returns null", () async {
    var offerings = MockOfferings();
    when(offerings.current).thenReturn(null);

    when(appManager.purchasesWrapper.getOfferings())
        .thenAnswer((_) => Future.value(offerings));
    expect(await subscriptionManager.subscriptions(), isNull);
  });

  test("No available RevenueCat packages returns null", () async {
    var offering = MockOffering();
    when(offering.monthly).thenReturn(MockPackage());
    when(offering.annual).thenReturn(MockPackage());
    when(offering.availablePackages).thenReturn([]);

    var offerings = MockOfferings();
    when(offerings.current).thenReturn(offering);

    when(appManager.purchasesWrapper.getOfferings())
        .thenAnswer((_) => Future.value(offerings));

    expect(await subscriptionManager.subscriptions(), isNull);
  });

  test("Fetch subscriptions returns Subscriptions object", () async {
    var offering = MockOffering();
    when(offering.monthly).thenReturn(MockPackage());
    when(offering.annual).thenReturn(MockPackage());
    when(offering.availablePackages).thenReturn([MockPackage()]);

    var offerings = MockOfferings();
    when(offerings.current).thenReturn(offering);

    when(appManager.purchasesWrapper.getOfferings())
        .thenAnswer((_) => Future.value(offerings));

    expect(await subscriptionManager.subscriptions(), isNotNull);
  });

  test("Listeners are notified on state changes", () async {
    var entitlementInfo = MockEntitlementInfo();
    when(entitlementInfo.isActive).thenReturn(true);

    var entitlementInfos = MockEntitlementInfos();
    when(entitlementInfos.all).thenReturn({
      "pro": entitlementInfo,
    });

    var purchaserInfo = MockPurchaserInfo();
    when(purchaserInfo.entitlements).thenReturn(entitlementInfos);

    when(appManager.purchasesWrapper.restoreTransactions())
        .thenAnswer((_) => Future.value(purchaserInfo));

    var called = false;
    var listener = subscriptionManager.stream.listen((_) => called = true);

    var restoreResult = await subscriptionManager.restoreSubscription();
    expect(restoreResult, RestoreSubscriptionResult.success);
    expect(subscriptionManager.isPro, isTrue);

    await Future.delayed(const Duration(milliseconds: 50));
    expect(called, isTrue);

    listener.cancel();
  });
}
