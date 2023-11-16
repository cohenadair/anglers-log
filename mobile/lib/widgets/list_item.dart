import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/dialog_utils.dart';
import '../widgets/button.dart';
import '../widgets/widget.dart';
import 'checkbox_input.dart';
import 'photo.dart';
import 'text.dart';

/// A custom [ListTile]-like widget with app default properties. This widget
/// also automatically adjusts its height to fit its content, unlike [ListTile].
class ListItem extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget? title;
  final Widget? subtitle;
  final Widget? subtitle2;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const ListItem({
    Key? key,
    this.padding,
    this.title,
    this.subtitle,
    this.subtitle2,
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
        overflow: TextOverflow.ellipsis,
        child: title,
      );
    }

    var subtitle = this.subtitle;
    if (subtitle is Text) {
      subtitle = DefaultTextStyle(
        style: styleSubtitle(context, enabled: enabled),
        overflow: TextOverflow.ellipsis,
        child: subtitle,
      );
    }

    var subtitle2 = this.subtitle2;
    if (subtitle2 is Text) {
      subtitle2 = DefaultTextStyle(
        style: styleSubtitle(context, enabled: enabled),
        overflow: TextOverflow.ellipsis,
        child: subtitle2,
      );
    }

    return InkWell(
      onTap: onTap,
      child: HorizontalSafeArea(
        child: Padding(
          padding: padding ?? insetsDefault,
          child: Row(
            children: [
              leading ?? const Empty(),
              leading == null
                  ? const Empty()
                  : const HorizontalSpace(paddingXL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title ?? const Empty(),
                    subtitle ?? const Empty(),
                    subtitle2 ?? const Empty(),
                  ],
                ),
              ),
              trailing == null
                  ? const Empty()
                  : const HorizontalSpace(paddingDefault),
              trailing ?? const Empty(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrapper for [ManageableListItem] with a [ManageableListImageItem] child.
/// Generally speaking, [ManageableListItem] and [ManageableListImageItem]
/// shouldn't be used outside a [ManageableListPage]; [ListItem] should be used
/// instead. However, horizontal spacing between the leading and content
/// widgets is different when using a leading thumbnail, so we use this
/// convenience class for such cases.
class ImageListItem extends StatelessWidget {
  final String? imageName;
  final String? title;
  final String? subtitle;
  final String? subtitle2;
  final String? subtitle3;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// See [ManageableListImageItem.showFullImageOnTap].
  final bool showFullImageOnTap;

  /// See [ManageableListImageItem.showPlaceholder].
  final bool showPlaceholder;

  const ImageListItem({
    this.imageName,
    this.title,
    this.subtitle,
    this.subtitle2,
    this.subtitle3,
    this.trailing,
    this.onTap,
    this.showPlaceholder = true,
    this.showFullImageOnTap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ManageableListItem(
      onTap: onTap,
      // In this state, the delete button will never be shown.
      onTapDeleteButton: () => false,
      child: ManageableListImageItem(
        imageName: imageName,
        title: title,
        subtitle: subtitle,
        subtitle2: subtitle2,
        subtitle3: subtitle3,
        trailing: trailing,
        showPlaceholder: showPlaceholder,
        showFullImageOnTap: showFullImageOnTap,
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
      isEnabled: isEnabled,
      child: ListItem(
        padding: padding,
        title: Text(title),
        subtitle: isNotEmpty(subtitle)
            ? Text(
                subtitle!,
                style: styleSubtitle(context),
                overflow: TextOverflow.visible,
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
      child: const ItemSelectedIcon(),
    );
  }
}

class ExpansionListItem extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final Widget? trailing;
  final Function(bool)? onExpansionChanged;
  final bool toBottomSafeArea;
  final bool isExpanded;

  const ExpansionListItem({
    required this.title,
    this.children = const [],
    this.trailing,
    this.onExpansionChanged,
    this.toBottomSafeArea = false,
    this.isExpanded = false,
  });

  @override
  ExpansionListItemState createState() => ExpansionListItemState();
}

class ExpansionListItemState extends State<ExpansionListItem> {
  final GlobalKey _key = GlobalKey();

  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isExpanded;
  }

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
              unselectedWidgetColor: context.colorGreyAccent,
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(secondary: context.colorGreyAccent),
            ),
            child: ExpansionTile(
              key: _key,
              title: widget.title,
              trailing: widget.trailing,
              initiallyExpanded: widget.isExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _expanded = expanded;
                });
                widget.onExpansionChanged?.call(expanded);
              },
              children: widget.children,
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

  final Widget? grandchild;

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

  final bool isCondensed;

  const ManageableListItem({
    required this.child,
    this.grandchild,
    this.deleteMessageBuilder,
    this.onConfirmDelete,
    this.onTap,
    this.onTapDeleteButton,
    this.trailing,
    this.editing = false,
    this.enabled = true,
    this.isCondensed = false,
  });

  @override
  Widget build(BuildContext context) {
    var child = this.child;
    if (child is Text) {
      child = DefaultTextStyle(
        style: stylePrimary(context),
        child: child,
      );
    }

    var grandchild = this.grandchild;
    if (grandchild is Text) {
      grandchild = DefaultTextStyle(
        style: stylePrimary(context),
        child: child,
      );
    }

    if (grandchild != null) {
      grandchild = ManageableListGrandchild(child: grandchild);
    }

    var touchColor = onTap == null ? Colors.transparent : null;

    return SafeArea(
      top: false,
      bottom: false,
      child: EnabledOpacity(
        isEnabled: enabled,
        child: InkWell(
          onTap: onTap,
          splashColor: touchColor,
          highlightColor: touchColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildDeleteIcon(context),
                  Expanded(
                    child: Padding(
                      padding: isCondensed
                          ? insetsHorizontalDefaultVerticalSmall
                          : insetsDefault,
                      child: child,
                    ),
                  ),
                  _buildTrailing(context),
                ],
              ),
              grandchild ?? const Empty(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteIcon(BuildContext context) {
    if (onTapDeleteButton == null &&
        (deleteMessageBuilder == null || onConfirmDelete == null)) {
      return const Empty();
    }

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
      secondChild: const Empty(),
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
      trailingWidget = const Empty();
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
        child: FakeTextButton(Strings.of(context).edit),
      ),
      secondChild: trailingWidget,
    );
  }
}

class ManageableListGrandchild extends StatelessWidget {
  static const leftBorderWidth = 1.0;

  final Widget child;

  const ManageableListGrandchild({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: paddingDefault + paddingDefault,
        bottom: paddingDefault,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              width: leftBorderWidth,
              color: context.colorDefault,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

class ManageableListImageItem extends StatelessWidget {
  final String? imageName;
  final String? title;
  final String? subtitle;
  final String? subtitle2;
  final String? subtitle3;
  final Widget? trailing;

  final TextStyle? subtitleStyle;
  final TextStyle? subtitle2Style;

  /// See [Photo.showFullOnTap].
  final bool showFullImageOnTap;

  /// See [Photo.showPlaceholder].
  final bool showPlaceholder;

  const ManageableListImageItem({
    this.imageName,
    this.title,
    this.subtitle,
    this.subtitleStyle,
    this.subtitle2,
    this.subtitle2Style,
    this.subtitle3,
    this.trailing,
    this.showPlaceholder = true,
    this.showFullImageOnTap = false,
  });

  @override
  Widget build(BuildContext context) {
    var trailing = this.trailing;
    if (trailing != null) {
      trailing = Padding(
        padding: insetsLeftDefault,
        child: trailing,
      );
    }

    return Row(
      children: [
        Photo.listThumbnail(
          imageName,
          showPlaceholder: showPlaceholder,
          showFullOnTap: showFullImageOnTap,
          padding: insetsRightDefault,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleLineText(
                title,
                style: stylePrimary(context),
              ),
              SingleLineText(
                subtitle,
                style: styleSubtitle(context).merge(subtitleStyle),
              ),
              SingleLineText(
                subtitle2,
                style: styleSubtitle(context).merge(subtitle2Style),
              ),
              isEmpty(subtitle3)
                  ? const Empty()
                  : Text(
                      subtitle3!,
                      style: styleSubtitle(context),
                    ),
            ],
          ),
        ),
        trailing ?? const Empty(),
      ],
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

  const _RowEndsCrossFade({
    required this.state,
    required this.firstChild,
    required this.secondChild,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState: state,
      duration: animDurationDefault,
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
    return SizedBox(
      height: _maxTrailingHeight,
      child: Center(
        child: child,
      ),
    );
  }
}
