import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

import '../bait_manager.dart';
import '../entity_manager.dart';
import '../log.dart';
import 'widget.dart';

/// A widget that allows users to pick items from a list and assign a quantity
/// value to each item.
class QuantityPickerInput<PickerType extends GeneratedMessage, InputType>
    extends StatelessWidget {
  static const textInputWidth = 50.0;

  final Log _log;
  final String title;
  final String? pickerTitle;

  final QuantityPickerInputDelegate<PickerType, InputType> delegate;

  QuantityPickerInput({
    required this.title,
    required this.delegate,
    this.pickerTitle,
  }) : _log = Log(
            "QuantityPickerInput<${PickerType.runtimeType}, ${InputType.runtimeType}>");

  SetInputController<InputType> get _controller => delegate.controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (_, __, ___) {
        Widget content = Empty();
        if (_controller.value.isNotEmpty) {
          content = Padding(
            padding: const EdgeInsets.only(
              left: paddingDefault,
              right: paddingDefault,
              bottom: paddingDefault,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _controller.value
                  .map((e) => _buildInput(context, e))
                  .toList(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _controller.value.isEmpty ? Empty() : const MinDivider(),
            ListItem(
              title: Text(
                title,
                style: _controller.value.isEmpty
                    ? null
                    : styleListHeading(context),
              ),
              onTap: () => push(context, _buildPickerPage(context)),
              trailing: RightChevronIcon(),
            ),
            content,
          ],
        );
      },
    );
  }

  Widget _buildInput(BuildContext context, InputType item) {
    var numberController = NumberInputController();
    numberController.intValue =
        delegate.inputTypeHasValue(item) ? delegate.inputTypeValue(item) : null;

    var label = _buildInputLabel(context, item);
    if (isEmpty(label)) {
      _log.e("Input label cannot be empty. Item: $item");
      return Empty();
    }

    return Row(
      children: [
        Text(label!, style: stylePrimary(context)),
        const Spacer(),
        SizedBox(
          width: textInputWidth,
          child: TextInput.number(
            context,
            controller: numberController,
            hintText: "0",
            decimal: false,
            signed: false,
            showMaxLength: false,
            onChanged: (newValue) {
              var newInt = int.tryParse(newValue);
              if (newInt == null) {
                delegate.clearValue(item);
              } else {
                delegate.updateValue(item, newInt);
              }
            },
          ),
        ),
      ],
    );
  }

  String? _buildInputLabel(BuildContext context, InputType item) {
    if (!delegate.inputTypeEntityExists(item)) {
      return Strings.of(context).unknown;
    }
    return delegate.inputTypeEntityDisplayName(context, item);
  }

  Widget _buildPickerPage(BuildContext context) {
    return delegate.pickerPage(
      ManageableListPagePickerSettings<PickerType>(
        multiTitle: isEmpty(pickerTitle) ? null : Text(pickerTitle!),
        initialValues: delegate.pickerTypeInitialValues,
        onPicked: (context, entities) {
          var newValue = <InputType>{};

          for (var entity in entities) {
            var catches = delegate.newInputItem(entity);

            // Maintain last known value, if there was one.
            var existingCatches = delegate.existingInputItem(entity);
            if (existingCatches != null &&
                delegate.inputTypeHasValue(existingCatches)) {
              delegate.updateValue(
                  catches, delegate.inputTypeValue(existingCatches)!);
            }

            newValue.add(catches);
          }

          _controller.value = newValue;
          return true;
        },
      ),
    );
  }
}

@immutable
abstract class QuantityPickerInputDelegate<PickerType extends GeneratedMessage,
    InputType> {
  SetInputController<InputType> get controller;

  Widget pickerPage(
      ManageableListPagePickerSettings<PickerType> pickerSettings);

  Set<PickerType> get pickerTypeInitialValues;

  bool inputTypeEntityExists(InputType item);

  bool inputTypeHasValue(InputType item);

  int? inputTypeValue(InputType item);

  String? inputTypeEntityDisplayName(BuildContext context, InputType item);

  InputType newInputItem(PickerType pickerItem);

  InputType? existingInputItem(PickerType pickerItem);

  void updateValue(InputType item, int value);

  void clearValue(InputType item);
}

