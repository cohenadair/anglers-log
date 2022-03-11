import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mobile/wrappers/google_mobile_ads_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';

import '../log.dart';
import '../subscription_manager.dart';

class AdBannerWidget extends StatefulWidget {
  @override
  AdBannerWidgetState createState() => AdBannerWidgetState();
}

class AdBannerWidgetState extends State<AdBannerWidget> {
  final _log = const Log("AdBannerWidget");

  BannerAd? _ad;
  bool _isLoaded = false;
  late StreamSubscription<void> _subscriptionStream;

  GoogleMobileAdsWrapper get _adsWrapper => GoogleMobileAdsWrapper.of(context);

  IoWrapper get _ioWrapper => IoWrapper.of(context);

  PropertiesManager get _propertiesManager => PropertiesManager.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  @override
  void initState() {
    super.initState();

    _subscriptionStream = _subscriptionManager.stream.listen((_) {
      if (_subscriptionManager.isPro) {
        setState(() => _ad = null);
      } else {
        _loadAd();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  @override
  void dispose() {
    super.dispose();
    _subscriptionStream.cancel();
    _ad?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null || !_isLoaded) {
      return const Empty();
    }

    return Container(
      color: Colors.transparent,
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: _adsWrapper.adWidget(ad: _ad!),
    );
  }

  Future<void> _loadAd() async {
    if (_subscriptionManager.isPro) {
      return;
    }

    var size =
        await _adsWrapper.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      _log.d("Unable to get height of anchored banner.");
      return;
    }

    _ad = _adsWrapper.bannerAd(
      adUnitId: _ioWrapper.isAndroid
          ? _propertiesManager.adUnitIdAndroid
          : _propertiesManager.adUnitIdApple,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {
          _ad = ad as BannerAd;
          _isLoaded = true;
        }),
        onAdFailedToLoad: (ad, error) {
          _log.e(StackTrace.current, "Error loading banner: $error");
          ad.dispose();
        },
      ),
    );

    return _ad!.load();
  }
}
