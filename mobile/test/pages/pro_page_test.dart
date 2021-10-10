import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockPackage monthlyPackage;
  late MockPackage yearlyPackage;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    var monthlyProduct = MockProduct();
    when(monthlyProduct.priceString).thenReturn("\$2.99");
    monthlyPackage = MockPackage();
    when(monthlyPackage.product).thenReturn(monthlyProduct);

    var yearlyProduct = MockProduct();
    when(yearlyProduct.priceString).thenReturn("\$19.99");
    yearlyPackage = MockPackage();
    when(yearlyPackage.product).thenReturn(yearlyProduct);

    when(appManager.subscriptionManager.subscriptions()).thenAnswer((_) =>
        Future.value(Subscriptions(
            Subscription(monthlyPackage, 7), Subscription(yearlyPackage, 14))));
  });

  testWidgets("Loading widget shows while fetching subscriptions, then options",
      (tester) async {
    when(appManager.subscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 50),
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
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });

  testWidgets("Loading widget shows while a purchase is pending, then success",
      (tester) async {
    when(appManager.subscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.subscriptionManager.purchaseSubscription(any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () {}));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.ensureVisible(find.text("Billed monthly"));
    await tester.tap(find.text("Billed monthly"));
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.subscriptionManager.isPro).thenReturn(true);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Congratulations, you are an Anglers' Log Pro user!"),
        findsOneWidget);
  });

  testWidgets("Subscription options are not shown if user is already pro",
      (tester) async {
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    expect(find.text("Congratulations, you are an Anglers' Log Pro user!"),
        findsOneWidget);
  });

  testWidgets("Error shown if error fetching subscriptions", (tester) async {
    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(
      find.text("Unable to fetch subscription options. Please ensure your"
          " device is connected to the internet and try again."),
      findsOneWidget,
    );
  });

  testWidgets("Loading widget shows while a restore is pending, then success",
      (tester) async {
    when(appManager.subscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.subscriptionManager.restoreSubscription()).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50),
            () => RestoreSubscriptionResult.success));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(
      tapRichTextContaining(
          tester, "Purchased Pro on another device? Restore.", "Restore."),
      isTrue,
    );
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.subscriptionManager.isPro).thenReturn(true);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Congratulations, you are an Anglers' Log Pro user!"),
        findsOneWidget);
  });

  testWidgets("No purchases found when restoring on iOS", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(false);
    when(appManager.subscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.subscriptionManager.restoreSubscription()).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50),
            () => RestoreSubscriptionResult.noSubscriptionsFound));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(
      tapRichTextContaining(
          tester, "Purchased Pro on another device? Restore.", "Restore."),
      isTrue,
    );
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(
      find.text("There were no previous purchases found. Please ensure "
          "you are signed in to the same Apple ID with which you made the "
          "original purchase."),
      findsOneWidget,
    );
  });

  testWidgets("No purchases found when restoring on Android", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);
    when(appManager.subscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.subscriptionManager.restoreSubscription()).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50),
            () => RestoreSubscriptionResult.noSubscriptionsFound));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(
      tapRichTextContaining(
          tester, "Purchased Pro on another device? Restore.", "Restore."),
      isTrue,
    );
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(
      find.text("There were no previous purchases found. Please ensure you"
          " are signed in to the same Google account with which you made the"
          " original purchase."),
      findsOneWidget,
    );
  });

  testWidgets("Generic error when restoring", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);
    when(appManager.subscriptionManager.subscriptions()).thenAnswer(
      (_) => Future.value(
        Subscriptions(
          Subscription(monthlyPackage, 7),
          Subscription(yearlyPackage, 14),
        ),
      ),
    );
    when(appManager.subscriptionManager.restoreSubscription()).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50),
            () => RestoreSubscriptionResult.error));

    await tester.pumpWidget(Testable(
      (_) => ProPage(),
      appManager: appManager,
    ));

    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(
      tapRichTextContaining(
          tester, "Purchased Pro on another device? Restore.", "Restore."),
      isTrue,
    );
    await tester.pump();

    // Purchase is pending.
    expect(findFirst<AnimatedSwitcher>(tester).child is Loading, isTrue);

    // Wait for purchase to finish.
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(
      find.text("Unexpected error occurred. Please ensure your device is "
          "connected to the internet and try again."),
      findsOneWidget,
    );
  });
}
