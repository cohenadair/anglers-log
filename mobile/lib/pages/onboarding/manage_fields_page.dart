import 'package:flutter/material.dart';

import '../../utils/page_utils.dart';
import 'analytics_agreement_page.dart';
import 'onboarding_page.dart';

class ManageFieldsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      onPressedNextButton: () => push(context, AnalyticsAgreementPage()),
      children: <Widget>[
        Text("ManageFields"),
      ],
    );
  }
}
