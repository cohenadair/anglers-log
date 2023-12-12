import 'package:flutter/material.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/res/theme.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/style.dart';
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

const animDurationDefault = Duration(milliseconds: 150);
const animDurationSlow = Duration(milliseconds: 450);

class Empty extends StatelessWidget {
  const Empty();

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class EmptyOr extends StatelessWidget {
  final Widget Function(BuildContext) childBuilder;

  /// Padding wrapped around the widget returned by [childBuilder].
  final EdgeInsets? padding;

  final bool isShowing;

  const EmptyOr({
    this.isShowing = true,
    required this.childBuilder,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return isShowing
        ? Padding(padding: padding ?? insetsZero, child: childBuilder(context))
        : const Empty();
  }
}

class MinDivider extends StatelessWidget {
  final Color? color;

  const MinDivider({this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: color,
    );
  }
}

class HeadingDivider extends StatelessWidget {
  final String text;
  final bool showDivider;

  /// A widget that's rendered at the right edge of the screen, in the same
  /// [Row] as [text].
  final Widget? trailing;

  const HeadingDivider(
    this.text, {
    this.showDivider = true,
    this.trailing,
  });

  HeadingDivider.withAddButton(
    this.text, {
    required VoidCallback onTap,
    this.showDivider = true,
  }) : trailing = MinimumIconButton(
          icon: Icons.add,
          onTap: onTap,
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showDivider ? const MinDivider() : const Empty(),
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
                Expanded(
                  child: Text(
                    text,
                    style: styleListHeading(context),
                  ),
                ),
                trailing ?? const Empty(),
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
  })  : assert(isNotEmpty(title)),
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
            child: HeadingDivider(
              title,
              showDivider: !hideDivider,
            ),
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
          ? const Empty()
          : Padding(
              padding: const EdgeInsets.only(
                left: paddingDefault,
                right: paddingDefault,
                top: paddingDefault,
              ),
              child: HorizontalSafeArea(
                child: IconLabel(
                  text: note!,
                  textArg: Icon(
                    noteIcon,
                    color: context.colorAppBarContent,
                  ),
                ),
              ),
            ),
    );
  }
}

class Loading extends StatelessWidget {
  static const _size = 20.0;
  static const _strokeWidth = 2.0;

  final EdgeInsets padding;
  final String? label;
  final bool isCentered;
  final bool isAppBar;

  const Loading({
    this.padding = insetsZero,
    this.label,
    this.isCentered = true,
    this.isAppBar = false,
  });

  /// A [Loading] widget to be used in an [AppBar].
  const Loading.appBar()
      : this(
          padding: const EdgeInsets.only(
            right: paddingDefault,
            top: paddingDefault,
          ),
          isCentered: true,
          isAppBar: true,
        );

  @override
  Widget build(BuildContext context) {
    var indicator = SizedBox.fromSize(
      size: const Size(_size, _size),
      child: CircularProgressIndicator(
        strokeWidth: _strokeWidth,
        color: isAppBar ? context.colorText : null,
      ),
    );

    if (isCentered || isNotEmpty(label)) {
      return Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment:
              isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            indicator,
            const VerticalSpace(paddingDefault),
            isEmpty(label) ? const Empty() : Text(label!),
          ],
        ),
      );
    } else {
      return Padding(
        padding: padding,
        child: indicator,
      );
    }
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

  const EnabledOpacity({
    Key? key,
    required this.child,
    this.isEnabled = true,
  }) : super(key: key);

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
    return Icon(
      data,
      color: context.colorGreyAccent,
    );
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

class DefaultColorIcon extends StatelessWidget {
  final IconData data;

  const DefaultColorIcon(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      data,
      color: context.colorDefault,
    );
  }
}

class OpenInWebIcon extends StatelessWidget {
  const OpenInWebIcon();

  @override
  Widget build(BuildContext context) {
    return const DefaultColorIcon(Icons.open_in_new);
  }
}

