import 'dart:async';

import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/widget_utils.dart';

import '../../res/style.dart';
import '../../utils/protobuf_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/text.dart';
import '../save_catch_page.dart';
import 'embedded_page.dart';
import 'onboarding_page.dart';

class HowToManageFieldsPage extends StatefulWidget {
  final ContextCallback? onNext;

  const HowToManageFieldsPage({this.onNext});

  @override
  HowToManageFieldsPageState createState() => HowToManageFieldsPageState();
}

class HowToManageFieldsPageState extends State<HowToManageFieldsPage> {
  static const _menuTimerDuration = Duration(seconds: 2);

  // Allows showing/hiding popup menu programmatically.
  final _popupMenuKey = GlobalKey<PopupMenuButtonState>();

  late Timer _menuTimer;
  bool _isMenuShowing = false;

  @override
  void initState() {
    super.initState();
    _menuTimer = Timer.periodic(_menuTimerDuration, (_) {
      if (_isMenuShowing) {
        Navigator.of(_popupMenuKey.currentContext!).pop();
      } else {
        _popupMenuKey.currentState!.showButtonMenu();
      }
      _isMenuShowing = !_isMenuShowing;
    });
  }

  @override
  void dispose() {
    _menuTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      onPressedNextButton: widget.onNext,
      children: <Widget>[
        Container(height: paddingDefault),
        TitleLabel.style1(
          Strings.of(context).onboardingJourneyManageFieldsTitle,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
        Container(height: paddingXL),
        EmbeddedPage(
          childBuilder: (context) =>
              SaveCatchPage(speciesId: randomId(), popupMenuKey: _popupMenuKey),
        ),
        Container(height: paddingXL),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).onboardingJourneyManageFieldsDescription,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: stylePrimary(context),
          ),
        ),
        Container(height: paddingDefault),
      ],
    );
  }
}
