import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/color_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

import 'text.dart';
import 'widget.dart';

class Tile extends StatelessWidget {
  final TileItem item;

  const Tile(this.item);

  @override
  Widget build(BuildContext context) {
    Widget title = const Empty();
    if (isNotEmpty(item.title)) {
      title = TitleLabel.style1(
        item.title!,
        overflow: TextOverflow.ellipsis,
      );
    }

    Widget subtitle1 = const Empty();
    if (isNotEmpty(item.subtitle)) {
      subtitle1 = Padding(
        padding: insetsHorizontalSmall,
        child: TitleLabel.style2(
          context,
          item.subtitle!,
          align: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    Widget subtitle2 = const Empty();
    if (isNotEmpty(item.subtitle2)) {
      subtitle2 = Padding(
        padding: insetsSmall,
        child: Text(
          item.subtitle2!,
          style: stylePrimary(context),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return InkWell(
      onTap: item.onTap,
      borderRadius: defaultBorderRadius,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: defaultBorderRadius,
          color: randomAccentColor(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            title,
            subtitle1,
            subtitle2,
          ],
        ),
      ),
    );
  }
}

class TileRow extends StatelessWidget {
  static const _defaultHeight = 175.0;

  final EdgeInsets? padding;
  final Iterable<TileItem> items;
  final double? height;

  const TileRow({
    this.padding,
    this.items = const [],
    this.height = _defaultHeight,
  });

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for (var (index, item) in items.indexed) {
      children.add(_buildItem(item));
      if (index != items.length - 1) {
        children.add(const HorizontalSpace(paddingDefault));
      }
    }

    return Container(
      padding: padding ?? insetsZero,
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildItem(TileItem item) {
    return Flexible(
      flex: 1,
      child: Tile(item),
    );
  }
}

class TileItem {
  final String? title;
  final String? subtitle;
  final String? subtitle2;
  final VoidCallback? onTap;

  TileItem({
    this.title,
    this.subtitle,
    this.subtitle2,
    this.onTap,
  });

  /// Doesn't use [TileItem.title], since it is very large text. Uses only
  /// [TileItem.subtitle] and [TileItem.subtitle2].
  TileItem.condensedDuration(
    BuildContext context, {
    required int msDuration,
    this.subtitle2,
    this.onTap,
  })  : title = null,
        subtitle = formatDuration(
          context: context,
          millisecondsDuration: msDuration,
          condensed: true,
          numberOfQuantities: 1,
        );

  TileItem.duration(
    BuildContext context, {
    required int msDuration,
    this.subtitle,
    this.subtitle2,
    this.onTap,
  }) : title = formatDuration(
          context: context,
          millisecondsDuration: msDuration,
          condensed: true,
          numberOfQuantities: 1,
        );

  @override
  bool operator ==(Object other) {
    return other is TileItem &&
        title == other.title &&
        subtitle == other.subtitle &&
        subtitle2 == other.subtitle2;
  }

  @override
  int get hashCode => hash3(title, subtitle, subtitle2);
}
