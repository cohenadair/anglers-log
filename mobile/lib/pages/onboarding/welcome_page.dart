import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../res/dimen.dart';
import '../../utils/page_utils.dart';
import '../../widgets/button.dart';
import '../../widgets/text.dart';
import '../../widgets/widget.dart';
import 'catch_field_picker_page.dart';
import 'onboarding_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      children: <Widget>[
        VerticalSpace(paddingWidget),
        WatermarkLogo(
          icon: Icons.ac_unit,
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
            onPressed: () => push(context, CatchFieldPickerPage()),
          ),
        ),
        VerticalSpace(paddingWidgetSmall),
        Align(
          child: SmallTextButton(
            text: Strings.of(context).onboardingJourneySkip,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        VerticalSpace(paddingWidget),
      ],
    );
  }
}
