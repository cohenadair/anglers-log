import 'package:flutter/material.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../pages/manageable_list_page.dart';
import '../time_manager.dart';
import 'widget.dart';

class TimeZoneInput extends StatelessWidget {
  final InputController<String> controller;
  final VoidCallback? onPicked;

  const TimeZoneInput({required this.controller, this.onPicked});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller,
      builder: (context, timeZone, _) => ListPickerInput(
        title: Strings.of(context).timeZoneInputLabel,
        value: isEmpty(timeZone)
            ? null
            : TimeZoneLocation.fromName(timeZone!).displayName,
        onTap: () => push(
          context,
          _TimeZonePickerPage(
            controller: controller,
            onPicked: onPicked,
          ),
        ),
      ),
    );
  }
}

class _TimeZonePickerPage extends StatefulWidget {
  final InputController<String> controller;
  final VoidCallback? onPicked;

  const _TimeZonePickerPage({required this.controller, this.onPicked});

  @override
  State<_TimeZonePickerPage> createState() => _TimeZonePickerPageState();
}

class _TimeZonePickerPageState extends State<_TimeZonePickerPage> {
  final _log = const Log("_TimeZonePickerPage");

  TimeZoneLocation? _initialValue;

  TimeManager get _timeManager => TimeManager.of(context);

  @override
  void initState() {
    super.initState();
    if (widget.controller.hasValue) {
      _initialValue = TimeZoneLocation(getLocation(widget.controller.value!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ManageableListPage<dynamic>(
      itemManager: ManageableListPageItemManager<dynamic>(
        loadItems: (query) => _filteredLocations(query),
      ),
      itemBuilder: _buildItem,
      pickerSettings: ManageableListPagePickerSettings<dynamic>.single(
        title: Text(Strings.of(context).pickerTitleTimeZone),
        initialValue: _initialValue,
        isRequired: true,
        onPicked: (context, loc) {
          if (loc == null || loc is! TimeZoneLocation) {
            widget.controller.value = null;
          } else {
            widget.controller.value = loc.name;
          }
          widget.onPicked?.call();
          return true;
        },
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).timeZoneInputSearchHint,
      ),
    );
  }

  List<dynamic> _filteredLocations(String? query) {
    var result = [];

    // Always include the selected value.
    if (_initialValue != null) {
      result.add(_initialValue);
      result.add(const MinDivider());
    }

    result
        .addAll(_timeManager.filteredLocations(query, exclude: _initialValue));
    return result;
  }

  ManageableListPageItemModel _buildItem(BuildContext context, dynamic item) {
    if (item is MinDivider) {
      return const ManageableListPageItemModel(
        isEditable: false,
        isSelectable: false,
        child: MinDivider(),
      );
    } else if (item is TimeZoneLocation) {
      return ManageableListPageItemModel(child: Text(item.displayNameUtc));
    } else {
      _log.e(StackTrace.current, "Unknown item type: ${item.runtimeType}");
      return const ManageableListPageItemModel(child: Empty());
    }
  }
}
