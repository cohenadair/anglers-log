import 'package:flutter/material.dart';

import '../../database/legacy_importer.dart';
import '../../i18n/strings.dart';
import '../../res/dimen.dart';
import '../../widgets/data_importer.dart';
import 'onboarding_page.dart';

class MigrationPage extends StatefulWidget {
  final LegacyImporter importer;
  final VoidCallback? onNext;

  const MigrationPage({
    required this.importer,
    this.onNext,
  });

  @override
  _MigrationPageState createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  var _nextEnabled = false;

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      showBackButton: false,
      nextButtonEnabled: _nextEnabled,
      onPressedNextButton: widget.onNext,
      padding: insetsDefault,
      children: [
        DataImporter(
          importer: widget.importer,
          watermarkIcon: Icons.sync,
          titleText: Strings.of(context).migrationPageTitle,
          descriptionText: Strings.of(context).migrationPageDescription,
          errorText: Strings.of(context).migrationPageError,
          loadingText: Strings.of(context).migrationPageLoading,
          successText: Strings.of(context).migrationPageSuccess,
          feedbackPageTitle: Strings.of(context).migrationPageFeedbackTitle,
          onFinish: (_) => setState(() => _nextEnabled = true),
        ),
      ],
    );
  }
}
