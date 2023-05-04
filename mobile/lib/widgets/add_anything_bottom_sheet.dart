import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/utils/entity_utils.dart';
import 'package:mobile/widgets/our_bottom_sheet.dart';
import 'package:mobile/widgets/widget.dart';

import '../res/dimen.dart';

/// Shows a bottom sheet widget with a grid of everything the user can add to
/// their log. The returned [EntitySpec] object represents the item that was
/// picked, or null if no item was picked.
Future<EntitySpec?> showAddAnythingBottomSheet(BuildContext context) {
  return showOurBottomSheet<EntitySpec?>(
    context,
    (context) => const _AddAnythingBottomSheet(),
  );
}

class _AddAnythingBottomSheet extends StatelessWidget {
  // The smallest width each item can be such that all text remains on 2 lines
  // (in English).
  static const _itemSize = 61.0;
  static const _itemTitleMaxLines = 2;

  const _AddAnythingBottomSheet();

  @override
  Widget build(BuildContext context) {
    return OurBottomSheet(
      title: Strings.of(context).addAnythingTitle,
      children: [
        Wrap(
          children: allEntitySpecs
              .where((e) => e.canAdd)
              .map((spec) => _buildItem(context, spec))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, EntitySpec spec) {
    if (!spec.isTracked(context)) {
      return const Empty();
    }

    return InkWell(
      onTap: () => Navigator.of(context).pop(spec),
      child: Padding(
        padding: insetsDefault,
        child: SizedBox(
          width: _itemSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: insetsMedium,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colorGreyMedium,
                  ),
                ),
                child: DefaultColorIcon(spec.icon),
              ),
              Padding(
                padding: insetsTopSmall,
                child: Text(
                  spec.singularName(context),
                  textAlign: TextAlign.center,
                  maxLines: _itemTitleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
