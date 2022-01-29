import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile/widgets/ad_banner_widget.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockBannerAd bannerAd;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.googleMobileAdsWrapper.adWidget(ad: anyNamed("ad")))
        .thenReturn(const Text("Ad Widget"));
    when(appManager.googleMobileAdsWrapper
            .getCurrentOrientationAnchoredAdaptiveBannerAdSize(any))
        .thenAnswer(
      (_) => Future.value(
        AnchoredAdaptiveBannerAdSize(
          Orientation.landscape,
          width: 50,
          height: 50,
        ),
      ),
    );

    bannerAd = MockBannerAd();
    when(bannerAd.size).thenReturn(AdSize.banner);
    when(bannerAd.load()).thenAnswer((_) => Future.value(null));
    when(appManager.googleMobileAdsWrapper.bannerAd(
      adUnitId: anyNamed("adUnitId"),
      size: anyNamed("size"),
      request: anyNamed("request"),
      listener: anyNamed("listener"),
    )).thenReturn(bannerAd);

    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    when(appManager.propertiesManager.adUnitIdApple).thenReturn("Apple");
    when(appManager.propertiesManager.adUnitIdAndroid).thenReturn("Android");

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  testWidgets("Subscription changes updates state", (tester) async {
    var isPro = true;
    var controller = StreamController.broadcast(sync: true);
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.subscriptionManager.isPro).thenAnswer((_) => isPro);

    await pumpContext(tester, (_) => AdBannerWidget(), appManager: appManager);

    // Starts as pro.
    expect(find.byType(Empty), findsOneWidget);
    expect(find.text("Ad Widget"), findsNothing);

    // Pro to free.
    isPro = false;
    await tester.runAsync(() {
      controller.add(null);
      return Future.delayed(const Duration(milliseconds: 50));
    });

    // Ensure widget is marked as loaded.
    var result = verify(appManager.googleMobileAdsWrapper.bannerAd(
      adUnitId: anyNamed("adUnitId"),
      size: anyNamed("size"),
      request: anyNamed("request"),
      listener: captureAnyNamed("listener"),
    ));
    result.called(1);
    (result.captured.first as BannerAdListener).onAdLoaded?.call(bannerAd);

    await tester.pumpAndSettle();
    expect(find.byType(Empty), findsNothing);
    expect(find.text("Ad Widget"), findsOneWidget);

    // Free to pro.
    isPro = true;
    controller.add(null);
    await tester.pumpAndSettle();
    expect(find.byType(Empty), findsOneWidget);
    expect(find.text("Ad Widget"), findsNothing);
  });

  testWidgets("Empty widget shown if ad sizing failed", (tester) async {
    when(appManager.googleMobileAdsWrapper
            .getCurrentOrientationAnchoredAdaptiveBannerAdSize(any))
        .thenAnswer((_) => Future.value(null));
    when(appManager.subscriptionManager.isPro).thenAnswer((_) => false);

    await pumpContext(tester, (_) => AdBannerWidget(), appManager: appManager);

    expect(find.byType(Empty), findsOneWidget);
    expect(find.text("Ad Widget"), findsNothing);
  });

  testWidgets("Ad is disposed if it couldn't load", (tester) async {
    when(appManager.subscriptionManager.isPro).thenAnswer((_) => false);

    await pumpContext(tester, (_) => AdBannerWidget(), appManager: appManager);

    var result = verify(appManager.googleMobileAdsWrapper.bannerAd(
      adUnitId: anyNamed("adUnitId"),
      size: anyNamed("size"),
      request: anyNamed("request"),
      listener: captureAnyNamed("listener"),
    ));
    result.called(1);
    (result.captured.first as BannerAdListener)
        .onAdFailedToLoad
        ?.call(bannerAd, LoadAdError(5, "Domain", "Message", null));

    expect(find.byType(Empty), findsOneWidget);
    expect(find.text("Ad Widget"), findsNothing);
    verify(bannerAd.dispose()).called(1);
  });
}
