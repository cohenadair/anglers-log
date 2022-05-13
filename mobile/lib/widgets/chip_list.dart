import 'package:flutter/material.dart';

import '../res/dimen.dart';
import 'widget.dart';

class ChipList extends StatelessWidget {
  static const _chipHeight = 32.0;

  final List<Widget> children;
  final EdgeInsets? containerPadding;
  final EdgeInsets? listPadding;

  const ChipList({
    required this.children,
    this.containerPadding,
    this.listPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removes default padding of ActionChip.
      height: _chipHeight + paddingDefault,
      padding: containerPadding,
      child: ListView.separated(
        padding: listPadding,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, i) => const HorizontalSpace(paddingSmall),
        itemBuilder: (context, i) => children[i],
        itemCount: children.length,
      ),
    );
  }
}
