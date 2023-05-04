import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';

import '../res/dimen.dart';
import '../widgets/widget.dart';

/// A widget that will fill a portion of itself with a given color.
class FilledRow extends StatelessWidget {
  static final Color _emptyBgColor = Colors.grey.withOpacity(0.15);

  final String label;
  final EdgeInsets labelPadding;

  final double height;
  final double cornerRadius;

  /// The maximum value or span of the row, filled with a [_emptyBgColor] color.
  final double maxValue;

  /// The value of the row, filled with [fillColor].
  final int value;

  /// If false, the value label will be hidden.
  final bool showValue;

  /// The color with which to fill the value of the row.
  final Color? fillColor;

  /// A padding value used in row width calculation. This _does not_ add padding
  /// to the [FilledRow] widget. This is meant to the padding value of the
  /// parent widget.
  final EdgeInsets padding;

  final VoidCallback? onTap;

  final String Function()? valueBuilder;

  const FilledRow({
    required this.height,
    required this.maxValue,
    required this.value,
    required this.label,
    this.showValue = true,
    this.fillColor,
    this.labelPadding = insetsHorizontalDefault,
    this.onTap,
    this.cornerRadius = 0,
    this.valueBuilder,
    this.padding = insetsZero,
  });

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(cornerRadius);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.hardEdge,
      // Material required here to show InkWell on top of Ink as well as clip
      // Ink to parent Container.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              _buildEmptyContainer(context),
              _buildFilledContainer(context),
              _buildText(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyContainer(BuildContext context) {
    return Ink(
      width: MediaQuery.of(context).size.width,
      height: height,
      color: _emptyBgColor,
    );
  }

  Widget _buildFilledContainer(BuildContext context) {
    var filledWidth = value.toDouble() /
        maxValue *
        (MediaQuery.of(context).size.width - padding.left - padding.right)
            .abs();
    return AnimatedContainer(
      duration: animDurationSlow,
      width: showValue ? filledWidth : 0,
      child: Container(
        color: fillColor ?? context.colorDefault,
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    var text = label;
    if (showValue) {
      text += " (${valueBuilder?.call() ?? value})";
    }

    return Padding(
      padding: labelPadding,
      child: Text(text, overflow: TextOverflow.ellipsis),
    );
  }
}