class ItemSelectedIcon extends StatelessWidget {
  const ItemSelectedIcon();

  @override
  Widget build(BuildContext context) {
    return const DefaultColorIcon(Icons.check);
  }
}

/// A help popup that fades in and out of view.
class HelpTooltip extends StatelessWidget {
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
            color: Colors.black.withOpacity(0.70),
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
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

  const AnimatedVisibility({
    this.visible = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: animDurationDefault,
      child: child,
    );
  }
}

/// A [FutureBuilder] wrapper that shows an [Empty] widget when the given
/// [Future] doesn't have any data.
class EmptyFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T?) builder;

  const EmptyFutureBuilder({
    required this.future,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Empty();
        }
        return builder(context, snapshot.data);
      },
    );
  }
}

class VerticalSpace extends StatelessWidget {
  final double size;

  const VerticalSpace(this.size);

  @override
  Widget build(BuildContext context) => Container(height: size);
}

class HorizontalSpace extends StatelessWidget {
  final double size;

  const HorizontalSpace(this.size);

  @override
  Widget build(BuildContext context) => Container(width: size);
}

class AppBarDropdownItem<T> extends DropdownMenuItem<T> {
  final String text;

  AppBarDropdownItem({
    required BuildContext context,
    required this.text,
    T? value,
  })  : assert(isNotEmpty(text)),
        super(
          child: Text(
            text,
            // Use the same theme as default AppBar title text.
            style: Theme.of(context).textTheme.titleLarge,
          ),
          value: value,
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
      return const Empty();
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

  const HorizontalSafeArea({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: child,
    );
  }
}

class HorizontalSliverSafeArea extends StatelessWidget {
  final Widget sliver;

  const HorizontalSliverSafeArea({
    required this.sliver,
  });

  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(
      top: false,
      bottom: false,
      sliver: sliver,
    );
  }
}

class WatermarkLogo extends StatelessWidget {
  static const _size = 150.0;

  final IconData icon;
  final Color? color;
  final String? title;

  const WatermarkLogo({
    required this.icon,
    this.color,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = const Empty();
    if (isNotEmpty(title)) {
      titleWidget = Padding(
        padding: insetsTopDefault,
        child: TitleLabel.style1(
          title!,
          overflow: TextOverflow.visible,
          align: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        ClipOval(
          child: Container(
            padding: insetsXL,
            color: context.colorGreyAccentLight,
            child: Icon(
              icon,
              size: _size,
              color: color ?? context.colorDefault,
            ),
          ),
        ),
        titleWidget,
      ],
    );
  }
}

class TransparentAppBar extends AppBar {
  TransparentAppBar(
    BuildContext context, {
    Widget? leading,
    VoidCallback? onCloseOverride,
  }) : super(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: leading ??
              CloseButton(
                color: context.colorDefault,
                onPressed: onCloseOverride,
              ),
          systemOverlayStyle: context.appBarSystemStyle,
        );
}

class CatchFavoriteStar extends StatelessWidget {
  static const _largeSize = 40.0;

  final Catch cat;
  final bool large;

  const CatchFavoriteStar(
    this.cat, {
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!cat.hasIsFavorite() || !cat.isFavorite) {
      return const Empty();
    }

    return Padding(
      padding: insetsLeftDefault,
      child: Icon(
        Icons.star,
        size: large ? _largeSize : null,
        color: context.colorDefault,
      ),
    );
  }
}

/// A convenience widget to be used at the top of an input [FormPage]. When
/// tapped, [controller] is cleared and the current [Navigator] is popped. This
/// widget will automatically update when [controller.value] changes.
class NoneFormHeader extends StatelessWidget {
  final InputController controller;

  const NoneFormHeader({
    required this.controller,
  });

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

  const MyBadge({
    required this.isVisible,
  });

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

  const BadgeContainer({
    required this.child,
    required this.isBadgeVisible,
  });

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
