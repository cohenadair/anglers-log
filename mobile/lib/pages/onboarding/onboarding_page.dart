import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/widget_utils.dart';

import '../../utils/string_utils.dart';
import '../../widgets/button.dart';

class OnboardingPage extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final String? nextButtonText;
  final bool nextButtonEnabled;
  final bool showBackButton;
  final bool showAppBar;
  final ContextCallback? onPressedNextButton;

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
          ? TransparentAppBar(context, leading: const SizedBox())
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
        onPressed: nextButtonEnabled
            ? () => onPressedNextButton?.call(context)
            : null,
        textColor: AppConfig.get.colorAppTheme,
      ),
    ];
  }

  Widget _buildBackButton(BuildContext context) {
    if (!showBackButton) {
      return const SizedBox();
    }

    return IconButton(
      icon: const BackButtonIcon(),
      color: AppConfig.get.colorAppTheme,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
