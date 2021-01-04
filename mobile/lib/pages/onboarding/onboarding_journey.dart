import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/onboarding/location_permission_page.dart';

import '../../log.dart';
import 'catch_field_picker_page.dart';
import 'how_to_feedback_page.dart';
import 'how_to_manage_fields_page.dart';
import 'welcome_page.dart';

class OnboardingJourney extends StatelessWidget {
  final String _routeWelcome = "/";
  final String _routeCatchFields = "catch_fields";
  final String _routeManageFields = "manage_fields";
  final String _routeLocationPermission = "location_permission";
  final String _routeFeedback = "feedback";

  final _log = Log("OnboardingJourney");

  final VoidCallback onFinished;

  OnboardingJourney({
    this.onFinished,
  }) : assert(onFinished != null);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (routeSettings) {
        var name = routeSettings.name;
        if (name == _routeWelcome) {
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => WelcomePage(
              onStart: () => Navigator.of(context).pushNamed(_routeCatchFields),
              onSkip: onFinished,
            ),
          );
        } else if (name == _routeCatchFields) {
          return MaterialPageRoute(
            builder: (context) => CatchFieldPickerPage(
              onNext: () => Navigator.of(context).pushNamed(_routeManageFields),
            ),
          );
        } else if (name == _routeManageFields) {
          return MaterialPageRoute(
            builder: (context) => HowToManageFieldsPage(
              onNext: () =>
                  Navigator.of(context).pushNamed(_routeLocationPermission),
            ),
          );
        } else if (name == _routeLocationPermission) {
          return MaterialPageRoute(
            builder: (context) => LocationPermissionPage(
              onNext: () => Navigator.of(context).pushNamed(_routeFeedback),
            ),
          );
        } else if (name == _routeFeedback) {
          return MaterialPageRoute(
            builder: (context) => HowToFeedbackPage(
              onNext: onFinished,
            ),
          );
        } else {
          _log.w("Unexpected route $name");
        }

        return null;
      },
    );
  }
}
