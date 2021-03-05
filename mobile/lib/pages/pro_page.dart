import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../subscription_manager.dart';
import '../utils/dialog_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/question_answer_link.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import '../widgets/work_result.dart';
import '../wrappers/io_wrapper.dart';
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

  IoWrapper get _ioWrapper => IoWrapper.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  @override
  void initState() {
    super.initState();
    _subscriptionsFuture = _subscriptionManager.subscriptions();
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
        _buildSubscriptionState(),
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

  Widget _buildSubscriptionState() {
    if (_subscriptionManager.isPro) {
      return WorkResult.success(Strings.of(context).proPageUpgradeSuccess);
    }

    return FutureBuilder<Subscriptions>(
      future: _subscriptionsFuture,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: defaultAnimationDuration,
          child: snapshot.connectionState != ConnectionState.done
              ? Loading()
              : _buildSubscriptionOptions(snapshot.data),
        );
      },
    );
  }

  Widget _buildSubscriptionOptions(Subscriptions subscriptions) {
    if (subscriptions == null) {
      return WorkResult.error(Strings.of(context).proPageFetchError);
    }

    Widget restore = Empty();
    // if (_ioWrapper.isIOS) {
      restore = Padding(
        padding: insetsTopWidget,
        child: QuestionAnswerLink(
          question: Strings.of(context).proPageRestoreQuestion,
          actionText: Strings.of(context).proPageRestoreAction,
          action: _restoreSubscription,
        ),
      );
    // }

    return Column(
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: _maxButtonsContainerWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSubscriptionButton(
                title: format(Strings.of(context).proPageYearlyTitle,
                    [subscriptions.yearly.price]),
                subtitle: format(Strings.of(context).proPageYearlyTrial,
                    [subscriptions.yearly.trialLengthDays]),
                subSubtitle: Strings.of(context).proPageYearlySubtext,
                onPressed: () => _subscriptionManager
                    .purchaseSubscription(subscriptions.yearly),
              ),
              HorizontalSpace(paddingDefault),
              _buildSubscriptionButton(
                title: format(Strings.of(context).proPageMonthlyTitle,
                    [subscriptions.monthly.price]),
                subtitle: format(Strings.of(context).proPageMonthlyTrial,
                    [subscriptions.monthly.trialLengthDays]),
                subSubtitle: Strings.of(context).proPageMonthlySubtext,
                onPressed: () => _subscriptionManager
                    .purchaseSubscription(subscriptions.monthly),
              ),
            ],
          ),
        ),
        restore,
      ],
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

  void _restoreSubscription() async {
    var result = await _subscriptionManager.fetchPastPurchases();
    switch (result) {
      case FetchPastPurchasesResult.error:
      case FetchPastPurchasesResult.noneFound:
        showOkDialog(
          context: context,
          title: Strings.of(context).error,
          description: Text(result == FetchPastPurchasesResult.error
              ? Strings.of(context).proPageRestoreNoServer
              : Strings.of(context).proPageRestoreNoneFound),
        );
        break;
      case FetchPastPurchasesResult.success:
        // Nothing to do.
        break;
    }
  }
}
