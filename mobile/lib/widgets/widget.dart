import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/res/anim.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:adair_flutter_lib/widgets/app_color_icon.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/res/theme.dart';
import 'package:quiver/strings.dart';

import '../model/gen/anglers_log.pb.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';
import '../widgets/text.dart';
import 'button.dart';
import 'input_controller.dart';
import 'list_item.dart';

const iconAngler = Icons.person;
const iconBait = Icons.bug_report;
const iconBaitCategories = CustomIcons.baitCategories;
const iconBodyOfWater = Icons.water;
const iconBottomBarAdd = Icons.add_box_rounded;
const iconCatch = CustomIcons.catches;
const iconCustomField = Icons.build;
const iconFishingSpot = Icons.place;
const iconGear = Icons.phishing;
const iconGpsTrail = Icons.route;
const iconMethod = Icons.list;
const iconSpecies = CustomIcons.species;
const iconTrip = Icons.public;
const iconWaterClarity = CustomIcons.waterClarities;

const animDurationSlow = Duration(milliseconds: 450);

class MinDivider extends StatelessWidget {
  final Color? color;

  const MinDivider({this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: color);
  }
}

class HeadingDivider extends StatelessWidget {
  final String text;
  final bool showDivider;

  /// A widget that's rendered at the right edge of the screen, in the same
  /// [Row] as [text].
  final Widget? trailing;

  const HeadingDivider(this.text, {this.showDivider = true, this.trailing});

  HeadingDivider.withAddButton(
    this.text, {
    required VoidCallback onTap,
    this.showDivider = true,
  }) : trailing = MinimumIconButton(icon: Icons.add, onTap: onTap);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showDivider ? const MinDivider() : const SizedBox(),
        Padding(
          padding: const EdgeInsets.only(
            top: paddingDefault,
            left: paddingDefault,
            right: paddingDefault,
          ),
          // Add SafeArea here so the divider always stretches to the edges
          // of the page.
          child: SafeArea(
            top: false,
            bottom: false,
            child: Row(
              children: [
                Expanded(child: Text(text, style: styleListHeading(context))),
                trailing ?? const SizedBox(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A [HeadingDivider] widget with an optional [IconLabel].
class HeadingNoteDivider extends StatelessWidget {
  final bool hideNote;
  final bool hideDivider;
  final String title;
  final String? note;
  final IconData? noteIcon;
  final EdgeInsets? padding;

  HeadingNoteDivider({
    this.hideNote = true,
    this.hideDivider = false,
    required this.title,
    required this.note,
    required this.noteIcon,
    this.padding,
  }) : assert(isNotEmpty(title)),
       assert(hideNote || (isNotEmpty(note) && noteIcon != null));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? insetsZero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: insetsBottomSmall,
            child: HeadingDivider(title, showDivider: !hideDivider),
          ),
          _buildNote(context),
        ],
      ),
    );
  }

  Widget _buildNote(BuildContext context) {
    return AnimatedSwitcher(
      duration: animDurationDefault,
      child: hideNote
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.only(
                left: paddingDefault,
                right: paddingDefault,
                top: paddingDefault,
              ),
              child: HorizontalSafeArea(
                child: IconLabel(
                  text: note!,
                  textArg: Icon(noteIcon, color: context.colorAppBarContent),
                ),
              ),
            ),
    );
  }
}

/// A widget used to indicate the parent widget responds to the swipe gesture,
/// such as swiping down to close a bottom sheet-style widget.
class SwipeChip extends StatelessWidget {
  final _width = 20.0;
  final _height = 5.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: insetsVerticalSmall,
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: context.colorGreyAccentLight,
          borderRadius: BorderRadius.all(Radius.circular(_height / 2)),
        ),
      ),
    );
  }
}

/// An [Opacity] wrapper whose state depends on the [isEnabled] property.
class EnabledOpacity extends StatelessWidget {
  static const double _disabledOpacity = 0.5;

  final bool isEnabled;
  final Widget child;

  const EnabledOpacity({super.key, required this.child, this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      key: key,
      opacity: isEnabled ? 1.0 : _disabledOpacity,
      child: child,
    );
  }
}

class GreyAccentIcon extends StatelessWidget {
  final IconData data;

  const GreyAccentIcon(this.data);

  @override
  Widget build(BuildContext context) {
    return Icon(data, color: context.colorGreyAccent);
  }
}

class RightChevronIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const GreyAccentIcon(Icons.chevron_right);
  }
}

class DropdownIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const GreyAccentIcon(Icons.arrow_drop_down);
  }
}

class OpenInWebIcon extends StatelessWidget {
  const OpenInWebIcon();

  @override
  Widget build(BuildContext context) {
    return const AppColorIcon(Icons.open_in_new);
  }
}

class ItemSelectedIcon extends StatelessWidget {
  const ItemSelectedIcon();

  @override
  Widget build(BuildContext context) {
    return const AppColorIcon(Icons.check);
  }
}

/// A help popup that fades in and out of view.
class HelpTooltip extends StatelessWidget {
  static const _alpha = 0.70;
  static const _borderRadius = BorderRadius.all(Radius.circular(5.0));

  final Widget? child;
  final bool showing;
  final EdgeInsets margin;

  const HelpTooltip({
    required this.child,
    this.showing = false,
    this.margin = insetsDefault,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedVisibility(
        visible: showing,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: _alpha),
            borderRadius: _borderRadius,
          ),
          padding: insetsDefault,
          margin: margin,
          child: child,
        ),
      ),
    );
  }
}

/// A wrapper for [AnimatedOpacity] with a default duration.
class AnimatedVisibility extends StatelessWidget {
  final bool visible;
  final Widget child;

  const AnimatedVisibility({this.visible = true, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: animDurationDefault,
      child: child,
    );
  }
}

class AppBarDropdownItem<T> extends DropdownMenuItem<T> {
  final String text;

  AppBarDropdownItem({
    required BuildContext context,
    required this.text,
    super.value,
  }) : assert(isNotEmpty(text)),
       super(
         child: Text(
           text,
           // Use the same theme as default AppBar title text.
           style: Theme.of(context).textTheme.titleLarge,
         ),
       );
}

/// A widget that shows a list of horizontal [Chip] widgets that wrap vertically
/// when there is no longer enough horizontal space.
///
/// This widget should be places inside some kind of scroll view, otherwise
/// it could overflow its container.
class ChipWrap extends StatelessWidget {
  final Set<String> items;

  const ChipWrap([this.items = const {}]);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox();
    }

    return Wrap(
      spacing: paddingSmall,
      runSpacing: paddingSmall,
      children: items.map((item) => MinChip(item)).toList(),
    );
  }
}

class MinChip extends StatelessWidget {
  final String label;

  const MinChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class HorizontalSafeArea extends StatelessWidget {
  final Widget child;

  const HorizontalSafeArea({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(top: false, bottom: false, child: child);
  }
}

class HorizontalSliverSafeArea extends StatelessWidget {
  final Widget sliver;

  const HorizontalSliverSafeArea({required this.sliver});

  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(top: false, bottom: false, sliver: sliver);
  }
}

class CatchFavoriteStar extends StatelessWidget {
  static const _largeSize = 40.0;

  final Catch cat;
  final bool large;

  const CatchFavoriteStar(this.cat, {this.large = false});

  @override
  Widget build(BuildContext context) {
    if (!cat.hasIsFavorite() || !cat.isFavorite) {
      return const SizedBox();
    }

    return Padding(
      padding: insetsLeftDefault,
      child: Icon(
        Icons.star,
        size: large ? _largeSize : null,
        color: AppConfig.get.colorAppTheme,
      ),
    );
  }
}

/// A convenience widget to be used at the top of an input [FormPage]. When
/// tapped, [controller] is cleared and the current [Navigator] is popped. This
/// widget will automatically update when [controller.value] changes.
class NoneFormHeader extends StatelessWidget {
  final InputController controller;

  const NoneFormHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, _, __) {
        return Column(
          children: [
            PickerListItem(
              padding: insetsDefault,
              title: Strings.of(context).none,
              isSelected: !controller.hasValue,
              onTap: () {
                controller.clear();
                Navigator.pop(context);
              },
            ),
            const MinDivider(),
          ],
        );
      },
    );
  }
}

class MyBadge extends StatelessWidget {
  static const _size = 12.0;

  final bool isVisible;

  const MyBadge({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: isVisible,
      child: const Icon(
        Icons.brightness_1,
        size: _size,
        color: Colors.redAccent,
      ),
    );
  }
}

class BadgeContainer extends StatelessWidget {
  final Widget child;
  final bool isBadgeVisible;

  const BadgeContainer({required this.child, required this.isBadgeVisible});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          top: 0.0,
          right: 0.0,
          child: MyBadge(isVisible: isBadgeVisible),
        ),
      ],
    );
  }
}
