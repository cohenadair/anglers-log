import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import '../app_manager.dart';

class InAppReviewWrapper {
  static InAppReviewWrapper of(BuildContext context) =>
      AppManager.get.inAppReviewWrapper;

  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  Future<void> requestReview() => InAppReview.instance.requestReview();
}
