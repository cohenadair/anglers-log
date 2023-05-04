import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

import '../res/style.dart';
import 'widget.dart';

class AppBarDropdown extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final MainAxisAlignment textAlignment;

  const AppBarDropdown({
    required this.title,
    this.onTap,
    this.padding = insetsZero,
    this.textAlignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: textAlignment,
          children: [
            Text(
              title,
              style: styleTitleAppBar(context),
            ),
            DropdownIcon(),
          ],
        ),
      ),
    );
  }
}
