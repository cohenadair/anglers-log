import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'log.dart';
import 'wrappers/in_app_purchase_wrapper.dart';
import 'wrappers/io_wrapper.dart';

enum SubscriptionEvent {
  onSubscribe,
  onUnsubscribe,
}

class SubscriptionManager {
  static SubscriptionManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).subscriptionManager;

  static const _idYearlyApple = "pro_yearly";
  static const _idMonthlyApple = "pro_monthly";
  static const _idYearlyGoogle = "yearly_pro";
  static const _idMonthlyGoogle = "monthly_pro";

  static const _trialDaysYearly = 14;
  static const _trialDaysMonthly = 7;

  final _log = Log("SubscriptionManager");
  final _controller = StreamController<SubscriptionEvent>.broadcast();

  final AppManager _appManager;

  bool _isPro = false;

  SubscriptionManager(this._appManager);

  InAppPurchaseWrapper get _iapWrapper => _appManager.inAppPurchaseWrapper;

  IoWrapper get _ioWrapper => _appManager.ioWrapper;

  bool get isPro => true;

  Stream<SubscriptionEvent> get stream => _controller.stream;

  Future<void> initialize() async {
    _iapWrapper.purchaseUpdatedStream.listen((purchases) {
      print("Purchases updated");

      if (purchases.isEmpty) {
        print("User is not pro");
        _isPro = false;
      } else {
        print("User is pro");
        _isPro = true;
      }
    });
  }

  Future<bool> isStoreAvailable() => _iapWrapper.isAvailable();

  Future<Subscriptions> subscriptionOptions() async {
    if (!(await isStoreAvailable())) {
      _log.e("Store is unavailable");
      return null;
    }

    var response = await _iapWrapper.queryProductDetails(_ioWrapper.isAndroid
        ? {_idMonthlyGoogle, _idYearlyGoogle}
        : {_idMonthlyApple, _idYearlyApple});

    if (response.notFoundIDs.isNotEmpty) {
      _log.e("Product IDs not found: ${response.notFoundIDs}");
      return null;
    }

    Subscription monthly;
    Subscription yearly;

    for (var product in response.productDetails) {
      switch (product.id) {
        case _idYearlyApple:
          yearly = Subscription(product.price, _trialDaysYearly);
          break;
        case _idMonthlyApple:
          monthly = Subscription(product.price, _trialDaysMonthly);
          break;
        case _idYearlyGoogle:
          yearly = Subscription(product.price, _trialDaysYearly);
          break;
        case _idMonthlyGoogle:
          monthly = Subscription(product.price, _trialDaysMonthly);
          break;
        default:
          _log.e("Invalid product ID: ${product.id}");
      }
    }

    if (monthly == null || yearly == null) {
      _log.e("Failed to get all subscriptions");
      return null;
    }

    return Subscriptions(monthly, yearly);
  }
}

class Subscription {
  final String price;
  final int trialLengthDays;

  Subscription(this.price, this.trialLengthDays);
}

/// A convenience class that stores subscription options. A single class like
/// this is easier to manage than a collection of subscriptions, especially
/// when the options shouldn't change.
class Subscriptions {
  final Subscription monthly;
  final Subscription yearly;

  Subscriptions(this.monthly, this.yearly);
}
