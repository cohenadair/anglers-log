import 'dart:async';

import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../model/gen/anglerslog.pb.dart';
import '../../res/dimen.dart';
import '../../utils/protobuf_utils.dart';
import '../../widgets/text.dart';
import '../../widgets/widget.dart';
import '../save_catch_page.dart';
import 'embedded_page.dart';
import 'onboarding_page.dart';

class ManageFieldsPage extends StatefulWidget {
  final VoidCallback onNext;

  ManageFieldsPage({
    this.onNext,
  });

  @override
  _ManageFieldsPageState createState() => _ManageFieldsPageState();
}

class _ManageFieldsPageState extends State<ManageFieldsPage> {
  static const _menuTimerDuration = Duration(seconds: 2);

  // Allows showing/hiding popup menu programmatically.
  final _popupMenuKey = GlobalKey<PopupMenuButtonState>();

  Timer _menuTimer;
  bool _isMenuShowing = false;

  @override
  void initState() {
    super.initState();
    _menuTimer = Timer.periodic(_menuTimerDuration, (_) {
      if (_isMenuShowing) {
        Navigator.of(_popupMenuKey.currentContext).pop();
      } else {
        _popupMenuKey.currentState.showButtonMenu();
      }
      _isMenuShowing = !_isMenuShowing;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _menuTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      onPressedNextButton: widget.onNext,
      children: <Widget>[
        VerticalSpace(paddingWidget),
        TitleLabel(
          Strings.of(context).onboardingJourneyManageFieldsTitle,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
        VerticalSpace(paddingWidgetDouble),
        EmbeddedPage(
          childBuilder: (context) => SaveCatchPage(
            popupMenuKey: _popupMenuKey,
            species: Species()
              ..id = randomId()
              ..name = Strings.of(context).onboardingJourneyManageFieldsSpecies,
            fishingSpot: FishingSpot()
              ..id = randomId()
              // Coordinates don't matter here; they aren't shown.
              ..lat = 0.000000
              ..lng = 0.000000,
          ),
        ),
        VerticalSpace(paddingWidgetDouble),
        Padding(
          padding: insetsHorizontalDefault,
          child: PrimaryLabel(
            Strings.of(context).onboardingJourneyManageFieldsDescription,
            overflow: TextOverflow.visible,
            align: TextAlign.center,
          ),
        ),
        VerticalSpace(paddingWidget),
      ],
    );
  }
}
