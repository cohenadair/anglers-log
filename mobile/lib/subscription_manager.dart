import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'log.dart';
import 'user_preference_manager.dart';
import 'utils/void_stream_controller.dart';
import 'wrappers/purchases_wrapper.dart';
import 'wrappers/io_wrapper.dart';

enum SubscriptionState {
  /// Subscription is being processed by the platform's storefront. This state
  /// is only temporary for a short period after a purchase is made.
  pending,
  pro,
  free,
}

enum FetchPastPurchasesResult {
  error,
  noneFound,
  success,
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
  final _controller = VoidStreamController();

  final AppManager _appManager;

  var _state = SubscriptionState.free;

  SubscriptionManager(this._appManager);

  PurchasesWrapper get _iapWrapper => _appManager.purchasesWrapper;

  IoWrapper get _ioWrapper => _appManager.ioWrapper;

  UserPreferenceManager get _userPreferenceManager =>
      _appManager.userPreferenceManager;

  bool get isPro => _state == SubscriptionState.pro;
  // bool get isPro => true;

  /// A [Stream] that fires events when [state] updates. Listeners should
  /// access the [state] property directly, as it will always have a valid
  /// value, unlike the [AsyncSnapshot] passed to the listener function.
  Stream<SubscriptionState> get stream => _controller.stream;

  Future<void> initialize() async {
    // Fetch the latest purchase data so we're always up to date. Note that we
    // cannot do this here on iOS because Apple requires previous purchases to
    // be restored via a "Restore" button, rather than automatically in the
    // background.
    if (_ioWrapper.isAndroid) {
      await fetchPastPurchases();
    }

    // Listen for purchase updates.
    // TODO
    // _iapWrapper.purchaseUpdatedStream.listen(_processPurchaseDetails);
  }

  Future<bool> purchaseSubscription(Subscription sub) {
    // From here, the purchase is handled by the App Store and Google Play.
    // Updates are delivered to purchaseUpdatedStream.
    // TODO
    // return _iapWrapper.buyNonConsumable(
    //   purchaseParam: PurchaseParam(
    //     productDetails: sub.details,
    //   ),
    // );
    return Future.value(false);
  }

  Future<Subscriptions> subscriptions() async {
    // TODO
    // if (!(await _iapWrapper.isAvailable())) {
    //   _log.e("Store is unavailable");
    //   return null;
    // }

    // var response = await _iapWrapper.queryProductDetails(_ioWrapper.isAndroid
    //     ? {_idMonthlyGoogle, _idYearlyGoogle}
    //     : {_idMonthlyApple, _idYearlyApple});
    //
    // if (response.notFoundIDs.isNotEmpty) {
    //   _log.e("Product IDs not found: ${response.notFoundIDs}");
    //   return null;
    // }
    //
    // Subscription monthly;
    // Subscription yearly;
    //
    // for (var product in response.productDetails) {
    //   switch (product.id) {
    //     case _idYearlyApple:
    //       yearly = Subscription(_trialDaysYearly, product);
    //       break;
    //     case _idMonthlyApple:
    //       monthly = Subscription(_trialDaysMonthly, product);
    //       break;
    //     case _idYearlyGoogle:
    //       yearly = Subscription(_trialDaysYearly, product);
    //       break;
    //     case _idMonthlyGoogle:
    //       monthly = Subscription(_trialDaysMonthly, product);
    //       break;
    //     default:
    //       _log.e("Invalid product ID: ${product.id}");
    //   }
    // }
    //
    // if (monthly == null || yearly == null) {
    //   _log.e("Failed to get all subscriptions");
    //   return null;
    // }
    //
    // return Subscriptions(monthly, yearly);
    return null;
  }

  // TODO
  // void _processPurchaseDetails(List<PurchaseDetails> purchases) async {
  //   if (purchases.isEmpty) {
  //     _log.d("No purchases found");
  //   }
  //
  //   for (var purchase in purchases) {
  //     _log.d("PurchaseDetails{id=${purchase.productID}; "
  //         "status=${purchase.status}; "
  //         "error=${purchase.error?.code}}");
  //
  //     switch (purchase.status) {
  //       case PurchaseStatus.pending:
  //         _setState(SubscriptionState.pending);
  //         break;
  //       case PurchaseStatus.purchased:
  //         _setState(SubscriptionState.pro);
  //         break;
  //       case PurchaseStatus.error:
  //         // Happens if the user cancels or if there was a payment problem.
  //         // Payment issues are shown to the user via system UI.
  //         _setState(SubscriptionState.free);
  //         break;
  //     }
  //
  //     // Required by both stores.
  //     if (purchase.pendingCompletePurchase) {
  //       await _iapWrapper.completePurchase(purchase);
  //     }
  //   }
  // }

  /// Fetches past purchases for the current device. Note that on iOS this may
  /// prompt users to enter their App Store credentials and therefore, should
  /// only be called after user interaction, such as tapping a "Restore" button.
  Future<FetchPastPurchasesResult> fetchPastPurchases() async {
    // TODO
    // var response = await _iapWrapper.queryPastPurchases();
    //
    // if (response.error == null) {
    //   if (response.pastPurchases.isEmpty) {
    //     return FetchPastPurchasesResult.noneFound;
    //   } else {
    //     _processPurchaseDetails(response.pastPurchases);
    //     return FetchPastPurchasesResult.success;
    //   }
    // }

    // Something went wrong, set the state to what is already in preferences for
    // now.
    // TODO
    // _log.d("Error fetching past purchases: ${response.error.message}");
    _setState(_userPreferenceManager.isPro
        ? SubscriptionState.pro
        : SubscriptionState.free);

    return FetchPastPurchasesResult.error;
  }

  void _setState(SubscriptionState state) {
    _log.d("Update state: $state");
    _state = state;
    _userPreferenceManager.isPro = isPro;
    _controller.notify();
  }
}

class Subscription {
  final int trialLengthDays;

  Subscription(this.trialLengthDays);

  // TODO
  String get price => "\$2.99";
}

/// A convenience class that stores subscription options. A single class like
/// this is easier to manage than a collection of subscriptions, especially
/// when the options shouldn't change.
class Subscriptions {
  final Subscription monthly;
  final Subscription yearly;

  Subscriptions(this.monthly, this.yearly);
}
