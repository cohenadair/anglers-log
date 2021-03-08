import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../app_manager.dart';

class PurchasesWrapper {
  static PurchasesWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).purchasesWrapper;

  void addPurchaserInfoUpdateListener(Function(PurchaserInfo) listener) =>
      Purchases.addPurchaserInfoUpdateListener(listener);

  Future<void> setup(String apiKey) => Purchases.setup(apiKey);

  // ignore: avoid_positional_boolean_parameters
  void setAllowSharingStoreAccount(bool allowSharing) =>
      Purchases.setAllowSharingStoreAccount(allowSharing);

  // ignore: avoid_positional_boolean_parameters
  void setDebugEnabled(bool enabled) => Purchases.setDebugLogsEnabled(enabled);

  Future<Offerings> getOfferings() => Purchases.getOfferings();

  Future<PurchaserInfo> getPurchaserInfo() => Purchases.getPurchaserInfo();

  Future<PurchaserInfo> identify(String appUserId) =>
      Purchases.identify(appUserId);

  Future<PurchaserInfo> purchasePackage(Package package) =>
      Purchases.purchasePackage(package);

  Future<PurchaserInfo> reset() => Purchases.reset();

  Future<PurchaserInfo> restoreTransactions() =>
      Purchases.restoreTransactions();
}
