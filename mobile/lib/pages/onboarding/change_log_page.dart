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
        _build2_6_0(context),
        _build2_5_2(context),
        _build2_5_1(context),
        _build2_5_0(context),
        _build2_4_3(context),
        _build2_4_2(context),
        _build2_4_0(context),
        _build2_3_4(context),
        _build2_3_3(context),
        _build2_3_2(context),
        _build2_3_0(context),
        _build2_2_0(context),
        _build2_1_6(context),
        _build2_1_5(context),
        _build2_1_3(context),
        _build2_1_2(context),
        _build2_1_0(context),
        _build2_0_22(context),
      ],
    );
  }

  Widget _build2_6_0(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.6.0")),
      isExpanded: true,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_260_1),
            BulletListItem(Strings.of(context).changeLog_260_2),
            BulletListItem(Strings.of(context).changeLog_260_3),
            BulletListItem(Strings.of(context).changeLog_260_4),
            BulletListItem(Strings.of(context).changeLog_260_5),
          },
        ),
      ],
    );
  }

  Widget _build2_5_2(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.5.2")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_252_1),
            BulletListItem(Strings.of(context).changeLog_252_2),
            BulletListItem(Strings.of(context).changeLog_252_3),
            BulletListItem(Strings.of(context).changeLog_252_4),
          },
        ),
      ],
    );
  }

  Widget _build2_5_1(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.5.1")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_251_1),
          },
        ),
      ],
    );
  }

  Widget _build2_5_0(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.5.0")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_250_1),
            BulletListItem(Strings.of(context).changeLog_250_2),
            BulletListItem(Strings.of(context).changeLog_250_3),
            BulletListItem(Strings.of(context).changeLog_250_4),
            BulletListItem(Strings.of(context).changeLog_250_5),
          },
        ),
      ],
    );
  }

  Widget _build2_4_3(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.4.3")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_243_1),
          },
        ),
      ],
    );
  }

  Widget _build2_4_2(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.4.2")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_241_1),
            BulletListItem(Strings.of(context).changeLog_241_2),
            BulletListItem(Strings.of(context).changeLog_241_3),
            BulletListItem(Strings.of(context).changeLog_241_4),
            BulletListItem(Strings.of(context).changeLog_241_5),
          },
        ),
      ],
    );
  }

  Widget _build2_4_0(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.4.0")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_240_1),
            BulletListItem(Strings.of(context).changeLog_240_2),
            BulletListItem(Strings.of(context).changeLog_240_3),
            BulletListItem(Strings.of(context).changeLog_240_4),
            BulletListItem(Strings.of(context).changeLog_240_5),
            BulletListItem(Strings.of(context).changeLog_240_6),
          },
        ),
      ],
    );
  }

  Widget _build2_3_4(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.3.4")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_234_1),
            BulletListItem(Strings.of(context).changeLog_234_2),
            BulletListItem(Strings.of(context).changeLog_234_3),
            BulletListItem(Strings.of(context).changeLog_234_4),
          },
        ),
      ],
    );
  }

  Widget _build2_3_3(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.3.3")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_233_1),
            BulletListItem(Strings.of(context).changeLog_233_2),
          },
        ),
      ],
    );
  }

  Widget _build2_3_2(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.3.2")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(Strings.of(context).changeLog_232_1),
          },
        ),
      ],
    );
  }

  Widget _build2_3_0(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.3.1")),
      isExpanded: false,
      children: [
        BulletList(
          padding: insetsHorizontalDefaultBottomDefault,
          items: {
            BulletListItem(
              Strings.of(context).changeLog_230_1,
              const Icon(iconGpsTrail, color: Colors.black),
            ),
            BulletListItem(Strings.of(context).changeLog_230_2),
            BulletListItem(Strings.of(context).changeLog_230_3),
            BulletListItem(Strings.of(context).changeLog_230_4),
            BulletListItem(Strings.of(context).changeLog_230_5),
          },
        ),
      ],
    );
  }

  Widget _build2_2_0(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.2.0")),
      isExpanded: false,
      children: [
        _buildStringChangeList({
          Strings.of(context).changeLog_220_1,
          Strings.of(context).changeLog_220_2,
          Strings.of(context).changeLog_220_3,
        }),
      ],
    );
  }

  Widget _build2_1_6(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.1.6")),
      isExpanded: false,
      children: [
        _buildStringChangeList({
          Strings.of(context).changeLog_216_1,
          Strings.of(context).changeLog_216_2,
          Strings.of(context).changeLog_216_3,
          Strings.of(context).changeLog_216_4,
          Strings.of(context).changeLog_216_5,
        }),
      ],
    );
  }

  Widget _build2_1_5(BuildContext context) {
    return ExpansionListItem(
      title: Text(_buildVersionText(context, "2.1.5")),
      isExpanded: false,
      children: [
        _buildStringChangeList({
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
        _buildStringChangeList({
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
        _buildStringChangeList({
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
        _buildStringChangeList({
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
        _buildStringChangeList({
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

  Widget _buildStringChangeList(Set<String> items) {
    return BulletList(
      padding: insetsHorizontalDefaultBottomDefault,
      items: items.map((e) => BulletListItem(e)).toSet(),
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
