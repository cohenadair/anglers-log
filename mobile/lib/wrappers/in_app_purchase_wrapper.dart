import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../app_manager.dart';

class InAppPurchaseWrapper {
  static InAppPurchaseWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).inAppPurchaseWrapper;

  Stream<List<PurchaseDetails>> get purchaseUpdatedStream =>
      InAppPurchaseConnection.instance.purchaseUpdatedStream;

  Future<bool> isAvailable() => InAppPurchaseConnection.instance.isAvailable();

  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) =>
      InAppPurchaseConnection.instance.queryProductDetails(ids);
}
