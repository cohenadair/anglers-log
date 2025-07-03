import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';

import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';
import '../widgets/widget.dart';

/// The page shown while initialization futures are completing.
class LandingPage extends StatelessWidget {
  final bool hasError;

  const LandingPage({required this.hasError});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.get.colorAppTheme,
      body: Stack(children: [
        const Align(
          alignment: Alignment(0.0, -0.5),
          child: Icon(
            CustomIcons.catches,
            size: 200,
            color: Colors.white,
          ),
        ),
        _buildInitError(context),
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

  Widget _buildInitError(BuildContext context) {
    if (!hasError) {
      return const Empty();
    }

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: insetsDefault,
        child: Text(
          Strings.of(context).landingPageInitError,
          style: styleError(context).copyWith(
            fontWeight: fontWeightBold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
