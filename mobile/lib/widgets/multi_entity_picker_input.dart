import 'package:flutter/material.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:protobuf/protobuf.dart';

import '../entity_manager.dart';
import 'input_controller.dart';
import 'multi_list_picker_input.dart';
import 'widget.dart';

/// A convenience widget for picking multiple entities backed by a
/// [EntityManager].
class MultiEntityPickerInput<T extends GeneratedMessage>
    extends StatelessWidget {
  final EntityManager<T> manager;
  final SetInputController<Id> controller;
  final String emptyValue;
  final bool isHidden;
  final Widget Function(ManageableListPagePickerSettings<T>)? listPage;
  final void Function(Set<Id>)? onPicked;

  /// Used for when a picker page can have multiple entities displayed, such
  /// as a FishingSpotListPage, which shows bodies of water as well as
  /// fishing spots. In these cases a definitive type T does not work.
  final Widget? customListPage;

  const MultiEntityPickerInput({
    required this.manager,
    required this.controller,
    required this.emptyValue,
    this.isHidden = false,
    this.listPage,
    this.onPicked,
    this.customListPage,
  });

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return Empty();
    }

    assert(listPage != null || customListPage != null);

    return EntityListenerBuilder(
      managers: [manager],
      builder: (context) {
        // Fetch latest values from the database.
        var values = controller.value.isNotEmpty
            ? manager.list(controller.value).toSet()
            : <T>{};
        var displayValues =
            values.map((e) => manager.displayName(context, e)).toSet();

        return MultiListPickerInput(
          padding: insetsHorizontalDefaultVerticalWidget,
          values: displayValues,
          emptyValue: (context) => emptyValue,
          onTap: () => showPickerPage(context, values),
        );
      },
    );
  }

  void showPickerPage(BuildContext context, Set<T> values) {
    var pickerPage = customListPage;
    pickerPage ??= listPage!(
      ManageableListPagePickerSettings<T>(
        onPicked: (context, entities) {
          onPicked?.call(entities.map((e) => manager.id(e)).toSet());
          return true;
        },
        initialValues: values,
      ),
    );
    push(context, pickerPage);
  }
}