@immutable
class EntityQuantityPickerInputDelegate<T extends GeneratedMessage>
    extends QuantityPickerInputDelegate<T, Trip_EntityCatches> {
  final EntityManager<T> manager;
  final Widget Function(ManageableListPagePickerSettings<T>) listPageBuilder;

  final SetInputController<Trip_EntityCatches> _controller;

  EntityQuantityPickerInputDelegate({
    required this.manager,
    required SetInputController<Trip_EntityCatches> controller,
    required this.listPageBuilder,
  }) : _controller = controller;

  @override
  SetInputController<Trip_EntityCatches> get controller => _controller;

  @override
  Trip_EntityCatches newInputItem(T pickerItem) =>
      Trip_EntityCatches(entityId: manager.id(pickerItem));

  @override
  Trip_EntityCatches? existingInputItem(T pickerItem) => controller.value
      .firstWhereOrNull((e) => e.entityId == manager.id(pickerItem));

  @override
  String? inputTypeEntityDisplayName(
          BuildContext context, Trip_EntityCatches item) =>
      manager.displayName(context, manager.entity(item.entityId)!);

  @override
  bool inputTypeEntityExists(Trip_EntityCatches item) =>
      manager.entityExists(item.entityId);

  @override
  bool inputTypeHasValue(Trip_EntityCatches item) => item.hasValue();

  @override
  int inputTypeValue(Trip_EntityCatches item) => item.value;

  @override
  Widget pickerPage(ManageableListPagePickerSettings<T> pickerSettings) =>
      listPageBuilder(pickerSettings);

  @override
  Set<T> get pickerTypeInitialValues =>
      manager.list(controller.value.map((e) => e.entityId)).toSet();

  @override
  void updateValue(Trip_EntityCatches item, int value) => item.value = value;

  @override
  void clearValue(Trip_EntityCatches item) => item.clearValue();
}

@immutable
class BaitQuantityPickerInputDelegate
    extends QuantityPickerInputDelegate<BaitAttachment, Trip_BaitCatches> {
  final BaitManager baitManager;

  final SetInputController<Trip_BaitCatches> _controller;

  BaitQuantityPickerInputDelegate({
    required this.baitManager,
    required SetInputController<Trip_BaitCatches> controller,
  }) : _controller = controller;

  @override
  SetInputController<Trip_BaitCatches> get controller => _controller;

  @override
  Trip_BaitCatches newInputItem(BaitAttachment pickerItem) =>
      Trip_BaitCatches(attachment: pickerItem);

  @override
  Trip_BaitCatches? existingInputItem(BaitAttachment pickerItem) =>
      controller.value.firstWhereOrNull((e) => e.attachment == pickerItem);

  @override
  String? inputTypeEntityDisplayName(
    BuildContext context,
    Trip_BaitCatches item,
  ) =>
      baitManager.attachmentDisplayValue(item.attachment, context);

  @override
  bool inputTypeEntityExists(Trip_BaitCatches item) {
    if (item.attachment.hasVariantId()) {
      return baitManager.variantFromAttachment(item.attachment) != null;
    }
    return baitManager.entityExists(item.attachment.baitId);
  }

  @override
  bool inputTypeHasValue(Trip_BaitCatches item) => item.hasValue();

  @override
  int inputTypeValue(Trip_BaitCatches item) => item.value;

  @override
  Widget pickerPage(
    ManageableListPagePickerSettings<BaitAttachment> pickerSettings,
  ) {
    return BaitListPage(
      pickerSettings: BaitListPagePickerSettings(
        initialValues: pickerSettings.initialValues,
        onPicked: pickerSettings.onPicked,
      ),
    );
  }

  @override
  Set<BaitAttachment> get pickerTypeInitialValues =>
      controller.value.map((e) => e.attachment).toSet();

  @override
  void updateValue(Trip_BaitCatches item, int value) => item.value = value;

  @override
  void clearValue(Trip_BaitCatches item) => item.clearValue();
}

class FishingSpotQuantityPickerInputDelegate
    extends EntityQuantityPickerInputDelegate<FishingSpot> {
  FishingSpotQuantityPickerInputDelegate({
    required FishingSpotManager manager,
    required SetInputController<Trip_EntityCatches> controller,
  }) : super(
          manager: manager,
          controller: controller,
          listPageBuilder: (settings) => FishingSpotListPage(
              pickerSettings: FishingSpotListPagePickerSettings(
            initialValues: settings.initialValues,
            onPicked: settings.onPicked,
          )),
        );

  FishingSpotManager get _fishingSpotManager => manager as FishingSpotManager;

  @override
  String inputTypeEntityDisplayName(
    BuildContext context,
    Trip_EntityCatches item,
  ) {
    return _fishingSpotManager.displayName(
      context,
      _fishingSpotManager.entity(item.entityId)!,
      includeBodyOfWater: true,
    );
  }
}