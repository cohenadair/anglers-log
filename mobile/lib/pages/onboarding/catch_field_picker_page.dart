import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../model/gen/anglerslog.pb.dart';
import '../../preferences_manager.dart';
import '../../res/dimen.dart';
import '../../res/gen/custom_icons.dart';
import '../../utils/catch_utils.dart';
import '../../utils/page_utils.dart';
import '../../widgets/checkbox_input.dart';
import '../../widgets/list_item.dart';
import '../../widgets/text.dart';
import '../../widgets/widget.dart';
import 'manage_fields_page.dart';
import 'onboarding_page.dart';

class CatchFieldPickerPage extends StatefulWidget {
  @override
  _CatchFieldPickerPageState createState() => _CatchFieldPickerPageState();
}

class _CatchFieldPickerPageState extends State<CatchFieldPickerPage> {
  List<Id> _selectedFields;

  PreferencesManager get _preferencesManager => PreferencesManager.of(context);

  @override
  void initState() {
    super.initState();

    _selectedFields = allCatchFields()
        .where((field) => !field.removable)
        .map((field) => field.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      padding: insetsZero,
      onPressedNextButton: _onPressedNext,
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
          child: PrimaryLabel(
            Strings.of(context).onboardingJourneyCatchFieldDescription,
            overflow: TextOverflow.visible,
            align: TextAlign.center,
          ),
        ),
        VerticalSpace(paddingWidget),
      ]..addAll(_buildFieldOptions()),
    );
  }

  List<Widget> _buildFieldOptions() {
    return allCatchFieldsSorted(context).map((field) {
      var isEnabled = field.removable;

      var subtitle = field.description == null
          ? null
          : field.description.call(context);
      if (subtitle == null && !isEnabled) {
        subtitle = Strings.of(context).inputGenericRequired;
      }

      return PickerListItem(
        title: field.name(context),
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
    _preferencesManager.catchFieldIds = _selectedFields;
    push(context, ManageFieldsPage());
  }
}
