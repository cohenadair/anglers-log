import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../app_manager.dart';

class PurchasesWrapper {
  static PurchasesWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).purchasesWrapper;

  void addCustomerInfoUpdateListener(Function(CustomerInfo) listener) =>
      Purchases.addCustomerInfoUpdateListener(listener);

  Future<void> configure(String apiKey) =>
      Purchases.configure(PurchasesConfiguration(apiKey));

  void setLogLevel(LogLevel level) => Purchases.setLogLevel(level);

  Future<Offerings> getOfferings() => Purchases.getOfferings();

  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  Future<LogInResult> logIn(String appUserId) => Purchases.logIn(appUserId);

  Future<CustomerInfo> purchasePackage(Package package) =>
      Purchases.purchasePackage(package);

  Future<bool> get isAnonymous => Purchases.isAnonymous;

  Future<CustomerInfo> logOut() => Purchases.logOut();

  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();
}
