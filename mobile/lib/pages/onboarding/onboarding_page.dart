import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';

import '../../i18n/strings.dart';
import '../../res/dimen.dart';
import '../../widgets/button.dart';
import '../../widgets/widget.dart';
import '../scroll_page.dart';

class OnboardingPage extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final String? nextButtonText;
  final bool nextButtonEnabled;
  final bool showBackButton;
  final bool showAppBar;
  final VoidCallback? onPressedNextButton;

  const OnboardingPage({
    this.children = const [],
    this.padding = insetsZero,
    this.nextButtonText,
    this.nextButtonEnabled = true,
    this.showBackButton = true,
    this.showAppBar = true,
    this.onPressedNextButton,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: showAppBar
          ? TransparentAppBar(
              context,
              leading: const Empty(),
            )
          : null,
      padding: padding,
      footer: _buildFooter(context),
      children: children,
    );
  }

  List<Widget> _buildFooter(BuildContext context) {
    if (onPressedNextButton == null) {
      return [];
    }

    return [
      _buildBackButton(context),
      ActionButton(
        text: nextButtonText ?? Strings.of(context).next,
        onPressed: nextButtonEnabled ? onPressedNextButton : null,
        textColor: context.colorDefault,
      ),
    ];
  }

  Widget _buildBackButton(BuildContext context) {
    if (!showBackButton) {
      return const Empty();
    }

    return IconButton(
      icon: const BackButtonIcon(),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
