import 'package:flutter/material.dart';

import '../res/color.dart';
import '../res/dimen.dart';
import '../utils/dialog_utils.dart';
import '../widgets/button.dart';
import '../widgets/widget.dart';

/// A [ListTile] wrapper with app default properties.
class ListItem extends StatelessWidget {
  final EdgeInsets contentPadding;
  final Widget title;
  final Widget subtitle;
  final Widget leading;
  final Widget trailing;
  final VoidCallback onTap;
  final bool enabled;

  ListItem({
    this.contentPadding,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: ListTile(
        contentPadding: contentPadding,
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        enabled: enabled,
      ),
    );
  }
}

class ExpansionListItem extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final Function(bool) onExpansionChanged;
  final bool toBottomSafeArea;

  ExpansionListItem({
    @required this.title,
    this.children,
    this.onExpansionChanged,
    this.toBottomSafeArea = false,
  })  : assert(toBottomSafeArea != null),
        assert(title != null);

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
/// - A [RightChevronIcon] is rendered as the trailing [Widget].
/// - When the "Delete" button is pressed, a delete confirmation dialog is
///   shown.
class ManageableListItem extends StatefulWidget {
  final Widget child;

  /// The trailing [Widget] to show when not editing.
  final Widget trailing;

  /// Invoked when the item is tapped.
  final VoidCallback onTap;

  /// Called when the delete button is pressed. Useful for pre-database
  /// validation, such as when trying to delete an [Entity] required by another
  /// [Entity].
  ///
  /// If null, or false is returned, a default delete confirmation dialog is
  /// shown.
  ///
  /// If non-null and true is returned, the default delete confirmation dialog
  /// is not shown.
  final bool Function() onTapDeleteButton;

  /// Return the message that is shown in the delete confirmation dialog.
  final Widget Function(BuildContext) deleteMessageBuilder;

  /// Invoked when the delete action is confirmed by the user.
  final VoidCallback onConfirmDelete;

  /// When true, a "Delete" icon is rendered as the leading [Widget], and a
  /// [RightChevronIcon] as the trailing.
  final bool editing;

  /// When true, renders the entire [Widget] as disabled, and is not clickable.
  final bool enabled;

  ManageableListItem({
    @required this.child,
    this.deleteMessageBuilder,
    this.onConfirmDelete,
    this.onTap,
    this.onTapDeleteButton,
    this.trailing,
    this.editing = false,
    this.enabled = true,
  }) : assert(onTapDeleteButton != null ||
            (deleteMessageBuilder != null && onConfirmDelete != null));

  @override
  _ManageableListItemState createState() => _ManageableListItemState();
}

class _ManageableListItemState extends State<ManageableListItem>
    with SingleTickerProviderStateMixin {
  AnimationController _editAnimController;
  Animation<double> _deleteIconSizeAnim;

  @override
  void initState() {
    super.initState();

    _editAnimController = AnimationController(
      duration: defaultAnimationDuration,
      vsync: this,
    );
    _deleteIconSizeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_editAnimController);
  }

  @override
  void dispose() {
    _editAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editing) {
      _editAnimController.forward();
    } else {
      _editAnimController.reverse();
    }

    var child = widget.child;
    if (child is Text) {
      // If the child is just a plain Text widget, style it the same as a
      // system ListTile.
      child = DefaultTextStyle(
        style: Theme.of(context).textTheme.subtitle1,
        child: child,
      );
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: EnabledOpacity(
        enabled: widget.enabled,
        child: InkWell(
          onTap: widget.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildDeleteIcon(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left:
                        widget.editing ? paddingDefaultDouble : paddingDefault,
                    right: paddingDefault,
                    top: paddingDefault,
                    bottom: paddingDefault,
                  ),
                  child: child,
                ),
              ),
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteIcon() {
    return SizeTransition(
      axis: Axis.horizontal,
      sizeFactor: _deleteIconSizeAnim,
      child: Padding(
        padding: insetsLeftDefault,
        child: MinimumIconButton(
          icon: Icons.delete,
          color: Colors.red,
          onTap: () {
            if (widget.onTapDeleteButton == null) {
              _showDeleteConfirmation();
            } else {
              if (!widget.onTapDeleteButton()) {
                _showDeleteConfirmation();
              }
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDeleteDialog(
      context: context,
      description: widget.deleteMessageBuilder(context),
      onDelete: widget.onConfirmDelete,
    );
  }

  Widget _buildTrailing() {
    Key key = ValueKey(0);
    Widget trailing = Empty();
    if (widget.trailing is RightChevronIcon) {
      // If trailing widget is of the same type as editing trailer, do not
      // reset and therefore, do not animate.
      trailing = widget.trailing;
    } else if (widget.editing) {
      key = ValueKey(1);
      trailing = RightChevronIcon();
    } else if (widget.trailing != null) {
      key = ValueKey(2);
      trailing = widget.trailing;
    }

    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: Padding(
        // Key is required here for animation (since widget type might not
        // change).
        key: key,
        padding: insetsRightDefault,
        child: trailing,
      ),
      transitionBuilder: (widget, animation) => SlideTransition(
        child: widget,
        position: Tween<Offset>(
          begin: Offset(2.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
      ),
    );
  }
}
