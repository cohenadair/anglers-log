import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/tide_chart.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../res/dimen.dart';
import '../tide_fetcher.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import 'date_time_picker.dart';
import 'fetch_input_header.dart';
import 'input_controller.dart';
import 'list_item.dart';
import 'list_picker_input.dart';
import 'radio_input.dart';

class TideInput extends StatefulWidget {
  final FishingSpot? fishingSpot;
  final TZDateTime dateTime;
  final InputController<Tide> controller;

  const TideInput({
    this.fishingSpot,
    required this.dateTime,
    required this.controller,
  });

  @override
  TideInputState createState() => TideInputState();
}

class TideInputState extends State<TideInput> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Tide?>(
      valueListenable: widget.controller,
      builder: (context, tide, __) {
        Widget subtitle = const Empty();
        Widget subtitle2 = const Empty();
        if (tide != null) {
          var current = tide.currentDisplayValue(context);
          if (isNotEmpty(current)) {
            subtitle = Text(current);
          }

          var extremes = tide.extremesDisplayValue(context);
          if (isNotEmpty(extremes)) {
            subtitle2 = Text(extremes);
          }
        }

        showTideInput() {
          push(
            context,
            _TideInputPage(
              fishingSpot: widget.fishingSpot,
              dateTime: widget.dateTime,
              controller: widget.controller,
            ),
          );
        }

        // Use a standard input widget if there's no additional (i.e. extremes)
        // data to show.
        if (subtitle2 is Empty) {
          return ListPickerInput(
            title: Strings.of(context).tideInputTitle,
            value: tide?.currentDisplayValue(context),
            placeholderText: "",
            onTap: showTideInput,
          );
        } else {
          return ListItem(
            title: Text(Strings.of(context).tideInputTitle),
            subtitle: subtitle,
            subtitle2: subtitle2,
            trailing: RightChevronIcon(),
            onTap: showTideInput,
          );
        }
      },
    );
  }
}

class _TideInputPage extends StatefulWidget {
  final FishingSpot? fishingSpot;
  final TZDateTime dateTime;
  final InputController<Tide> controller;

  const _TideInputPage({
    this.fishingSpot,
    required this.dateTime,
    required this.controller,
  });

  @override
  __TideInputPageState createState() => __TideInputPageState();
}

class __TideInputPageState extends State<_TideInputPage> {
  late DateTimeInputController _firstLowTideController;
  late DateTimeInputController _firstHighTideController;
  late DateTimeInputController _secondLowTideController;
  late DateTimeInputController _secondHighTideController;

  InputController<Tide> get _controller => widget.controller;

  bool get _hasValue => _controller.hasValue;

  Tide? get _value => _controller.value;

  @override
  void initState() {
    super.initState();

    _firstLowTideController = DateTimeInputController(context);
    _firstHighTideController = DateTimeInputController(context);
    _secondLowTideController = DateTimeInputController(context);
    _secondHighTideController = DateTimeInputController(context);

    if (_hasValue) {
      _firstLowTideController.value = _value!.hasFirstLowHeight()
          ? _value!.firstLowDateTime(context)
          : null;
      _firstHighTideController.value = _value!.hasFirstHighHeight()
          ? _value!.firstHighDateTime(context)
          : null;
      _secondLowTideController.value = _value!.hasSecondLowHeight()
          ? _value!.secondLowDateTime(context)
          : null;
      _secondHighTideController.value = _value!.hasSecondHighHeight()
          ? _value!.secondHighDateTime(context)
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: Text(Strings.of(context).tideInputTitle),
      padding: insetsZero,
      showSaveButton: false,
      header: _buildHeader(),
      overflowOptions: [
        FormPageOverflowOption.manageUnits(context),
        FormPageOverflowOption.autoFetch(context),
      ],
      fieldBuilder: (context) => [
        _buildChart(),
        _buildType(),
        _buildFirstTimes(),
        _buildSecondTimes(),
      ],
    );
  }

