import 'package:flutter/material.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/utils/widget_utils.dart';

import '../../res/dimen.dart';
import '../../utils/string_utils.dart';
import 'onboarding_page.dart';

class OnboardingProPage extends StatelessWidget {
  final ContextCallback? onNext;

  const OnboardingProPage({
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    var subscriptionManager = SubscriptionManager.of(context);
    return StreamBuilder<void>(
      stream: subscriptionManager.stream,
      builder: (context, _) {
        return OnboardingPage(
          showAppBar: false,
          nextButtonText: subscriptionManager.isFree
              ? Strings.of(context).onboardingJourneyNotNow
              : Strings.of(context).finish,
          onPressedNextButton: onNext,
          padding: insetsDefault,
          children: const [
            ProPage(isEmbeddedInScrollPage: false),
          ],
        );
      },
    );
  }
}
