import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import 'date_time_picker.dart';
import 'input_controller.dart';
import 'list_picker_input.dart';
import 'radio_input.dart';
import 'widget.dart';

class TideInput extends StatefulWidget {
  final InputController<Tide> controller;

  const TideInput({
    required this.controller,
  });

  @override
  TideInputState createState() => TideInputState();
}

class TideInputState extends State<TideInput> {
  bool get hasValue => widget.controller.hasValue;

  Tide? get value => widget.controller.value;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Tide?>(
      valueListenable: widget.controller,
      builder: (context, _, __) {
        return ListPickerInput(
          title: Strings.of(context).tideInputTitle,
          value: value?.displayValue(context),
          onTap: () {
            push(
              context,
              _TideInputPage(widget.controller),
            );
          },
        );
      },
    );
  }
}

class _TideInputPage extends StatefulWidget {
  final InputController<Tide> controller;

  const _TideInputPage(this.controller);

  @override
  __TideInputPageState createState() => __TideInputPageState();
}

class __TideInputPageState extends State<_TideInputPage> {
  late DateTimeInputController _lowTideController;
  late DateTimeInputController _highTideController;

  InputController<Tide> get controller => widget.controller;

  bool get hasValue => controller.hasValue;

  Tide? get value => controller.value;

  @override
  void initState() {
    super.initState();

    _lowTideController = DateTimeInputController(context);
    _highTideController = DateTimeInputController(context);

    if (hasValue) {
      _lowTideController.value =
          value!.hasLowTimestamp() ? value!.lowDateTime(context) : null;
      _highTideController.value =
          value!.hasHighTimestamp() ? value!.highDateTime(context) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: Text(Strings.of(context).pickerTitleTide),
      padding: insetsZero,
      showSaveButton: false,
      header: NoneFormHeader(controller: controller),
      fieldBuilder: (context) => [
        _buildType(),
        _buildLowTime(),
        _buildHighTime(),
      ],
    );
  }

  Widget _buildType() {
    var options = TideTypes.selectable().toList();

    int? initialIndex;
    if (hasValue && value!.hasType()) {
      initialIndex = options.indexOf(value!.type);
    }

    return RadioInput(
      padding: const EdgeInsets.only(
        top: paddingSmall,
        bottom: paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      initialSelectedIndex: initialIndex,
      optionCount: options.length,
      optionBuilder: (context, i) => options[i].displayName(context),
      onSelect: (i) => _update(type: options[i]),
    );
  }

  Widget _buildLowTime() {
    return TimePicker(
      context,
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      label: Strings.of(context).tideInputLowTimeLabel,
      controller: _lowTideController,
      onChange: (_) => _update(),
    );
  }

  Widget _buildHighTime() {
    return TimePicker(
      context,
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      label: Strings.of(context).tideInputHighTimeLabel,
      controller: _highTideController,
      onChange: (_) => _update(),
    );
  }

  void _update({TideType? type}) {
    applyUpdates(Tide newTide) {
      if (type != null) {
        newTide.type = type;
      }

      if (_lowTideController.hasValue) {
        newTide.lowTimestamp = Int64(_lowTideController.timestamp!);
      }

      if (_highTideController.hasValue) {
        newTide.highTimestamp = Int64(_highTideController.timestamp!);
      }
    }

    if (hasValue) {
      controller.value = controller.value!.immutableCopyAndUpdate(applyUpdates);
    } else if (type != null ||
        _lowTideController.hasValue ||
        _highTideController.hasValue) {
      controller.value = Tide();
      applyUpdates(controller.value!);
    }
  }
}
