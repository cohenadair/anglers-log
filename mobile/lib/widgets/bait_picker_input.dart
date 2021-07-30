import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../entity_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_list_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import 'input_controller.dart';
import 'multi_list_picker_input.dart';

class BaitPickerInput extends StatelessWidget {
  final SetInputController<BaitAttachment> controller;
  final String Function(BuildContext) emptyValue;

  /// If true, treats an empty controller value as "all" baits and variants
  /// being selected.
  final bool isAllEmpty;

  BaitPickerInput({
    required this.controller,
    required this.emptyValue,
    this.isAllEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    var baitCategoryManager = BaitCategoryManager.of(context);
    var baitManager = BaitManager.of(context);

    return EntityListenerBuilder(
      managers: [
        baitCategoryManager,
        baitManager,
      ],
      builder: (context) {
        return ValueListenableBuilder<Set<BaitAttachment>?>(
          valueListenable: controller,
          builder: (context, _, __) => MultiListPickerInput(
            padding: insetsHorizontalDefaultVerticalWidget,
            values: baitManager
                .attachmentsDisplayValues(controller.value, context)
                .toSet(),
            emptyValue: emptyValue,
            onTap: () => _showBaitListPage(context, baitManager),
          ),
        );
      },
    );
  }

  void _showBaitListPage(BuildContext context, BaitManager baitManager) {
    var allValues = baitManager.baitAttachmentList().toSet();

    push(
      context,
      BaitListPage(
        pickerSettings: BaitListPagePickerSettings(
          onPicked: (context, attachments) {
            if (isAllEmpty && attachments.containsAll(allValues)) {
              controller.clear();
            } else {
              controller.value = attachments;
            }
            return true;
          },
          // TODO: This doesn't work for picked bait variants. May also not
          //  work when selecting "All".
          //  - Create new catch
          //  - Tap No baits
          //  - Select variant
          //  - Go back
          //  - Variant is selected
          //  - Tap variant to open picker page again
          //  - Observe variant isn't selected
          initialValues: isAllEmpty && controller.value.isEmpty
              ? allValues
              : controller.value,
        ),
      ),
    );
  }
}
