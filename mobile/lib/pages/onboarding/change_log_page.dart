import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/onboarding/onboarding_page.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/widgets/bullet_list.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:quiver/strings.dart';
import 'package:version/version.dart';

import '../../res/dimen.dart';
import '../../res/gen/custom_icons.dart';
import '../../widgets/widget.dart';

class ChangeLogPage extends StatelessWidget {
  final VoidCallback onTapContinue;

  const ChangeLogPage({
    required this.onTapContinue,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      showBackButton: false,
      nextButtonText: Strings.of(context).continueString,
      onPressedNextButton: () => _onTapContinue(context),
      children: [
        Padding(
          padding: insetsHorizontalDefault,
          child: WatermarkLogo(
            icon: CustomIcons.catches,
            title: Strings.of(context).changeLogPageTitle,
          ),
        ),
        const VerticalSpace(paddingDefault),
        _build2_1_4(context),
        _build2_1_3(context),
        _build2_1_2(context),
        _build2_1_0(context),
        _build2_0_22(context),
      ],
    );
  }

  Widget _build2_1_4(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.1.5")),
      isExpanded: true,
      children: [
        _buildChangeList({
          Strings.of(context).changeLog_215_1,
        }),
      ],
    );
  }

  Widget _build2_1_3(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.1.3")),
      isExpanded: false,
      children: [
        _buildChangeList({
          Strings.of(context).changeLog_213_1,
          Strings.of(context).changeLog_213_2,
          Strings.of(context).changeLog_213_3,
          Strings.of(context).changeLog_213_4,
        }),
      ],
    );
  }

  Widget _build2_1_2(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.1.2")),
      isExpanded: false,
      children: [
        _buildChangeList({
          Strings.of(context).changeLog_212_1,
          Strings.of(context).changeLog_212_2,
          Strings.of(context).changeLog_212_3,
          Strings.of(context).changeLog_212_4,
        }),
      ],
    );
  }

  Widget _build2_1_0(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.1.1")),
      isExpanded: false,
      children: [
        _buildChangeList({
          Strings.of(context).changeLog_210_1,
          Strings.of(context).changeLog_210_2,
          Strings.of(context).changeLog_210_3,
          Strings.of(context).changeLog_210_4,
        }),
      ],
    );
  }

  Widget _build2_0_22(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.0.22")),
      children: [
        _buildChangeList({
          Strings.of(context).changeLog_2022_1,
          Strings.of(context).changeLog_2022_2,
          Strings.of(context).changeLog_2022_3,
          Strings.of(context).changeLog_2022_4,
          Strings.of(context).changeLog_2022_5,
          Strings.of(context).changeLog_2022_6,
        }),
      ],
    );
  }

  Widget _buildChangeList(Set<String> items) {
    return BulletList(
      padding: insetsHorizontalDefaultBottomDefault,
      items: items,
    );
  }

  String _buildVersionText(BuildContext context, String version) {
    assert(isNotEmpty(version));

    var result = version;
    var oldVersion = UserPreferenceManager.of(context).appVersion;
    if (isNotEmpty(oldVersion) &&
        Version.parse(oldVersion!) == Version.parse(version)) {
      result += " (${Strings.of(context).changeLogPagePreviousVersion})";
    }

    return result;
  }

  Future<void> _onTapContinue(BuildContext context) async {
    UserPreferenceManager.of(context).updateAppVersion();
    onTapContinue();
  }
}
