import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import 'input_controller.dart';
import 'multi_list_picker_input.dart';
import 'widget.dart';

/// A convenience widget for picking entities backed by an [EntityManager].
/// When picking multiple items, a [MultiListPickerInput] is used. When picking
/// a single item, [ListPickerInput] is used.
class EntityPickerInput<T extends GeneratedMessage> extends StatelessWidget {
  final EntityManager<T> manager;
  final bool isHidden;
  final Widget Function(ManageableListPagePickerSettings<T>)? listPage;

  /// Used for when a picker page can have multiple entities displayed, such
  /// as a FishingSpotListPage, which shows bodies of water as well as
  /// fishing spots. In these cases a definitive type T does not work.
  final Widget? customListPage;

  /// Called when items are picked. If this value is not null, the
  /// [InputController] value associated with this widget will _not_ be updated.
  /// If this value _is_ null, the controller's value is automatically updated.
  late final void Function(Set<Id>)? _onPicked;

  late final void Function(Set<Id>) _updateControllerValue;
  late final Set<T> Function() _fetchValues;
  late final bool _isMulti;

  late final SetInputController<Id>? _multiController;
  late final IdInputController? _singleController;

  /// See [MultiListPickerInput.emptyValue].
  late final String? _emptyValue;

  /// See [ListPickerInput.title].
  late final String? _title;

  EntityPickerInput.multi({
    required this.manager,
    required SetInputController<Id> controller,
    required String emptyValue,
    this.isHidden = false,
    this.listPage,
    void Function(Set<Id>)? onPicked,
    this.customListPage,
  }) : assert(isNotEmpty(emptyValue)) {
    _onPicked = onPicked;
    _updateControllerValue = (ids) => controller.value = ids;
    _emptyValue = emptyValue;
    _isMulti = true;
    _fetchValues = () => controller.value.isNotEmpty
        ? manager.list(controller.value).toSet()
        : <T>{};
    _multiController = controller;
  }

  EntityPickerInput.single({
    required this.manager,
    required IdInputController controller,
    required String title,
    this.isHidden = false,
    this.listPage,
    this.customListPage,
    void Function(Id?)? onPicked,
  }) {
    Id? firstOrNull(Set<Id> ids) => ids.isEmpty ? null : ids.first;

    _onPicked = onPicked == null ? null : (ids) => onPicked(firstOrNull(ids));
    _updateControllerValue = (ids) => controller.value = firstOrNull(ids);
    _title = title;
    _isMulti = false;
    _fetchValues = () => manager.entityExists(controller.value)
        ? {manager.entity(controller.value)!}
        : {};
    _singleController = controller;
  }

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return Empty();
    }

    assert(listPage != null || customListPage != null);

    return EntityListenerBuilder(
      managers: [manager],
      builder: (context) {
        ValueListenable listenable;
        if (_isMulti) {
          listenable = _multiController!;
        } else {
          listenable = _singleController!;
        }

        return ValueListenableBuilder(
          valueListenable: listenable,
          builder: (_, __, ___) {
            // Fetch latest values from the database.
            var values = _fetchValues();
            var displayValues =
                values.map((e) => manager.displayName(context, e)).toSet();

            if (_isMulti) {
              return MultiListPickerInput(
                padding: insetsHorizontalDefaultVerticalWidget,
                values: displayValues,
                emptyValue: (context) => _emptyValue!,
                onTap: () => showPickerPage(context, values),
              );
            } else {
              return ListPickerInput(
                title: _title,
                value: displayValues.isEmpty ? null : displayValues.first,
                onTap: () => showPickerPage(context, values),
              );
            }
          },
        );
      },
    );
  }

  void showPickerPage(BuildContext context, Set<T> values) {
    var pickerPage = customListPage;
    pickerPage ??= listPage!(
      ManageableListPagePickerSettings<T>(
        onPicked: (context, entities) {
          var pickedIds = entities.map((e) => manager.id(e)).toSet();

          if (_onPicked == null) {
            _updateControllerValue(pickedIds);
          } else {
            _onPicked!.call(pickedIds);
          }

          return true;
        },
        initialValues: values,
        isMulti: _isMulti,
      ),
    );
    push(context, pickerPage);
  }
}
