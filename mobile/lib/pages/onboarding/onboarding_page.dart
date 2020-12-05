import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../../i18n/strings.dart';
import '../../res/dimen.dart';
import '../../widgets/button.dart';
import '../../widgets/widget.dart';

class OnboardingPage extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final String nextButtonText;
  final VoidCallback onPressedNextButton;

  OnboardingPage({
    this.children,
    this.padding,
    this.nextButtonText,
    this.onPressedNextButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: onPressedNextButton == null
          ? null
          : [
              IconButton(
                icon: BackButtonIcon(),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ActionButton(
                text: nextButtonText ?? Strings.of(context).next,
                onPressed: onPressedNextButton,
                textColor: Theme.of(context).primaryColor,
              ),
            ],
      body: HorizontalSafeArea(
        child: Padding(
          padding: padding ?? insetsHorizontalDefault,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
