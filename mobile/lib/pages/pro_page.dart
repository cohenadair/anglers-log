import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/utils/widget_utils.dart';
import 'package:quiver/strings.dart';

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
  final VoidCallback? onCloseOverride;
  final bool isEmbeddedInScrollPage;

  const ProPage({
    this.onCloseOverride,
    this.isEmbeddedInScrollPage = true,
  });

  @override
  ProPageState createState() => ProPageState();
}

class ProPageState extends State<ProPage> {
  static const _logoHeight = 150.0;
  static const _checkSize = 30.0;
  static const _maxButtonsContainerWidth = 325.0;

  late Future<Subscriptions?> _subscriptionsFuture;
  var _isPendingTransaction = false;

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  @override
  void initState() {
    super.initState();
    _subscriptionsFuture = _subscriptionManager.subscriptions();
  }

  @override
  Widget build(BuildContext context) {
    var children = [
      const VerticalSpace(paddingDefault),
      Icon(
        CustomIcons.catches,
        size: _logoHeight,
        color: context.colorDefault,
      ),
      Text(
        Strings.of(context).proPageUpgradeTitle,
        style: styleTitle2(context),
      ),
      const VerticalSpace(paddingSmall),
      TitleLabel.style1(Strings.of(context).proPageProTitle),
      const VerticalSpace(paddingSmall),
      const DefaultColorIcon(Icons.stars),
      const VerticalSpace(paddingXL),
      _buildFeatureRow("*${Strings.of(context).proPageBackup}"),
      const VerticalSpace(paddingDefault),
      _buildFeatureRow(Strings.of(context).proPageCsv),
      const VerticalSpace(paddingDefault),
      _buildFeatureRow(Strings.of(context).proPageAtmosphere),
      const VerticalSpace(paddingDefault),
      _buildFeatureRow(Strings.of(context).proPageReports),
      const VerticalSpace(paddingDefault),
      _buildFeatureRow(Strings.of(context).proPageCustomFields),
      const VerticalSpace(paddingDefault),
      _buildFeatureRow(Strings.of(context).proPageGpsTrails),
      const VerticalSpace(paddingDefault),
      _buildFeatureRow(Strings.of(context).proPageCopyCatch),
      const VerticalSpace(paddingDefault),
      _buildFeatureRow(Strings.of(context).proPageSpeciesCounter),
      const VerticalSpace(paddingXL),
      _buildSubscriptionState(),
      const VerticalSpace(paddingDefault),
      _buildBackupWarning(),
    ];

    if (widget.isEmbeddedInScrollPage) {
      return ScrollPage(
        children: [
          Stack(
            children: [
              Padding(
                padding: insetsTiny,
                child: CloseButton(
                  onPressed: () => Navigator.of(context).pop(),
                  color: context.colorDefault,
                ),
              ),
              Padding(
                padding: insetsHorizontalDefaultBottomDefault,
                child: Column(children: children),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(children: children);
    }
  }

  Widget _buildFeatureRow(String description) {
    return Row(
      children: [
        Expanded(
          child: Text(
            description,
            style: stylePrimary(context),
            overflow: TextOverflow.visible,
          ),
        ),
        const HorizontalSpace(paddingDefault),
        const Icon(
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
      child = const Loading();
    } else if (_subscriptionManager.isPro) {
      child = WorkResult.success(
          description: Strings.of(context).proPageUpgradeSuccess);
    } else {
      child = FutureBuilder<Subscriptions?>(
        future: _subscriptionsFuture,
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: animDurationDefault,
            child: snapshot.connectionState != ConnectionState.done
                ? const Loading()
                : _buildSubscriptionOptions(snapshot.data),
          );
        },
      );
    }

    return AnimatedSwitcher(
      duration: animDurationDefault,
      child: child,
    );
  }

  Widget _buildSubscriptionOptions(Subscriptions? subscriptions) {
    if (subscriptions == null) {
      return WorkResult.error(
          description: Strings.of(context).proPageFetchError);
    }

    return Column(
      children: [
        Container(
          constraints:
              const BoxConstraints(maxWidth: _maxButtonsContainerWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSubscriptionButton(
                sub: subscriptions.yearly,
                priceCallback: Strings.of(context).proPageYearlyTitle,
                trialCallback: Strings.of(context).proPageYearlyTrial,
                billingFrequencyText: Strings.of(context).proPageYearlySubtext,
              ),
              const HorizontalSpace(paddingDefault),
              _buildSubscriptionButton(
                sub: subscriptions.monthly,
                priceCallback: Strings.of(context).proPageMonthlyTitle,
                trialCallback: Strings.of(context).proPageMonthlyTrial,
                billingFrequencyText: Strings.of(context).proPageMonthlySubtext,
              ),
            ],
          ),
        ),
        const VerticalSpace(paddingDefault),
        QuestionAnswerLink(
          question: Strings.of(context).proPageRestoreQuestion,
          actionText: Strings.of(context).proPageRestoreAction,
          action: _restoreSubscription,
        ),
        const VerticalSpace(paddingDefault),
        Text(
          IoWrapper.get.isAndroid
              ? Strings.of(context).proPageDisclosureAndroid
              : Strings.of(context).proPageDisclosureApple,
          style: styleSubtext,
        ),
      ],
    );
  }

  Widget _buildSubscriptionButton({
    required Subscription sub,
    required String Function(String) priceCallback,
    required String Function(int) trialCallback,
    required String billingFrequencyText,
  }) {
    assert(isNotEmpty(billingFrequencyText));

    return Expanded(
      child: ElevatedButton(
        child: Padding(
          padding: insetsVerticalSmall,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                priceCallback(sub.price),
                style: stylePrimary(context).copyWith(
                  fontWeight: fontWeightBold,
                ),
              ),
              const VerticalSpace(paddingTiny),
              Text(trialCallback(sub.trialLengthDays)),
              const VerticalSpace(paddingTiny),
              Text(
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

  Widget _buildBackupWarning() {
    return Text(
      "*${Strings.of(context).proPageBackupWarning}",
      style: styleSubtext,
    );
  }

  Future<void> _restoreSubscription() async {
    _setIsPendingTransaction(true);

    var strings = Strings.of(context);
    var result = await _subscriptionManager.restoreSubscription();

    _setIsPendingTransaction(false);

    String? dialogMessage;
    switch (result) {
      case RestoreSubscriptionResult.noSubscriptionsFound:
        dialogMessage = IoWrapper.get.isAndroid
            ? strings.proPageRestoreNoneFoundGooglePlay
            : strings.proPageRestoreNoneFoundAppStore;
        break;
      case RestoreSubscriptionResult.error:
        dialogMessage = strings.proPageRestoreError;
        break;
      case RestoreSubscriptionResult.success:
        // Nothing to do.
        break;
    }

    // Something went wrong, tell the user to make sure they're signed in to
    // the correct storefront account.
    if (isNotEmpty(dialogMessage)) {
      safeUseContext(
        this,
        () => showErrorDialog(
          context: context,
          description: Text(dialogMessage!),
        ),
      );
    }
  }

  void _purchaseSubscription(Subscription sub) {
    _setIsPendingTransaction(true);
    _subscriptionManager
        .purchaseSubscription(sub)
        .then((_) => _setIsPendingTransaction(false));
  }

  void _setIsPendingTransaction(bool pending) {
    // ProPage can be dismissed before purchaseSubscription has completed,
    // requiring safeUseContext here.
    safeUseContext(this, () => setState(() => _isPendingTransaction = pending));
  }
}
