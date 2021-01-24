import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../res/dimen.dart';
import '../../widgets/button.dart';
import '../../widgets/text.dart';
import '../../widgets/widget.dart';
import 'onboarding_page.dart';

class WelcomePage extends StatelessWidget {
  static const _logoSize = 150.0;

  final VoidCallback onStart;

  WelcomePage({
    this.onStart,
  }) : assert(onStart != null);

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      padding: insetsDefault,
      children: <Widget>[
        VerticalSpace(paddingWidget),
        ClipOval(
          child: Image(
            image: AssetImage("assets/logo.png"),
            width: _logoSize,
            height: _logoSize,
          ),
        ),
        VerticalSpace(paddingWidget),
        TitleLabel(
          Strings.of(context).onboardingJourneyWelcomeTitle,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
        VerticalSpace(paddingWidget),
        PrimaryLabel(
          Strings.of(context).onboardingJourneyStartDescription,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
        VerticalSpace(paddingWidget),
        Align(
          child: Button(
            text: Strings.of(context).onboardingJourneyStartButton,
            onPressed: onStart,
          ),
        ),
        VerticalSpace(paddingWidget),
      ],
    );
  }
}
