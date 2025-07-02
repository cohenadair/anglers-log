import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:mobile/utils/widget_utils.dart';

import '../../utils/string_utils.dart';
import 'onboarding_page.dart';

class OnboardingProPage extends StatelessWidget {
  final ContextCallback? onNext;

  const OnboardingProPage({
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: SubscriptionManager.get.stream,
      builder: (context, _) {
        return OnboardingPage(
          showAppBar: false,
          nextButtonText: SubscriptionManager.get.isFree
              ? Strings.of(context).onboardingJourneyNotNow
              : Strings.of(context).finish,
          onPressedNextButton: onNext,
          padding: insetsDefault,
          children: const [
            AnglersLogProPage(embedInScrollPage: false),
          ],
        );
      },
    );
  }
}
