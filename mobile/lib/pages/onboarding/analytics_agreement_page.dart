import 'package:flutter/material.dart';

import '../../utils/page_utils.dart';
import 'how_to_feedback_page.dart';
import 'onboarding_page.dart';

class AnalyticsAgreementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      onPressedNextButton: () => push(context, HowToFeedbackPage()),
      children: <Widget>[
        Text("AnalyticsAgreementPage"),
      ],
    );
  }
}
