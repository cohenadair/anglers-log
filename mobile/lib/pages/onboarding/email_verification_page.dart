import 'package:flutter/material.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mobile/widgets/work_result.dart';

import 'onboarding_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final VoidCallback? onNext;

  const EmailVerificationPage({
    this.onNext,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  /// Rate limit how often a user can re-send verification emails.
  static const _msBetweenEmails = Duration.millisecondsPerMinute * 5;

  var _feedbackState = _FeedbackState.none;

  AuthManager get _authManager => AuthManager.of(context);

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      onPressedNextButton: () {
        _startLoading();
        _reloadUser();
      },
      nextButtonEnabled: true,
      showBackButton: false,
      children: [
        const WatermarkLogo(icon: Icons.mail),
        const VerticalSpace(paddingWidget),
        _buildDescription(),
        const VerticalSpace(paddingWidget),
        Button(
          text: Strings.of(context).emailVerificationSendAgain,
          onPressed: () {
            _startLoading();
            _resendVerificationEmail();
          },
        ),
        const VerticalSpace(paddingWidgetDouble),
        GestureDetector(
          onTap: () => _authManager.logout(),
          child: Text(
            Strings.of(context).emailVerificationSignOut,
            style: styleHyperlink(context),
          ),
        ),
        const VerticalSpace(paddingWidgetDouble),
        _buildFeedback(),
        const VerticalSpace(paddingWidget),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: insetsDefault,
      child: Column(
        children: [
          Text(
            format(Strings.of(context).emailVerificationDesc1,
                [_authManager.userEmail]),
            style: stylePrimary(context),
          ),
          const VerticalSpace(paddingWidget),
          Text(
            format(Strings.of(context).emailVerificationDesc2,
                [_authManager.userEmail]),
            style: stylePrimary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    Widget child = Empty();

    switch (_feedbackState) {
      case _FeedbackState.none:
        child = Empty();
        break;
      case _FeedbackState.loading:
        child = const Loading();
        break;
      case _FeedbackState.notVerified:
        child = WorkResult.error(Strings.of(context).emailVerificationError);
        break;
      case _FeedbackState.emailResent:
        child = WorkResult.success(Strings.of(context).emailVerificationSent);
        break;
    }

    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: Padding(
        padding: insetsHorizontalDefault,
        child: child,
      ),
    );
  }

  Future<void> _reloadUser() async {
    await _authManager.reloadUser();

    if (_authManager.isUserVerified) {
      widget.onNext?.call();
    } else {
      setState(() => _feedbackState = _FeedbackState.notVerified);
    }
  }

  Future<void> _resendVerificationEmail() async {
    await _authManager.sendVerificationEmail(_msBetweenEmails);
    setState(() => _feedbackState = _FeedbackState.emailResent);
  }

  void _startLoading() {
    setState(() => _feedbackState = _FeedbackState.loading);
  }
}

enum _FeedbackState {
  none,
  loading,
  notVerified,
  emailResent,
}
