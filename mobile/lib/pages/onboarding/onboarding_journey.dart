import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_manager.dart';
import '../../channels/migration_channel.dart';
import '../../database/legacy_importer.dart';
import '../../log.dart';
import 'catch_field_picker_page.dart';
import 'how_to_feedback_page.dart';
import 'how_to_manage_fields_page.dart';
import 'location_permission_page.dart';
import 'migration_page.dart';

class OnboardingJourney extends StatefulWidget {
  final LegacyJsonResult? legacyJsonResult;
  final VoidCallback onFinished;

  OnboardingJourney({
    this.legacyJsonResult,
    required this.onFinished,
  });

  @override
  _OnboardingJourneyState createState() => _OnboardingJourneyState();
}

class _OnboardingJourneyState extends State<OnboardingJourney> {
  static const _routeRoot = "/";
  static const _routeCatchFields = "catch_fields";
  static const _routeManageFields = "manage_fields";
  static const _routeLocationPermission = "location_permission";
  static const _routeFeedback = "feedback";

  final _log = Log("OnboardingJourney");

  AppManager get _appManager => AppManager.of(context);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (routeSettings) {
        var name = routeSettings.name;
        if (name == _routeRoot) {
          if (widget.legacyJsonResult != null) {
            return _buildMigrationPageRoute(widget.legacyJsonResult!);
          } else {
            return _buildCatchFieldsRoute();
          }
        } else if (name == _routeCatchFields) {
          return _buildCatchFieldsRoute();
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

  Route<dynamic> _buildMigrationPageRoute(LegacyJsonResult legacyJsonResult) {
    return MaterialPageRoute(
      builder: (context) => MigrationPage(
        importer: LegacyImporter.migrate(_appManager, legacyJsonResult),
        onNext: () => Navigator.of(context).pushNamed(_routeCatchFields),
      ),
    );
  }

  Route<dynamic> _buildCatchFieldsRoute() {
    return MaterialPageRoute(
      builder: (context) => CatchFieldPickerPage(
        onNext: () => Navigator.of(context).pushNamed(_routeManageFields),
      ),
    );
  }
}
