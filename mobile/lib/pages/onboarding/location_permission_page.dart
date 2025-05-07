import 'package:flutter/material.dart';
import 'package:mobile/utils/widget_utils.dart';

import '../../i18n/strings.dart';
import '../../res/dimen.dart';
import '../../res/style.dart';
import '../../utils/permission_utils.dart';
import '../../widgets/button.dart';
import '../../widgets/widget.dart';
import 'onboarding_page.dart';

class LocationPermissionPage extends StatefulWidget {
  final ContextCallback? onNext;

  const LocationPermissionPage({
    this.onNext,
  });

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      onPressedNextButton: widget.onNext,
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
            text: Strings.of(context).setPermissionButton,
            onPressed: () async {
              await requestLocationPermissionIfNeeded(
                context: context,
                requestAlways: false,
              );
              if (context.mounted) {
                widget.onNext?.call(context);
              }
            },
          ),
        ),
        const VerticalSpace(paddingDefault),
      ],
    );
  }
}
