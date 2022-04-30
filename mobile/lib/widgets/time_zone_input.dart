import 'package:flutter/material.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:timezone/timezone.dart';

import '../i18n/strings.dart';
import '../pages/manageable_list_page.dart';
import '../time_manager.dart';
import 'widget.dart';

class TimeZoneInput extends StatelessWidget {
  final TimeZoneInputController controller;
  final VoidCallback? onPicked;

  const TimeZoneInput({required this.controller, this.onPicked});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller,
      builder: (context, timeZone, _) => ListPickerInput(
        title: Strings.of(context).timeZoneInputLabel,
        value: TimeZoneLocation.fromName(timeZone!).displayName,
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
  final TimeZoneInputController controller;
  final VoidCallback? onPicked;

  const _TimeZonePickerPage({required this.controller, this.onPicked});

  @override
  State<_TimeZonePickerPage> createState() => _TimeZonePickerPageState();
}

class _TimeZonePickerPageState extends State<_TimeZonePickerPage> {
  late TimeZoneLocation _initialValue;

  TimeManager get _timeManager => TimeManager.of(context);

  @override
  void initState() {
    super.initState();
    _initialValue = TimeZoneLocation(getLocation(widget.controller.value));
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
          // Only TimeZoneLocation objects should be selectable.
          assert(loc is TimeZoneLocation);
          widget.controller.value = loc.name;
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

    // Always put the selected value at the top, since the list of time zones
    // is so long.
    result.add(_initialValue);
    result.add(const MinDivider());
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
    } else {
      assert(item is TimeZoneLocation);
      return ManageableListPageItemModel(child: Text(item.displayNameUtc));
    }
  }
}
