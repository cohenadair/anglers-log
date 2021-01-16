import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../res/dimen.dart';
import '../../widgets/button.dart';
import '../../widgets/widget.dart';
import '../scroll_page.dart';

class OnboardingPage extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final String nextButtonText;
  final bool nextButtonEnabled;
  final bool showBackButton;
  final VoidCallback onPressedNextButton;

  OnboardingPage({
    this.children = const [],
    this.padding = insetsZero,
    this.nextButtonText,
    this.nextButtonEnabled = true,
    this.showBackButton = true,
    this.onPressedNextButton,
  })  : assert(children != null),
        assert(nextButtonEnabled != null),
        assert(showBackButton != null);

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Empty(),
      ),
      padding: padding,
      footer: _buildFooter(context),
      children: children,
    );
  }

  List<Widget> _buildFooter(BuildContext context) {
    if (onPressedNextButton == null) {
      return null;
    }

    return [
      _buildBackButton(context),
      ActionButton(
        text: nextButtonText ?? Strings.of(context).next,
        onPressed: nextButtonEnabled ? onPressedNextButton : null,
        textColor: Theme.of(context).primaryColor,
      ),
    ];
  }

  Widget _buildBackButton(BuildContext context) {
    if (!showBackButton) {
      return Empty();
    }

    return IconButton(
      icon: BackButtonIcon(),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
