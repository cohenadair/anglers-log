import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';

class ProOverlay extends StatelessWidget {
  /// A widget available only for pro users.
  final Widget proWidget;
  final String description;

  const ProOverlay({
    required this.description,
    required this.proWidget,
  });

  @override
  Widget build(BuildContext context) {
    var subscriptionManager = SubscriptionManager.of(context);

    return StreamBuilder<void>(
      stream: subscriptionManager.stream,
      builder: (context, snapshot) =>
          subscriptionManager.isFree ? _buildUpgrade(context) : proWidget,
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
          onPressed: () => present(context, const ProPage()),
        ),
      ],
    );
  }
}
