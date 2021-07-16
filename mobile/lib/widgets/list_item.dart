import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../res/color.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/dialog_utils.dart';
import '../widgets/button.dart';
import '../widgets/widget.dart';
import 'checkbox_input.dart';

/// A custom [ListTile]-like widget with app default properties. This widget
/// also automatically adjusts its height to fit its content, unlike [ListTile].
class ListItem extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  ListItem({
    Key? key,
    this.padding,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use default styling for text widgets.
    var title = this.title;
    if (title is Text) {
      title = DefaultTextStyle(
        style: stylePrimary(context, enabled: enabled),
        child: title,
      );
    }

    var subtitle = this.subtitle;
    if (subtitle is Text) {
      subtitle = DefaultTextStyle(
        style: styleSubtitle(context, enabled: enabled),
        child: subtitle,
      );
    }

    // Use the Material default for icon color.
    var leading = this.leading;
    if (leading is Icon) {
      leading = IconTheme.merge(
        data: IconThemeData(color: Colors.black45),
        child: leading,
      );
    }

    return InkWell(
      onTap: onTap,
      child: HorizontalSafeArea(
        child: Padding(
          padding: padding ?? insetsDefault,
          child: Row(
            children: [
              leading ?? Empty(),
              leading == null ? Empty() : HorizontalSpace(paddingWidgetDouble),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title ?? Empty(),
                    subtitle ?? Empty(),
                  ],
                ),
              ),
              trailing == null ? Empty() : HorizontalSpace(paddingWidget),
              trailing ?? Empty(),
            ],
          ),
        ),
      ),
    );
  }
}

class PickerListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsets? padding;
  final bool isEnabled;
  final bool isSelected;

  /// True renders a [PaddedCheckbox] as the trailing widget, false renders
  /// a check mark [Icon] if [isSelected] is true, or [Empty] if false.
  final bool isMulti;

  /// See [ListItem.onTap].
  final VoidCallback? onTap;

  /// Called when a checkbox state changes. A checkbox is only rendered if
  /// [isMulti] is true.
  ///
  /// See [PaddedCheckbox.onChanged].
  final void Function(bool)? onCheckboxChanged;

  PickerListItem({
    required this.title,
    this.subtitle,
    this.padding,
    this.isEnabled = true,
    this.isSelected = false,
    this.isMulti = false,
    this.onTap,
    this.onCheckboxChanged,
  }) : assert(isNotEmpty(title));

  @override
  Widget build(BuildContext context) {
    return EnabledOpacity(
      enabled: isEnabled,
      child: ListItem(
        padding: padding,
        title: Text(title),
        subtitle: isNotEmpty(subtitle)
            ? Text(
                subtitle!,
                style: styleSubtitle(context),
              )
            : null,
        enabled: isEnabled,
        onTap: onTap,
        trailing: _buildListItemTrailing(context),
      ),
    );
  }

  Widget _buildListItemTrailing(BuildContext context) {
    if (isMulti) {
      // Checkboxes for multi-select pickers.
      return PaddedCheckbox(
        enabled: isEnabled,
        checked: isSelected,
        onChanged: onCheckboxChanged,
      );
    }

    // A simple check mark icon for initial value for single item pickers.
    return AnimatedVisibility(
      visible: isSelected,
      child: Icon(
        Icons.check,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class ExpansionListItem extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final Function(bool)? onExpansionChanged;
  final bool toBottomSafeArea;

  ExpansionListItem({
    required this.title,
    this.children = const [],
    this.onExpansionChanged,
    this.toBottomSafeArea = false,
  });

  @override
  _ExpansionListItemState createState() => _ExpansionListItemState();
}

class _ExpansionListItemState extends State<ExpansionListItem> {
  final GlobalKey _key = GlobalKey();

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: widget.toBottomSafeArea,
      child: Column(
        children: [
          _divider,
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              accentColor: colorInputIconAccent,
              unselectedWidgetColor: colorInputIconAccent,
            ),
            child: ExpansionTile(
              key: _key,
              title: widget.title,
              children: widget.children,
              onExpansionChanged: (expanded) {
                setState(() {
                  _expanded = expanded;
                });
                widget.onExpansionChanged?.call(expanded);
              },
            ),
          ),
          _divider,
        ],
      ),
    );
  }

  Widget get _divider =>
      MinDivider(color: _expanded ? null : Colors.transparent);
}

