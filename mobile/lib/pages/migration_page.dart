import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/anim.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:adair_flutter_lib/widgets/work_result.dart';
import 'package:flutter/material.dart';

import '../channels/migration_channel.dart';
import '../database/legacy_importer.dart';
import '../utils/string_utils.dart';
import '../widgets/data_importer.dart';
import '../widgets/widget.dart';
import '../wrappers/services_wrapper.dart';

class MigrationPage extends StatefulWidget {
  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  late Future<LegacyJsonResult?> _legacyJsonResult;

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
        Container(height: paddingDefault),
        Text(
          Strings.of(context).migrationPageNothingToDoDescription,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        Container(height: paddingDefault),
        WorkResult.success(
          description: Strings.of(context).migrationPageNothingToDoSuccess,
        ),
      ],
    );
  }

  Widget _buildImporter(LegacyJsonResult legacyResult) {
    return DataImporter(
      importer: LegacyImporter.migrate(legacyResult),
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
