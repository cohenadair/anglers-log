import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';

class ProBlur extends StatelessWidget {
  static const double _blurSigma = 5.0;

  /// A widget available only for pro users.
  final Widget proWidget;
  final String description;

  const ProBlur({
    required this.description,
    required this.proWidget,
  });

  @override
  Widget build(BuildContext context) {
    var subscriptionManager = SubscriptionManager.of(context);

    return StreamBuilder<void>(
      stream: subscriptionManager.stream,
      builder: (context, snapshot) {
        if (subscriptionManager.isFree) {
          return Stack(
            children: [
              proWidget,
              Positioned.fill(child: _buildBlur(context)),
              _buildUpgrade(context),
            ],
          );
        }
        return proWidget;
      },
    );
  }

  Widget _buildBlur(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _blurSigma,
          sigmaY: _blurSigma,
        ),
        child: Container(
          color: Colors.black.withOpacity(0),
          child: const Empty(),
        ),
      ),
    );
  }

  Widget _buildUpgrade(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            description,
            style: stylePrimary(context),
          ),
        ),
        const VerticalSpace(paddingDefault),
        Button(
          text: Strings.of(context).proBlurUpgradeButton,
          onPressed: () => present(context, ProPage()),
        ),
      ],
    );
  }
}
