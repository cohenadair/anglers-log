import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/onboarding/onboarding_pro_page.dart';
import 'package:mobile/subscription_manager.dart';

import '../../app_manager.dart';
import '../../channels/migration_channel.dart';
import '../../database/legacy_importer.dart';
import '../../log.dart';
import '../../wrappers/permission_handler_wrapper.dart';
import 'catch_field_picker_page.dart';
import 'how_to_feedback_page.dart';
import 'how_to_manage_fields_page.dart';
import 'location_permission_page.dart';
import 'onboarding_migration_page.dart';

class OnboardingJourney extends StatefulWidget {
  final LegacyJsonResult? legacyJsonResult;
  final VoidCallback? onFinishedMigration;
  final VoidCallback onFinished;

  const OnboardingJourney({
    this.legacyJsonResult,
    this.onFinishedMigration,
    required this.onFinished,
  });

  @override
  OnboardingJourneyState createState() => OnboardingJourneyState();
}

class OnboardingJourneyState extends State<OnboardingJourney> {
  static const _routeRoot = "/";
  static const _routeMigrateOrCatchFields = "migrate";
  static const _routeCatchFields = "catch_fields";
  static const _routeManageFields = "manage_fields";
  static const _routeLocationPermission = "location_permission";
  static const _routeFeedback = "feedback";
  static const _routePro = "pro";

  static const _log = Log("OnboardingJourney");

  AppManager get _appManager => AppManager.of(context);

  PermissionHandlerWrapper get _permissionHandlerWrapper =>
      PermissionHandlerWrapper.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (routeSettings) {
        var name = routeSettings.name;
        if (name == _routeRoot) {
          return _buildMigrateOrCatchFields();
        } else if (name == _routeMigrateOrCatchFields) {
          return _buildMigrateOrCatchFields();
        } else if (name == _routeCatchFields) {
          return _buildCatchFieldsRoute();
        } else if (name == _routeManageFields) {
          return MaterialPageRoute(
            builder: (context) => HowToManageFieldsPage(
              onNext: () async => Navigator.of(context).pushNamed(
                  (await _permissionHandlerWrapper.isLocationAlwaysGranted)
                      ? _routeFeedback
                      : _routeLocationPermission),
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
              nextLabel: _subscriptionManager.isFree
                  ? Strings.of(context).next
                  : Strings.of(context).finish,
              onNext: () {
                if (_subscriptionManager.isFree) {
                  Navigator.of(context).pushNamed(_routePro);
                } else {
                  widget.onFinished();
                }
              },
            ),
          );
        } else if (name == _routePro) {
          return MaterialPageRoute(
            builder: (context) => OnboardingProPage(
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

  Route _buildMigrationPageRoute(LegacyJsonResult legacyJsonResult) {
    return MaterialPageRoute(
      builder: (context) => OnboardingMigrationPage(
        importer: LegacyImporter.migrate(
            _appManager, legacyJsonResult, widget.onFinishedMigration),
        onNext: () => Navigator.of(context).pushNamed(_routeCatchFields),
      ),
    );
  }

  Route _buildCatchFieldsRoute() {
    return MaterialPageRoute(
      builder: (context) => CatchFieldPickerPage(
        onNext: () => Navigator.of(context).pushNamed(_routeManageFields),
      ),
    );
  }

  Route _buildMigrateOrCatchFields() {
    if (widget.legacyJsonResult != null) {
      return _buildMigrationPageRoute(widget.legacyJsonResult!);
    } else {
      return _buildCatchFieldsRoute();
    }
  }
}
