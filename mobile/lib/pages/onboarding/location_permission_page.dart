import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../location_monitor.dart';
import '../../res/dimen.dart';
import '../../res/style.dart';
import '../../widgets/button.dart';
import '../../widgets/text.dart';
import '../../widgets/widget.dart';
import '../../wrappers/permission_handler_wrapper.dart';
import 'onboarding_page.dart';

class LocationPermissionPage extends StatelessWidget {
  final VoidCallback? onNext;

  const LocationPermissionPage({
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      onPressedNextButton: onNext,
      nextButtonEnabled: false,
      children: [
        const VerticalSpace(paddingDefault),
        WatermarkLogo(
          icon: Icons.location_on,
          title: Strings.of(context).onboardingJourneyLocationAccessTitle,
        ),
        const VerticalSpace(paddingDefault),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).onboardingJourneyLocationAccessDescription,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: stylePrimary(context),
          ),
        ),
        const VerticalSpace(paddingDefault),
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
        const VerticalSpace(paddingDefault),
      ],
    );
  }
}
