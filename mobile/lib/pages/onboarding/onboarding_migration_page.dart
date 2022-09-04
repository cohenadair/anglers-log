import 'package:flutter/material.dart';

import '../../database/legacy_importer.dart';
import '../../i18n/strings.dart';
import '../../res/dimen.dart';
import '../../widgets/data_importer.dart';
import 'onboarding_page.dart';

class OnboardingMigrationPage extends StatefulWidget {
  final LegacyImporter importer;
  final VoidCallback? onNext;

  const OnboardingMigrationPage({
    required this.importer,
    this.onNext,
  });

  @override
  OnboardingMigrationPageState createState() => OnboardingMigrationPageState();
}

class OnboardingMigrationPageState extends State<OnboardingMigrationPage> {
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
          descriptionText:
              Strings.of(context).onboardingMigrationPageDescription,
          errorText: Strings.of(context).onboardingMigrationPageError,
          loadingText: Strings.of(context).migrationPageLoading,
          successText: Strings.of(context).migrationPageSuccess,
          feedbackPageTitle: Strings.of(context).migrationPageFeedbackTitle,
          onFinish: (_) => setState(() => _nextEnabled = true),
        ),
      ],
    );
  }
}
