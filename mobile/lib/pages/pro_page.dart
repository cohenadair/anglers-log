import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../subscription_manager.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import 'scroll_page.dart';

class ProPage extends StatefulWidget {
  @override
  _ProPageState createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  static const _logoHeight = 150.0;
  static const _checkSize = 30.0;
  static const _maxButtonsContainerWidth = 300.0;

  Future<Subscriptions> _subscriptionsFuture;

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  @override
  void initState() {
    super.initState();
    _subscriptionsFuture = _subscriptionManager.subscriptionOptions();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: TransparentAppBar(context),
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      extendBodyBehindAppBar: true,
      children: [
        Icon(
          CustomIcons.catches,
          size: _logoHeight,
        ),
        Label(
          Strings.of(context).proPageUpgradeTitle,
          style: styleTitle2,
        ),
        VerticalSpace(paddingWidgetSmall),
        TitleLabel(Strings.of(context).proPageProTitle),
        VerticalSpace(paddingWidgetSmall),
        Icon(Icons.stars),
        VerticalSpace(paddingWidgetDouble),
        _buildFeatureRow(Strings.of(context).proPageBackup),
        VerticalSpace(paddingWidget),
        _buildFeatureRow(Strings.of(context).proPageSync),
        VerticalSpace(paddingWidget),
        _buildFeatureRow(Strings.of(context).proPageCustomReports),
        VerticalSpace(paddingWidget),
        _buildFeatureRow(Strings.of(context).proPageCustomFields),
        VerticalSpace(paddingWidgetDouble),
        _buildSubscriptionButtons(),
      ],
    );
  }

  Widget _buildFeatureRow(String description) {
    return Row(
      children: [
        Expanded(child: PrimaryLabel.multiline(description)),
        HorizontalSpace(paddingWidget),
        Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: _checkSize,
        ),
      ],
    );
  }

  Widget _buildSubscriptionButtons() {
    return FutureBuilder<Subscriptions>(
      future: _subscriptionsFuture,
      builder: (context, snapshot) {
        Widget child;

        if (snapshot.connectionState != ConnectionState.done) {
          child = Loading();
        } else {
          var subs = snapshot.data;
          if (subs == null) {
            child = _buildError(Strings.of(context).proPageFetchError);
          } else {
            child = Container(
              constraints: BoxConstraints(maxWidth: _maxButtonsContainerWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSubscriptionButton(
                    title: format(Strings.of(context).proPageYearlyTitle,
                        [subs.yearly.price]),
                    subtitle: format(Strings.of(context).proPageYearlyTrial,
                        [subs.yearly.trialLengthDays]),
                    subSubtitle: Strings.of(context).proPageYearlySubtext,
                    onPressed: () {
                      // TODO
                    },
                  ),
                  HorizontalSpace(paddingDefault),
                  _buildSubscriptionButton(
                    title: format(Strings.of(context).proPageMonthlyTitle,
                        [subs.monthly.price]),
                    subtitle: format(Strings.of(context).proPageMonthlyTrial,
                        [subs.monthly.trialLengthDays]),
                    subSubtitle: Strings.of(context).proPageMonthlySubtext,
                    onPressed: () {
                      // TODO
                    },
                  ),
                ],
              ),
            );
          }
        }

        return AnimatedSwitcher(
          duration: defaultAnimationDuration,
          child: child,
        );
      },
    );
  }

  Widget _buildSubscriptionButton({
    String title,
    String subtitle,
    String subSubtitle,
    VoidCallback onPressed,
  }) {
    return Expanded(
      child: RaisedButton(
        padding: insetsHorizontalDefaultVerticalSmall,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryLabel(
              title,
              fontWeight: fontWeightBold,
            ),
            VerticalSpace(paddingTiny),
            Label(subtitle),
            VerticalSpace(paddingTiny),
            Label(
              subSubtitle,
              style: styleSubtext,
            ),
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildError(String msg) {
    return Label.multiline(
      msg,
      style: styleError,
      align: TextAlign.center,
    );
  }
}
