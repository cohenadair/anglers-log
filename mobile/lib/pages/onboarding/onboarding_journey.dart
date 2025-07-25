import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/onboarding/onboarding_pro_page.dart';
import 'package:mobile/utils/widget_utils.dart';

import '../../channels/migration_channel.dart';
import '../../database/legacy_importer.dart';
import '../../utils/string_utils.dart';
import '../../wrappers/permission_handler_wrapper.dart';
import 'catch_field_picker_page.dart';
import 'how_to_feedback_page.dart';
import 'how_to_manage_fields_page.dart';
import 'location_permission_page.dart';
import 'onboarding_migration_page.dart';

class OnboardingJourney extends StatefulWidget {
  final LegacyJsonResult? legacyJsonResult;
  final VoidCallback? onFinishedMigration;
  final ContextCallback onFinished;

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

  PermissionHandlerWrapper get _permissionHandlerWrapper =>
      PermissionHandlerWrapper.of(context);

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
            builder: (_) => HowToManageFieldsPage(
              onNext: (context) async => Navigator.of(context).pushNamed(
                (await _permissionHandlerWrapper.isLocationAlwaysGranted)
                    ? _routeFeedback
                    : _routeLocationPermission,
              ),
            ),
          );
        } else if (name == _routeLocationPermission) {
          return MaterialPageRoute(
            builder: (_) => LocationPermissionPage(
              onNext: (context) =>
                  Navigator.of(context).pushNamed(_routeFeedback),
            ),
          );
        } else if (name == _routeFeedback) {
          return MaterialPageRoute(
            builder: (context) => HowToFeedbackPage(
              nextLabel: SubscriptionManager.get.isFree
                  ? Strings.of(context).next
                  : Strings.of(context).finish,
              onNext: (context) {
                if (SubscriptionManager.get.isFree) {
                  Navigator.of(context).pushNamed(_routePro);
                } else {
                  widget.onFinished(context);
                }
              },
            ),
          );
        } else if (name == _routePro) {
          return MaterialPageRoute(
            builder: (context) => OnboardingProPage(onNext: widget.onFinished),
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
          legacyJsonResult,
          widget.onFinishedMigration,
        ),
        onNext: (context) => Navigator.of(context).pushNamed(_routeCatchFields),
      ),
    );
  }

  Route _buildCatchFieldsRoute() {
    return MaterialPageRoute(
      builder: (_) => CatchFieldPickerPage(
        onNext: (context) =>
            Navigator.of(context).pushNamed(_routeManageFields),
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
