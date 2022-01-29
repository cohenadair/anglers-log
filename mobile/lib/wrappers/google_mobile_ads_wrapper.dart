import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class GoogleMobileAdsWrapper {
  static GoogleMobileAdsWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).googleMobileAdsWrapper;

  BannerAd bannerAd({
    required AdSize size,
    required String adUnitId,
    required BannerAdListener listener,
    required AdRequest request,
  }) {
    return BannerAd(
      size: size,
      adUnitId: adUnitId,
      listener: listener,
      request: request,
    );
  }

  Widget adWidget({
    Key? key,
    required AdWithView ad,
  }) {
    return AdWidget(key: key, ad: ad);
  }

  Future<AnchoredAdaptiveBannerAdSize?>
      getCurrentOrientationAnchoredAdaptiveBannerAdSize(int width) async {
    return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
  }
}
