import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

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

  late Future<Subscriptions?> _subscriptionsFuture;
  var _isPendingTransaction = false;

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
        _buildFeatureRow(Strings.of(context).proPageReports),
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
    Widget child;

    if (_isPendingTransaction) {
      child = Loading();
    } else if (_subscriptionManager.isPro) {
      child = WorkResult.success(Strings.of(context).proPageUpgradeSuccess);
    } else {
      child = FutureBuilder<Subscriptions?>(
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

    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: child,
    );
  }

  Widget _buildSubscriptionOptions(Subscriptions? subscriptions) {
    if (subscriptions == null) {
      return WorkResult.error(Strings.of(context).proPageFetchError);
    }

    return Column(
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: _maxButtonsContainerWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSubscriptionButton(
                sub: subscriptions.yearly,
                priceText: Strings.of(context).proPageYearlyTitle,
                trialText: Strings.of(context).proPageYearlyTrial,
                billingFrequencyText: Strings.of(context).proPageYearlySubtext,
              ),
              HorizontalSpace(paddingDefault),
              _buildSubscriptionButton(
                sub: subscriptions.monthly,
                priceText: Strings.of(context).proPageMonthlyTitle,
                trialText: Strings.of(context).proPageMonthlyTrial,
                billingFrequencyText: Strings.of(context).proPageMonthlySubtext,
              ),
            ],
          ),
        ),
        Padding(
          padding: insetsTopWidget,
          child: QuestionAnswerLink(
            question: Strings.of(context).proPageRestoreQuestion,
            actionText: Strings.of(context).proPageRestoreAction,
            action: _restoreSubscription,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionButton({
    required Subscription sub,
    required String priceText,
    required String trialText,
    required String billingFrequencyText,
  }) {
    assert(isNotEmpty(priceText));
    assert(isNotEmpty(trialText));
    assert(isNotEmpty(billingFrequencyText));

    return Expanded(
      child: ElevatedButton(
        child: Padding(
          padding: insetsVerticalWidgetSmall,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryLabel(
                format(priceText, [sub.price]),
                fontWeight: fontWeightBold,
              ),
              VerticalSpace(paddingTiny),
              Label(format(trialText, [sub.trialLengthDays])),
              VerticalSpace(paddingTiny),
              Label(
                billingFrequencyText,
                style: styleSubtext,
              ),
            ],
          ),
        ),
        onPressed: () => _purchaseSubscription(sub),
      ),
    );
  }

  void _restoreSubscription() {
    _setIsPendingTransaction(true);

    _subscriptionManager.restoreSubscription().then((result) {
      _setIsPendingTransaction(false);

      String? dialogMessage;
      switch (result) {
        case RestoreSubscriptionResult.noSubscriptionsFound:
          dialogMessage = _ioWrapper.isAndroid
              ? Strings.of(context).proPageRestoreNoneFoundGooglePlay
              : Strings.of(context).proPageRestoreNoneFoundAppStore;
          break;
        case RestoreSubscriptionResult.error:
          dialogMessage = Strings.of(context).proPageRestoreError;
          break;
        case RestoreSubscriptionResult.success:
          // Nothing to do.
          break;
      }

      // Something went wrong, tell the user to make sure they're signed in to
      // the correct storefront account.
      if (isNotEmpty(dialogMessage)) {
        showErrorDialog(
          context: context,
          description: Text(dialogMessage!),
        );
      }
    });
  }

  void _purchaseSubscription(Subscription sub) {
    _setIsPendingTransaction(true);
    _subscriptionManager
        .purchaseSubscription(sub)
        .then((_) => _setIsPendingTransaction(false));
  }

  void _setIsPendingTransaction(bool pending) {
    setState(() {
      _isPendingTransaction = pending;
    });
  }
}
