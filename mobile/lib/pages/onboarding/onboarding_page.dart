import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../res/dimen.dart';
import '../../widgets/button.dart';
import '../../widgets/widget.dart';

class OnboardingPage extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final String nextButtonText;
  final bool nextButtonEnabled;
  final VoidCallback onPressedNextButton;

  OnboardingPage({
    this.children = const [],
    this.padding,
    this.nextButtonText,
    this.nextButtonEnabled = true,
    this.onPressedNextButton,
  }) : assert(children != null),
       assert(nextButtonEnabled != null);

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
                onPressed: nextButtonEnabled ? onPressedNextButton : null,
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
