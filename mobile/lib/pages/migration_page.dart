import 'package:flutter/material.dart';

import '../app_manager.dart';
import '../channels/migration_channel.dart';
import '../database/legacy_importer.dart';
import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../widgets/data_importer.dart';
import '../widgets/widget.dart';
import '../widgets/work_result.dart';
import '../wrappers/services_wrapper.dart';
import 'scroll_page.dart';

class MigrationPage extends StatefulWidget {
  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  late Future<LegacyJsonResult?> _legacyJsonResult;

  AppManager get _appManager => AppManager.of(context);

  ServicesWrapper get _servicesWrapper => ServicesWrapper.of(context);

  @override
  void initState() {
    super.initState();
    _legacyJsonResult = legacyJson(_servicesWrapper);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: TransparentAppBar(context),
      extendBodyBehindAppBar: true,
      padding: insetsHorizontalDefaultBottomDefault,
      children: [
        FutureBuilder<LegacyJsonResult?>(
          future: _legacyJsonResult,
          builder: (context, snapshot) {
            Widget child;
            if (snapshot.connectionState != ConnectionState.done) {
              child = const Loading();
            } else if (snapshot.hasData) {
              child = _buildImporter(snapshot.data!);
            } else {
              child = _buildMigrationAlreadyDone();
            }

            return AnimatedSwitcher(
              duration: animDurationDefault,
              child: child,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMigrationAlreadyDone() {
    return Column(
      children: [
        Center(
          child: WatermarkLogo(
            icon: Icons.sync,
            title: Strings.of(context).migrationPageTitle,
          ),
        ),
        const VerticalSpace(paddingDefault),
        Text(
          Strings.of(context).migrationPageNothingToDoDescription,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const VerticalSpace(paddingDefault),
        WorkResult.success(
            description: Strings.of(context).migrationPageNothingToDoSuccess),
      ],
    );
  }

  Widget _buildImporter(LegacyJsonResult legacyResult) {
    return DataImporter(
      importer: LegacyImporter.migrate(_appManager, legacyResult),
      watermarkIcon: Icons.sync,
      titleText: Strings.of(context).migrationPageTitle,
      descriptionText: Strings.of(context).migrationPageDescription,
      errorText: Strings.of(context).migrationPageError,
      loadingText: Strings.of(context).migrationPageLoading,
      successText: Strings.of(context).migrationPageSuccess,
      feedbackPageTitle: Strings.of(context).migrationPageFeedbackTitle,
    );
  }
}
