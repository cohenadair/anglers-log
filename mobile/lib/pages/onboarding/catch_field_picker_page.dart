import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../model/gen/anglerslog.pb.dart';
import '../../res/dimen.dart';
import '../../res/gen/custom_icons.dart';
import '../../res/style.dart';
import '../../user_preference_manager.dart';
import '../../utils/catch_utils.dart';
import '../../widgets/list_item.dart';
import '../../widgets/widget.dart';
import 'onboarding_page.dart';

class CatchFieldPickerPage extends StatefulWidget {
  final VoidCallback? onNext;

  const CatchFieldPickerPage({
    this.onNext,
  });

  @override
  CatchFieldPickerPageState createState() => CatchFieldPickerPageState();
}

class CatchFieldPickerPageState extends State<CatchFieldPickerPage> {
  late List<Id> _selectedFields;

  UserPreferenceManager get _userPreferencesManager =>
      UserPreferenceManager.of(context);

  @override
  void initState() {
    super.initState();

    _selectedFields = allCatchFields(context).map((field) => field.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      padding: insetsZero,
      showBackButton: false,
      onPressedNextButton: widget.onNext == null ? null : _onPressedNext,
      children: <Widget>[
        const SafeArea(child: Empty()),
        const Padding(
          padding: insetsHorizontalDefault,
          child: WatermarkLogo(
            icon: CustomIcons.catches,
          ),
        ),
        const VerticalSpace(paddingDefault),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).onboardingJourneyCatchFieldDescription,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: stylePrimary(context),
          ),
        ),
        const VerticalSpace(paddingDefault),
        ..._buildFieldOptions(),
      ],
    );
  }

  List<Widget> _buildFieldOptions() {
    return allCatchFieldsSorted(context).map((field) {
      var isEnabled = field.isRemovable;

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
