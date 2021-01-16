import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_manager.dart';
import '../../channels/migration_channel.dart';
import '../../database/legacy_importer.dart';
import '../../log.dart';
import '../../widgets/widget.dart';
import '../../wrappers/services_wrapper.dart';
import '../landing_page.dart';
import 'catch_field_picker_page.dart';
import 'how_to_feedback_page.dart';
import 'how_to_manage_fields_page.dart';
import 'location_permission_page.dart';
import 'migration_page.dart';
import 'welcome_page.dart';

class OnboardingJourney extends StatefulWidget {
  final VoidCallback onFinished;

  OnboardingJourney({
    this.onFinished,
  }) : assert(onFinished != null);

  @override
  _OnboardingJourneyState createState() => _OnboardingJourneyState();
}

class _OnboardingJourneyState extends State<OnboardingJourney> {
  static const _routeRoot = "/";
  static const _routeWelcome = "welcome";
  static const _routeCatchFields = "catch_fields";
  static const _routeManageFields = "manage_fields";
  static const _routeLocationPermission = "location_permission";
  static const _routeFeedback = "feedback";

  final _log = Log("OnboardingJourney");

  Future<LegacyJsonResult> _legacyJsonFuture;

  AppManager get _appManager => AppManager.of(context);

  ServicesWrapper get _servicesWrapper => ServicesWrapper.of(context);

  @override
  void initState() {
    super.initState();
    _legacyJsonFuture = legacyJson(_servicesWrapper);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LegacyJsonResult>(
      future: _legacyJsonFuture,
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.hasData) {
          child = _buildNavigator(snapshot.data);
        } else {
          child = LandingPage();
        }

        return AnimatedSwitcher(
          duration: defaultAnimationDuration,
          child: child,
        );
      },
    );
  }

  Widget _buildNavigator(LegacyJsonResult legacyJsonResult) {
    return Navigator(
      onGenerateRoute: (routeSettings) {
        var name = routeSettings.name;
        if (name == _routeRoot) {
          if (legacyJsonResult.hasLegacyData) {
            return _buildMigrationPageRoute(legacyJsonResult.json);
          } else {
            return _buildWelcomePageRoute(routeSettings);
          }
        } else if (name == _routeWelcome) {
          return _buildWelcomePageRoute(routeSettings);
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
              onNext: widget.onFinished,
            ),
          );
        } else {
          _log.w("Unexpected route $name");
        }

        return null;
      },
    );
  }

  Route<dynamic> _buildWelcomePageRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (context) {
        return WelcomePage(
          onStart: () => Navigator.of(context).pushNamed(_routeCatchFields),
          onSkip: widget.onFinished,
        );
      },
    );
  }

  Route<dynamic> _buildMigrationPageRoute(Map<String, dynamic> json) {
    return MaterialPageRoute(
      builder: (context) => MigrationPage(
        importer: LegacyImporter.migrate(_appManager, json),
        onNext: () => Navigator.of(context).pushNamed(_routeWelcome),
      ),
    );
  }
}
