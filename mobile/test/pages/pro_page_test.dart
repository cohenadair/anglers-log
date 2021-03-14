import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

class MockPackage extends Mock implements Package {}

class MockProduct extends Mock implements Product {}

void main() {
  MockAppManager appManager;
  MockPackage monthlyPackage;
  MockPackage yearlyPackage;

  setUp(() {
    appManager = MockAppManager(
      mockIoWrapper: true,
      mockSubscriptionManager: true,
    );

    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => MockStream<void>());
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    var monthlyProduct = MockProduct();
    when(monthlyProduct.priceString).thenReturn("\$2.99");
    monthlyPackage = MockPackage();
    when(monthlyPackage.product).thenReturn(monthlyProduct);

    var yearlyProduct = MockProduct();
    when(yearlyProduct.priceString).thenReturn("\$19.99");
    yearlyPackage = MockPackage();
    when(yearlyPackage.product).thenReturn(yearlyProduct);

    when(appManager.mockSubscriptionManager.subscriptions()).thenAnswer((_) =>
        Future.value(Subscriptions(
            Subscription(monthlyPackage, 7), Subscription(yearlyPackage, 14))));
  });

  testWidgets("Loading widget shows while fetching subscriptions, then options",
      (tester) async {
    when(appManager.mockSubscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.delayed(
        Duration(milliseconds: 50),
        () => Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);

    // Wait for subscriptions to be fetched.
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });

  testWidgets("Loading widget shows while a purchase is pending, then success",
      (tester) async {
    when(appManager.mockSubscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.mockSubscriptionManager.purchaseSubscription(any))
        .thenAnswer((_) => Future.delayed(Duration(milliseconds: 50), () {}));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(Duration(milliseconds: 50));
    await tester.tap(find.text("Billed monthly"));
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.text("Congratulations, you are an Anglers' Log Pro user!"),
        findsOneWidget);
  });

  testWidgets("Subscription options are not shown if user is already pro",
      (tester) async {
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    expect(find.text("Congratulations, you are an Anglers' Log Pro user!"),
        findsOneWidget);
  });

  testWidgets("Error shown if error fetching subscriptions", (tester) async {
    when(appManager.mockSubscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(
      find.text("Unable to fetch subscription options. Please ensure your"
          " device is connected to the internet and try again."),
      findsOneWidget,
    );
  });

  testWidgets("Loading widget shows while a restore is pending, then success",
      (tester) async {
    when(appManager.mockSubscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.mockSubscriptionManager.restoreSubscription()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50),
            () => RestoreSubscriptionResult.success));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(Duration(milliseconds: 50));
    expect(
      tapRichTextContaining(
          tester, "Purchased Pro on another device? Restore.", "Restore."),
      isTrue,
    );
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(find.text("Congratulations, you are an Anglers' Log Pro user!"),
        findsOneWidget);
  });

  testWidgets("No purchases found when restoring on iOS", (tester) async {
    when(appManager.mockIoWrapper.isAndroid).thenReturn(false);
    when(appManager.mockSubscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.mockSubscriptionManager.restoreSubscription()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50),
            () => RestoreSubscriptionResult.noSubscriptionsFound));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(Duration(milliseconds: 50));
    expect(
      tapRichTextContaining(
          tester, "Purchased Pro on another device? Restore.", "Restore."),
      isTrue,
    );
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(
      find.text("There were no previous purchases found. Please ensure "
          "you are signed in to the same Apple ID with which you made the "
          "original purchase."),
      findsOneWidget,
    );
  });

  testWidgets("No purchases found when restoring on Android", (tester) async {
    when(appManager.mockIoWrapper.isAndroid).thenReturn(true);
    when(appManager.mockSubscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.mockSubscriptionManager.restoreSubscription()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 50),
            () => RestoreSubscriptionResult.noSubscriptionsFound));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(Duration(milliseconds: 50));
    expect(
      tapRichTextContaining(
          tester, "Purchased Pro on another device? Restore.", "Restore."),
      isTrue,
    );
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(
      find.text("There were no previous purchases found. Please ensure you"
          " are signed in to the same Google account with which you made the"
          " original purchase."),
      findsOneWidget,
    );
  });

  testWidgets("Generic error when restoring", (tester) async {
    when(appManager.mockIoWrapper.isAndroid).thenReturn(true);
    when(appManager.mockSubscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.mockSubscriptionManager.restoreSubscription()).thenAnswer(
        (_) => Future.delayed(
            Duration(milliseconds: 50), () => RestoreSubscriptionResult.error));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(Duration(milliseconds: 50));
    expect(
      tapRichTextContaining(
          tester, "Purchased Pro on another device? Restore.", "Restore."),
      isTrue,
    );
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);
    await tester.pumpAndSettle(Duration(milliseconds: 50));

    expect(
      find.text("Unexpected error occurred. Please ensure your device is "
          "connected to the internet and try again."),
      findsOneWidget,
    );
  });
}
