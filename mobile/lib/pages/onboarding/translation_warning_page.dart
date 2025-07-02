import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/onboarding/onboarding_page.dart';
import 'package:mobile/widgets/widget.dart';

import '../../res/style.dart';
import '../../utils/string_utils.dart';

class TranslationWarningPage extends StatelessWidget {
  final VoidCallback onFinished;

  const TranslationWarningPage({required this.onFinished});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      showAppBar: true,
      showBackButton: false,
      nextButtonText: L10n.get.lib.ok,
      onPressedNextButton: (_) => onFinished(),
      children: [
        WatermarkLogo(
          title: Strings.of(context).translationWarningPageTitle,
          icon: Icons.translate,
        ),
        const VerticalSpace(paddingLarge),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).translationWarningPageDescription,
            textAlign: TextAlign.center,
            style: stylePrimary(context),
          ),
        ),
        const VerticalSpace(paddingDefault),
      ],
    );
  }
}
