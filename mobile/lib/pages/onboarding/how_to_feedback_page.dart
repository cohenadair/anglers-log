import 'dart:async';

import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../log.dart';
import '../../res/dimen.dart';
import '../../res/style.dart';
import '../../widgets/text.dart';
import '../../widgets/widget.dart';
import '../more_page.dart';
import 'embedded_page.dart';
import 'onboarding_page.dart';

class HowToFeedbackPage extends StatefulWidget {
  final VoidCallback? onNext;
  final String nextLabel;

  const HowToFeedbackPage({
    this.onNext,
    required this.nextLabel,
  });

  @override
  HowToFeedbackPageState createState() => HowToFeedbackPageState();
}

class HowToFeedbackPageState extends State<HowToFeedbackPage> {
  static const _scrollAnimDuration = Duration(milliseconds: 500);
  static const _scrollToTopAfter = Duration(seconds: 2, milliseconds: 500);
  static const _scrollToFeedbackAfter = Duration(seconds: 1);

  // Align the scrolled content to the center of the viewport.
  static const _scrollAlignment = 0.5;

  static const _log = Log("HowToFeedbackPage");

  final _feedbackKey = GlobalKey();

  late Timer _scrollTimer;
  bool _isFeedbackShowing = false;

  @override
  void initState() {
    super.initState();
    _scrollTimer = Timer(_scrollToFeedbackAfter, _scrollToFeedback);
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      nextButtonText: widget.nextLabel,
      onPressedNextButton: widget.onNext,
      children: <Widget>[
        const VerticalSpace(paddingDefault),
        TitleLabel.style1(
          Strings.of(context).onboardingJourneyHowToFeedbackTitle,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
        const VerticalSpace(paddingXL),
        EmbeddedPage(
          showBackButton: false,
          childBuilder: (context) => MorePage(
            feedbackKey: _feedbackKey,
          ),
        ),
        const VerticalSpace(paddingXL),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).onboardingJourneyHowToFeedbackDescription,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: stylePrimary(context),
          ),
        ),
        const VerticalSpace(paddingDefault),
      ],
    );
  }

  void _scrollToFeedback() {
    if (_isFeedbackShowing) {
      return;
    }
    Scrollable.ensureVisible(
      _feedbackKey.currentContext!,
      duration: _scrollAnimDuration,
      alignment: _scrollAlignment,
    );
    _isFeedbackShowing = true;
    _scrollTimer = Timer(_scrollToTopAfter, _jumpToTop);
  }

  void _jumpToTop() {
    if (!_isFeedbackShowing) {
      return;
    }

    var controller =
        Scrollable.of(_feedbackKey.currentContext!).widget.controller;
    if (controller != null) {
      controller.jumpTo(0.0);
      _isFeedbackShowing = false;
      _scrollTimer = Timer(_scrollToFeedbackAfter, _scrollToFeedback);
    } else {
      _log.w("Scrollable controller doesn't exist");
    }
  }
}