  Widget _buildHeader() {
    return FetchInputHeader<Tide>(
      fishingSpot: widget.fishingSpot,
      defaultErrorMessage: Strings.of(context).inputGenericFetchError,
      dateTime: widget.dateTime,
      onFetch: _fetch,
      onFetchSuccess: (tide) => setState(() => _updateFromTide(tide)),
      controller: widget.controller,
    );
  }

  Widget _buildChart() {
    return AnimatedSize(
      duration: animDurationDefault,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: _hasValue
            ? Padding(
                padding: insetsHorizontalDefaultTopSmall,
                child: TideChart(_controller.value!),
              )
            : const Empty(),
      ),
    );
  }

  Widget _buildType() {
    var options = TideTypes.selectable().toList();

    int? initialIndex;
    if (_hasValue && _value!.hasType()) {
      initialIndex = options.indexOf(_value!.type);
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

  Widget _buildFirstTimes() {
    return Flex(
      direction: Axis.horizontal,
      children: [
        const HorizontalSpace(paddingDefault),
        _buildTimePicker(
          Strings.of(context).tideInputFirstLowTimeLabel,
          _firstLowTideController,
        ),
        const HorizontalSpace(paddingDefault),
        _buildTimePicker(
          Strings.of(context).tideInputFirstHighTimeLabel,
          _firstHighTideController,
        ),
        const HorizontalSpace(paddingDefault),
      ],
    );
  }

  Widget _buildSecondTimes() {
    return Flex(
      direction: Axis.horizontal,
      children: [
        const HorizontalSpace(paddingDefault),
        _buildTimePicker(
          Strings.of(context).tideInputSecondLowTimeLabel,
          _secondLowTideController,
        ),
        const HorizontalSpace(paddingDefault),
        _buildTimePicker(
          Strings.of(context).tideInputSecondHighTimeLabel,
          _secondHighTideController,
        ),
        const HorizontalSpace(paddingDefault),
      ],
    );
  }

  Widget _buildTimePicker(String label, DateTimeInputController controller) {
    return Flexible(
      flex: 1,
      child: TimePicker(
        context,
        padding: insetsBottomDefault,
        label: label,
        controller: controller,
        onChange: (_) => _update(),
      ),
    );
  }

  void _update({TideType? type}) {
    var newTide = _controller.value?.deepCopy() ?? Tide();

    if (type != null) {
      newTide.type = type;
    }

    if (_firstLowTideController.hasValue) {
      newTide.firstLowHeight = Tide_Height(
        timestamp: Int64(_firstLowTideController.timestamp!),
      );
    }

    if (_firstHighTideController.hasValue) {
      newTide.firstHighHeight = Tide_Height(
        timestamp: Int64(_firstHighTideController.timestamp!),
      );
    }

    if (_secondLowTideController.hasValue) {
      newTide.secondLowHeight = Tide_Height(
        timestamp: Int64(_secondLowTideController.timestamp!),
      );
    }

    if (_secondHighTideController.hasValue) {
      newTide.secondHighHeight = Tide_Height(
        timestamp: Int64(_secondHighTideController.timestamp!),
      );
    }

    _controller.value = newTide;
  }

  Future<FetchInputResult<Tide?>> _fetch() async {
    return await TideFetcher(
      widget.dateTime,
      widget.fishingSpot?.latLng,
    ).fetch(context);
  }

  void _updateFromTide(Tide tide) {
    _controller.value = tide;

    if (tide.hasFirstHighHeight()) {
      _firstLowTideController.value = tide.firstLowDateTime(context);
    }

    if (tide.hasFirstHighHeight()) {
      _firstHighTideController.value = tide.firstHighDateTime(context);
    }

    if (tide.hasSecondLowHeight()) {
      _secondLowTideController.value = tide.secondLowDateTime(context);
    }

    if (tide.hasSecondHighHeight()) {
      _secondHighTideController.value = tide.secondHighDateTime(context);
    }
  }
}
