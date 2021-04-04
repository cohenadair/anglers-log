import 'dart:async';

import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../log.dart';
import '../../res/dimen.dart';
import '../../widgets/text.dart';
import '../../widgets/widget.dart';
import '../more_page.dart';
import 'embedded_page.dart';
import 'onboarding_page.dart';

class HowToFeedbackPage extends StatefulWidget {
  final VoidCallback? onNext;

  HowToFeedbackPage({
    this.onNext,
  });

  @override
  _HowToFeedbackPageState createState() => _HowToFeedbackPageState();
}

class _HowToFeedbackPageState extends State<HowToFeedbackPage> {
  static const _scrollAnimDuration = Duration(milliseconds: 500);
  static const _scrollToTopAfter = Duration(seconds: 2, milliseconds: 500);
  static const _scrollToFeedbackAfter = Duration(seconds: 1);

  final _log = Log("HowToFeedbackPage");
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
    super.dispose();
    _scrollTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      nextButtonText: Strings.of(context).finish,
      onPressedNextButton: widget.onNext,
      children: <Widget>[
        VerticalSpace(paddingWidget),
        TitleLabel(
          Strings.of(context).onboardingJourneyHowToFeedbackTitle,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
        VerticalSpace(paddingWidgetDouble),
        EmbeddedPage(
          showBackButton: false,
          childBuilder: (context) => MorePage(
            feedbackKey: _feedbackKey,
          ),
        ),
        VerticalSpace(paddingWidgetDouble),
        Padding(
          padding: insetsHorizontalDefault,
          child: PrimaryLabel(
            Strings.of(context).onboardingJourneyHowToFeedbackDescription,
            overflow: TextOverflow.visible,
            align: TextAlign.center,
          ),
        ),
        VerticalSpace(paddingWidget),
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
    );
    _isFeedbackShowing = true;
    _scrollTimer = Timer(_scrollToTopAfter, _jumpToTop);
  }

  void _jumpToTop() {
    if (!_isFeedbackShowing) {
      return;
    }

    var controller =
        Scrollable.of(_feedbackKey.currentContext!)?.widget.controller;
    if (controller != null) {
      controller.jumpTo(0.0);
      _isFeedbackShowing = false;
      _scrollTimer = Timer(_scrollToFeedbackAfter, _scrollToFeedback);
    } else {
      _log.w("Scrollable controller doesn't exist");
    }
  }
}
