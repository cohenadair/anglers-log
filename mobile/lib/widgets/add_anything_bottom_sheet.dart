import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/utils/entity_utils.dart';
import 'package:mobile/widgets/our_bottom_sheet.dart';
import 'package:mobile/widgets/widget.dart';

import '../res/dimen.dart';
import '../utils/page_utils.dart';

/// A widget that shows a grid of everything the user can add to their log. An
/// [AddAnythingBottomSheet] is meant to be shown inside a bottom sheet using
/// [showOurBottomSheet].
class AddAnythingBottomSheet extends StatelessWidget {
  // The smallest width each item can be such that all text remains on 2 lines
  // (in English).
  static const _itemSize = 61.0;

  const AddAnythingBottomSheet();

  @override
  Widget build(BuildContext context) {
    return OurBottomSheet(
      title: Strings.of(context).addAnythingTitle,
      children: [
        Wrap(
          children:
              allEntitySpecs.map((spec) => _buildItem(context, spec)).toList(),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, EntitySpec spec) {
    if (!spec.isTracked(context)) {
      return Empty();
    }

    var subscriptionManager = SubscriptionManager.of(context);

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        present(
          context,
          spec.isProOnly && subscriptionManager.isFree
              ? ProPage()
              : spec.savePageBuilder(context),
        );
      },
      child: Padding(
        padding: insetsDefault,
        child: SizedBox(
          width: _itemSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Icon(spec.icon, color: Theme.of(context).primaryColor),
                padding: insetsMedium,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
              ),
              Padding(
                padding: insetsTopSmall,
                child: Text(
                  spec.singularName(context),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