/// A custom [ListTile]-like [Widget] that animates leading and trailing
/// widgets for managing the item associated with [ManageableListItem].
///
/// When editing:
/// - A "Delete" icon is rendered as the leading [Widget].
/// - A fake "Edit" button is rendered as the trailing [Widget]. The edit
///   button isn't clickable. Instead, the entire row is clickable and when
///   editing, tapping the row triggers the edit action.
/// - When the "Delete" button is pressed, a delete confirmation dialog is
///   shown.
class ManageableListItem extends StatelessWidget {
  final Widget child;

  /// The trailing [Widget] to show when not editing.
  final Widget? trailing;

  /// Invoked when the item is tapped.
  final VoidCallback? onTap;

  /// Called when the delete button is pressed. Useful for pre-database
  /// validation, such as when trying to delete an [Entity] required by another
  /// [Entity].
  ///
  /// If null, or false is returned, a default delete confirmation dialog is
  /// shown.
  ///
  /// If non-null and true is returned, the default delete confirmation dialog
  /// is not shown.
  final bool Function()? onTapDeleteButton;

  /// Return the message that is shown in the delete confirmation dialog.
  final Widget Function(BuildContext)? deleteMessageBuilder;

  /// Invoked when the delete action is confirmed by the user.
  final VoidCallback? onConfirmDelete;

  /// When true, a "Delete" icon is rendered as the leading [Widget], and a fake
  /// "Edit" button as the trailing [Widget].
  final bool editing;

  /// When true, renders the entire [Widget] as disabled, and is not clickable.
  final bool enabled;

  ManageableListItem({
    required this.child,
    this.deleteMessageBuilder,
    this.onConfirmDelete,
    this.onTap,
    this.onTapDeleteButton,
    this.trailing,
    this.editing = false,
    this.enabled = true,
  }) : assert(onTapDeleteButton != null ||
            (deleteMessageBuilder != null && onConfirmDelete != null));

  Widget build(BuildContext context) {
    var child = this.child;
    if (child is Text) {
      child = DefaultTextStyle(
        style: stylePrimary(context),
        child: child,
      );
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: EnabledOpacity(
        enabled: enabled,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildDeleteIcon(context),
              Expanded(
                child: Padding(
                  padding: insetsDefault,
                  child: child,
                ),
              ),
              _buildTrailing(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteIcon(BuildContext context) {
    return _RowEndsCrossFade(
      state: editing ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Padding(
        padding: insetsLeftDefault,
        child: MinimumIconButton(
          icon: Icons.delete,
          color: Colors.red,
          onTap: () {
            if (onTapDeleteButton == null) {
              _showDeleteConfirmation(context);
            } else {
              if (!onTapDeleteButton!()) {
                _showDeleteConfirmation(context);
              }
            }
          },
        ),
      ),
      secondChild: Empty(),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDeleteDialog(
      context: context,
      description: deleteMessageBuilder!(context),
      onDelete: onConfirmDelete,
    );
  }

  Widget _buildTrailing(BuildContext context) {
    Widget trailingWidget;
    if (trailing == null || trailing is Empty) {
      // We don't want to show additional padding if there's no trailing
      // widget, or the trailing widget is already empty.
      trailingWidget = Empty();
    } else {
      trailingWidget = Padding(
        padding: insetsRightDefault,
        child: trailing,
      );
    }

    return _RowEndsCrossFade(
      state: editing ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Padding(
        padding: insetsRightDefault,
        child: Text(
          Strings.of(context).edit.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: fontWeightBold,
          ),
          overflow: TextOverflow.visible,
          maxLines: 1,
        ),
      ),
      secondChild: trailingWidget,
    );
  }
}

class _RowEndsCrossFade extends StatelessWidget {
  // Using a fixed height for child widgets allows for a smoother transition
  // where the height of the animation doesn't change.
  static const _maxTrailingHeight = 30.0;

  final CrossFadeState state;
  final Widget firstChild;
  final Widget secondChild;

  _RowEndsCrossFade({
    required this.state,
    required this.firstChild,
    required this.secondChild,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: state,
      duration: defaultAnimationDuration,
      firstChild: _buildChildContainer(firstChild),
      secondChild: _buildChildContainer(secondChild),
      // A custom layout builder is used here to remove "jarring" result when
      // using AnimatedCrossFade with fixed size children. More details:
      // https://github.com/flutter/flutter/issues/10243#issuecomment-535287136
      layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
        return Stack(
          clipBehavior: Clip.none,
          // Align the non-positioned child to center.
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              key: bottomChildKey,
              // Instead of forcing the positioned child to a width
              // with left / right, just stick it to the top.
              top: 0,
              child: bottomChild,
            ),
            Positioned(
              key: topChildKey,
              child: topChild,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChildContainer(Widget child) {
    return Container(
      height: _maxTrailingHeight,
      child: Center(
        child: child,
      ),
    );
  }
}
