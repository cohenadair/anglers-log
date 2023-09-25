import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:purchases_flutter/errors.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;

  late SubscriptionManager subscriptionManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.propertiesManager.revenueCatApiKey).thenReturn("");

    when(appManager.purchasesWrapper.configure(any))
        .thenAnswer((_) => Future.value());
    when(appManager.purchasesWrapper.setLogLevel(any)).thenAnswer((_) {});
    when(appManager.purchasesWrapper.addCustomerInfoUpdateListener(any))
        .thenAnswer((_) {});
    when(appManager.purchasesWrapper.logIn(any))
        .thenAnswer((_) => Future.value(MockLogInResult()));
    when(appManager.purchasesWrapper.logOut())
        .thenAnswer((_) => Future.value(MockCustomerInfo()));

    subscriptionManager = SubscriptionManager(appManager.app);
  });

  test("Initialize ignores network error", () async {
    var exception = MockPlatformException();
    when(exception.code)
        .thenReturn(PurchasesErrorCode.networkError.index.toString());
    when(appManager.purchasesWrapper.getCustomerInfo())
        .thenAnswer((_) => throw exception);
    await subscriptionManager.initialize();
    verifyNever(exception.message);
  });

  test("Initialize ignores offline error", () async {
    var exception = MockPlatformException();
    when(exception.code)
        .thenReturn(PurchasesErrorCode.offlineConnectionError.index.toString());
    when(appManager.purchasesWrapper.getCustomerInfo())
        .thenAnswer((_) => throw exception);
    await subscriptionManager.initialize();
    verifyNever(exception.message);
  });

  test("Initialize ignores user account error", () async {
    var exception = MockPlatformException();
    when(exception.code).thenReturn(
        PurchasesErrorCode.purchaseNotAllowedError.index.toString());
    when(appManager.purchasesWrapper.getCustomerInfo())
        .thenAnswer((_) => throw exception);
    await subscriptionManager.initialize();
    verifyNever(exception.message);
  });

  test("Initialize ignores receipt in use error", () async {
    var exception = MockPlatformException();
    when(exception.code).thenReturn(
        PurchasesErrorCode.receiptAlreadyInUseError.index.toString());
    when(appManager.purchasesWrapper.getCustomerInfo())
        .thenAnswer((_) => throw exception);
    await subscriptionManager.initialize();
    verifyNever(exception.message);
  });

  test("Initialize logs error", () async {
    var exception = MockPlatformException();
    when(exception.code)
        .thenReturn(PurchasesErrorCode.apiEndpointBlocked.index.toString());
    when(exception.message).thenReturn("Test");
    when(appManager.purchasesWrapper.getCustomerInfo())
        .thenAnswer((_) => throw exception);
    await subscriptionManager.initialize();
    verify(exception.message).called(1);
  });

  test("Successful restore error sets state to pro", () async {
    var entitlementInfo = MockEntitlementInfo();
    when(entitlementInfo.isActive).thenReturn(true);

    var entitlementInfos = MockEntitlementInfos();
    when(entitlementInfos.all).thenReturn({
      "pro": entitlementInfo,
    });

    var purchaserInfo = MockCustomerInfo();
    when(purchaserInfo.entitlements).thenReturn(entitlementInfos);

    when(appManager.purchasesWrapper.restorePurchases())
        .thenAnswer((_) => Future.value(purchaserInfo));

    var restoreResult = await subscriptionManager.restoreSubscription();
    expect(restoreResult, RestoreSubscriptionResult.success);
    expect(subscriptionManager.isPro, isTrue);
  });

  test("Restore error sets state to free", () async {
    when(appManager.purchasesWrapper.restorePurchases())
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

    var purchaserInfo = MockCustomerInfo();
    when(purchaserInfo.entitlements).thenReturn(entitlementInfos);

    when(appManager.purchasesWrapper.restorePurchases())
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

    var purchaserInfo = MockCustomerInfo();
    when(purchaserInfo.entitlements).thenReturn(entitlementInfos);

    when(appManager.purchasesWrapper.restorePurchases())
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
