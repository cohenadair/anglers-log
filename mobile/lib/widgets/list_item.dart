import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/widget.dart';

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
  final ScrollController scrollController;

  ExpansionListItem({
    @required this.title,
    this.children,
    this.onExpansionChanged,
    this.toBottomSafeArea = false,
    this.scrollController,
  });

  @override
  _ExpansionListItemState createState() => _ExpansionListItemState();
}

class _ExpansionListItemState extends State<ExpansionListItem> {
  final GlobalKey _key = GlobalKey();
  double _previousScrollOffset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: widget.toBottomSafeArea,
      child: ExpansionTile(
        key: _key,
        title: widget.title,
        children: widget.children,
        onExpansionChanged: (bool isExpanded) {
          widget.onExpansionChanged?.call(isExpanded);

          if (isExpanded && widget.scrollController != null) {
            _previousScrollOffset = widget.scrollController.offset;

            // This is a hack to scroll after ExpansionTile has finished
            // animating, since there is no built in functionality to fire an
            // event after the expansion animation is finished.
            //
            // Duration is the duration of the expansion + 25 ms for insurance.
            Timer(Duration(milliseconds: 200 + 25), () {
              _scrollIfNeeded();
            });
          }
        },
      ),
    );
  }

  void _scrollIfNeeded() {
    if (_key.currentContext == null || widget.scrollController == null) {
      return;
    }

    RenderBox box = _key.currentContext.findRenderObject() as RenderBox;
    widget.scrollController.animateTo(
      min(widget.scrollController.position.maxScrollExtent,
          _previousScrollOffset + box.size.height),
      duration: defaultAnimationDuration,
      curve: Curves.linear,
    );
  }
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
  final Widget title;

  /// The trailing [Widget] to show when not editing.
  final Widget trailing;

  /// Invoked when the item is tapped.
  final VoidCallback onTap;

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
    @required this.title,
    this.deleteMessageBuilder,
    this.onConfirmDelete,
    this.onTap,
    this.trailing,
    this.editing = false,
    this.enabled = true,
  });

  @override
  _ManageableListItemState createState() => _ManageableListItemState();
}

class _ManageableListItemState extends State<ManageableListItem> with
    SingleTickerProviderStateMixin
{
  final Duration _editAnimDuration = Duration(milliseconds: 150);

  AnimationController _editAnimController;
  Animation<double> _deleteIconSizeAnim;

  @override
  void initState() {
    super.initState();

    _editAnimController = AnimationController(
      duration: _editAnimDuration,
      vsync: this,
    );
    _deleteIconSizeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_editAnimController);
  }

  @override
  void dispose() {
    super.dispose();
    _editAnimController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editing) {
      _editAnimController.forward();
    } else {
      _editAnimController.reverse();
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
              Padding(
                padding: insetsDefault,
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.subtitle1,
                  child: widget.title,
                ),
              ),
              Spacer(),
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
          onTap: () => showDeleteDialog(
            context: context,
            description: widget.deleteMessageBuilder(context),
            onDelete: widget.onConfirmDelete,
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    Key key;
    Widget trailing = Empty();
    if (widget.editing) {
      key = ValueKey(1);
      trailing = RightChevronIcon();
    } else if (widget.trailing != null) {
      key = ValueKey(2);
      trailing = widget.trailing;
    }

    return AnimatedSwitcher(
      duration: _editAnimDuration,
      child: Padding(
        // Key is required here for animation (since widget type doesn't
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