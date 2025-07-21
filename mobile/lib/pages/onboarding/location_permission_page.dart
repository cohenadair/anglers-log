import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/widget_utils.dart';

import '../../res/style.dart';
import '../../utils/permission_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/button.dart';
import '../../widgets/widget.dart';
import 'onboarding_page.dart';

class LocationPermissionPage extends StatefulWidget {
  final ContextCallback? onNext;

  const LocationPermissionPage({this.onNext});

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
        Container(height: paddingDefault),
        WatermarkLogo(
          icon: Icons.location_on,
          title: Strings.of(context).onboardingJourneyLocationAccessTitle,
        ),
        Container(height: paddingDefault),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).onboardingJourneyLocationAccessDescription,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: stylePrimary(context),
          ),
        ),
        Container(height: paddingDefault),
        Align(
          child: Button(
            text: Strings.of(context).setPermissionButton,
            onPressed: () async {
              var result = await requestLocationPermissionWithResultIfNeeded(
                context,
              );
              if (context.mounted &&
                  result != RequestLocationResult.inProgress) {
                widget.onNext?.call(context);
              }
            },
          ),
        ),
        Container(height: paddingDefault),
      ],
    );
  }
}
