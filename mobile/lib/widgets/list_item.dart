import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
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