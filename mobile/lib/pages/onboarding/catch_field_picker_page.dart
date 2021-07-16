import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../model/gen/anglerslog.pb.dart';
import '../../res/dimen.dart';
import '../../res/gen/custom_icons.dart';
import '../../res/style.dart';
import '../../time_manager.dart';
import '../../user_preference_manager.dart';
import '../../utils/catch_utils.dart';
import '../../widgets/list_item.dart';
import '../../widgets/widget.dart';
import 'onboarding_page.dart';

class CatchFieldPickerPage extends StatefulWidget {
  final VoidCallback? onNext;

  CatchFieldPickerPage({
    this.onNext,
  });

  @override
  _CatchFieldPickerPageState createState() => _CatchFieldPickerPageState();
}

class _CatchFieldPickerPageState extends State<CatchFieldPickerPage> {
  late List<Id> _selectedFields;

  TimeManager get _timeManager => TimeManager.of(context);

  UserPreferenceManager get _userPreferencesManager =>
      UserPreferenceManager.of(context);

  @override
  void initState() {
    super.initState();

    _selectedFields = allCatchFields(_timeManager)
        .where((field) => !field.removable)
        .map((field) => field.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      padding: insetsZero,
      showBackButton: false,
      onPressedNextButton: widget.onNext == null ? null : _onPressedNext,
      children: <Widget>[
        SafeArea(child: Empty()),
        Padding(
          padding: insetsHorizontalDefault,
          child: WatermarkLogo(
            icon: CustomIcons.catches,
          ),
        ),
        VerticalSpace(paddingWidget),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).onboardingJourneyCatchFieldDescription,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: stylePrimary(context),
          ),
        ),
        VerticalSpace(paddingWidget),
      ]..addAll(_buildFieldOptions()),
    );
  }

  List<Widget> _buildFieldOptions() {
    return allCatchFieldsSorted(context, _timeManager).map((field) {
      var isEnabled = field.removable;

      var subtitle = field.description?.call(context);
      if (subtitle == null && !isEnabled) {
        subtitle = Strings.of(context).inputGenericRequired;
      }

      return PickerListItem(
        title: field.name!(context),
        subtitle: subtitle,
        isEnabled: isEnabled,
        isMulti: true,
        isSelected: _selectedFields.contains(field.id),
        onCheckboxChanged: (checked) {
          if (checked) {
            _selectedFields.add(field.id);
          } else {
            _selectedFields.remove(field.id);
          }
        },
      );
    }).toList();
  }

  void _onPressedNext() {
    _userPreferencesManager.setCatchFieldIds(_selectedFields);
    widget.onNext?.call();
  }
}
