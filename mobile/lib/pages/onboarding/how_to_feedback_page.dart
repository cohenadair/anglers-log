import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import 'onboarding_page.dart';

class HowToFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      nextButtonText: Strings.of(context).finish,
      onPressedNextButton: () =>
          Navigator.of(context).popUntil((route) => route.isFirst),
      children: <Widget>[
        Text("HowToFeedbackPage"),
      ],
    );
  }
}
