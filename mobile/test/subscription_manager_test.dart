import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/utils/void_stream_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:purchases_flutter/entitlement_info_wrapper.dart';
import 'package:purchases_flutter/entitlement_infos_wrapper.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:purchases_flutter/purchaser_info_wrapper.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

class MockEntitlementInfo extends Mock implements EntitlementInfo {}

class MockEntitlementInfos extends Mock implements EntitlementInfos {}

class MockOffering extends Mock implements Offering {}

class MockOfferings extends Mock implements Offerings {}

class MockPackage extends Mock implements Package {}

class MockPurchaserInfo extends Mock implements PurchaserInfo {}

void main() {
  MockAppManager appManager;

  SubscriptionManager subscriptionManager;

  setUp(() {
    appManager = MockAppManager(
      mockAuthManager: true,
      mockPropertiesManager: true,
      mockPurchasesWrapper: true,
    );

    when(appManager.mockAuthManager.stream).thenAnswer((_) => MockStream());

    subscriptionManager = SubscriptionManager(appManager);
  });

  test("RevenueCat user identified on login", () async {
    var controller = VoidStreamController();
    when(appManager.mockAuthManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedIn);

    await subscriptionManager.initialize();

    controller.notify();
    await Future.delayed(Duration(milliseconds: 50));

    verify(appManager.mockPurchasesWrapper.identify(any)).called(1);
    verifyNever(appManager.mockPurchasesWrapper.reset());
  });

  test("RevenueCat user reset on logout", () async {
    var controller = VoidStreamController();
    when(appManager.mockAuthManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedOut);

    await subscriptionManager.initialize();

    controller.notify();
    await Future.delayed(Duration(milliseconds: 50));

    verifyNever(appManager.mockPurchasesWrapper.identify(any));
    verify(appManager.mockPurchasesWrapper.reset()).called(1);
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

    when(appManager.mockPurchasesWrapper.restoreTransactions())
        .thenAnswer((_) => Future.value(purchaserInfo));

    var restoreResult = await subscriptionManager.restoreSubscription();
    expect(restoreResult, RestoreSubscriptionResult.success);
    expect(subscriptionManager.isPro, isTrue);
  });

  test("Restore error sets state to free", () async {
    when(appManager.mockPurchasesWrapper.restoreTransactions())
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

    when(appManager.mockPurchasesWrapper.restoreTransactions())
        .thenAnswer((_) => Future.value(purchaserInfo));

    var restoreResult = await subscriptionManager.restoreSubscription();
    expect(restoreResult, RestoreSubscriptionResult.noSubscriptionsFound);
    expect(subscriptionManager.isFree, isTrue);
  });

  test("No current RevenueCat offering returns null", () async {
    when(appManager.mockPurchasesWrapper.getOfferings()).thenAnswer((_) =>
        Future.value(MockOfferings()));
    expect(await subscriptionManager.subscriptions(), isNull);
  });

  test("No available RevenueCat packages returns null", () async {
    var offering = MockOffering();
    when(offering.availablePackages).thenReturn([]);

    var offerings = MockOfferings();
    when(offerings.current).thenReturn(offering);

    when(appManager.mockPurchasesWrapper.getOfferings()).thenAnswer((_) =>
        Future.value(offerings));

    expect(await subscriptionManager.subscriptions(), isNull);
  });

  test("Fetch subscriptions returns Subscriptions object", () async {
    var offering = MockOffering();
    when(offering.availablePackages).thenReturn([MockPackage()]);

    var offerings = MockOfferings();
    when(offerings.current).thenReturn(offering);

    when(appManager.mockPurchasesWrapper.getOfferings()).thenAnswer((_) =>
        Future.value(offerings));

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

    when(appManager.mockPurchasesWrapper.restoreTransactions())
        .thenAnswer((_) => Future.value(purchaserInfo));

    var called = false;
    var listener = subscriptionManager.stream.listen((_) => called = true);

    var restoreResult = await subscriptionManager.restoreSubscription();
    expect(restoreResult, RestoreSubscriptionResult.success);
    expect(subscriptionManager.isPro, isTrue);

    await Future.delayed(Duration(milliseconds: 50));
    expect(called, isTrue);

    listener.cancel();
  });
}