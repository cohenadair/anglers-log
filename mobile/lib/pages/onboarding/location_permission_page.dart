import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../location_monitor.dart';
import '../../res/dimen.dart';
import '../../widgets/button.dart';
import '../../widgets/text.dart';
import '../../widgets/widget.dart';
import '../../wrappers/permission_handler_wrapper.dart';

import 'onboarding_page.dart';

class LocationPermissionPage extends StatelessWidget {
  final VoidCallback onNext;

  LocationPermissionPage({
    this.onNext,
  });

  Widget build(BuildContext context) {
    return OnboardingPage(
      onPressedNextButton: onNext,
      nextButtonEnabled: false,
      children: [
        VerticalSpace(paddingWidget),
        WatermarkLogo(icon: Icons.location_on),
        VerticalSpace(paddingWidgetDouble),
        TitleLabel(
          Strings.of(context).onboardingJourneyLocationAccessTitle,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
        VerticalSpace(paddingWidget),
        Padding(
          padding: insetsHorizontalDefault,
          child: PrimaryLabel(
            Strings.of(context).onboardingJourneyLocationAccessDescription,
            overflow: TextOverflow.visible,
            align: TextAlign.center,
          ),
        ),
        VerticalSpace(paddingWidget),
        Align(
          child: Button(
            text: Strings.of(context).onboardingJourneyLocationAccessButton,
            onPressed: () async {
              if (await PermissionHandlerWrapper.of(context)
                  .requestLocation()) {
                await LocationMonitor.of(context).initialize();
              }
              onNext?.call();
            },
          ),
        ),
        VerticalSpace(paddingWidget),
      ],
    );
  }
}
