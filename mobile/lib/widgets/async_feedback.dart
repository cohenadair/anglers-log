import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/res/anim.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/widgets/button.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:adair_flutter_lib/widgets/work_result.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/feedback_page.dart';

import '../../utils/string_utils.dart';
import '../pages/anglers_log_pro_page.dart';

enum AsyncFeedbackState { none, loading, error, success }

class AsyncFeedback extends StatelessWidget {
  final AsyncFeedbackState state;
  final String? description;
  final String? descriptionDetail;

  final Key? actionKey;
  final String actionText;
  final VoidCallback? action;
  final bool actionRequiresPro;

  final FeedbackPage? feedbackPage;

  const AsyncFeedback({
    this.state = AsyncFeedbackState.none,
    this.description,
    this.descriptionDetail,
    this.actionKey,
    required this.actionText,
    this.action,
    this.actionRequiresPro = false,
    this.feedbackPage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildActionButton(context), _buildFeedbackWidgets(context)],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    var onPressed = action;
    if (onPressed != null &&
        actionRequiresPro &&
        SubscriptionManager.get.isFree) {
      onPressed = () => present(context, const AnglersLogProPage());
    }

    return Button(
      key: actionKey,
      text: actionText,
      onPressed: state == AsyncFeedbackState.loading ? null : onPressed,
    );
  }

  Widget _buildFeedbackWidgets(BuildContext context) {
    var children = <Widget>[];

    switch (state) {
      case AsyncFeedbackState.none:
        return const SizedBox();
      case AsyncFeedbackState.loading:
        children.add(Loading(label: description));
        break;
      case AsyncFeedbackState.success:
        children.add(
          WorkResult.success(
            description: description,
            descriptionDetail: descriptionDetail,
          ),
        );
        break;
      case AsyncFeedbackState.error:
        children.add(
          WorkResult.error(
            description: description,
            descriptionDetail: descriptionDetail,
          ),
        );
        children.add(Container(height: paddingDefault));
        if (feedbackPage != null) {
          children.add(
            Button(
              text: Strings.of(context).asyncFeedbackSendReport,
              onPressed: () => present(context, feedbackPage!),
            ),
          );
        }
        break;
    }

    return Padding(
      padding: insetsTopDefault,
      child: AnimatedSwitcher(
        duration: animDurationDefault,
        child: Column(
          key: ValueKey<AsyncFeedbackState>(state),
          children: children,
        ),
      ),
    );
  }
}
