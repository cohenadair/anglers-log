import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';

/// The page shown while initialization futures are completing.
class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorDefault,
      body: Stack(children: [
        const Align(
          alignment: Alignment(0.0, -0.5),
          child: Icon(
            CustomIcons.catches,
            size: 200,
            color: Colors.white,
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: insetsDefault,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Strings.of(context).by,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  Text(
                    Strings.of(context).devName,
                    style: stylePrimary(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
