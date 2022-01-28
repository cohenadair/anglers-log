import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/widget.dart';

import 'button.dart';
import 'work_result.dart';

enum AsyncFeedbackState {
  none,
  loading,
  error,
  success,
}

class AsyncFeedback extends StatelessWidget {
  final AsyncFeedbackState state;
  final String? description;

  final String actionText;
  final VoidCallback? action;

  final FeedbackPage? feedbackPage;

  const AsyncFeedback({
    this.state = AsyncFeedbackState.none,
    this.description,
    required this.actionText,
    this.action,
    this.feedbackPage,
  }) : assert(state != AsyncFeedbackState.error || feedbackPage != null,
            "Error state must have a non-null feedbackPage value");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(),
        _buildFeedbackWidgets(context),
      ],
    );
  }

  Widget _buildActionButton() {
    return Button(
      text: actionText,
      onPressed: state == AsyncFeedbackState.loading ? null : action,
    );
  }

  Widget _buildFeedbackWidgets(BuildContext context) {
    var children = <Widget>[];

    switch (state) {
      case AsyncFeedbackState.none:
        return Empty();
      case AsyncFeedbackState.loading:
        children.add(Loading(label: description));
        break;
      case AsyncFeedbackState.success:
        children.add(WorkResult.success(description: description));
        break;
      case AsyncFeedbackState.error:
        children.add(WorkResult.error(description: description));
        children.add(const VerticalSpace(paddingDefault));
        children.add(Button(
          text: Strings.of(context).asyncFeedbackSendReport,
          onPressed: () => present(context, feedbackPage!),
        ));
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
