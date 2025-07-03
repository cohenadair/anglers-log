import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/res/anim.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:timezone/timezone.dart';

import '../utils/date_time_utils.dart';

Future<TZDateTime?> showMonthYearPicker(BuildContext context) {
  return showDialog<TZDateTime>(
    context: context,
    builder: (context) => _MonthYearPicker(),
  );
}

class _MonthYearPicker extends StatefulWidget {
  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  static const _monthHeight = 50.0;
  static const _monthWidth = 65.0;
  static const _monthBorderRadius = 25.0;

  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = TimeManager.get.currentDateTime.year;
    _month = TimeManager.get.currentDateTime.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      titlePadding: insetsZero,
      contentPadding: insetsZero,
      title: _buildYearPicker(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthPicker(),
          const MinDivider(),
        ],
      ),
      actions: [
        DialogButton(label: L10n.get.lib.cancel),
        DialogButton(
          label: L10n.get.lib.ok,
          popOnTap: false,
          onTap: () => Navigator.pop(
              context, TimeManager.get.dateTimeToTz(DateTime(_year, _month))),
        ),
      ],
    );
  }

  Widget _buildYearPicker() {
    return Container(
      color: AppConfig.get.colorAppTheme,
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() => _year--),
              color: context.colorAppBarContent,
            ),
            Expanded(
              child: Padding(
                padding: insetsVerticalDefault,
                child: Text(
                  _year.toString(),
                  textAlign: TextAlign.center,
                  style: styleTitleAlert(context),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() => _year++),
              color: context.colorAppBarContent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthPicker() {
    return Padding(
      padding: insetsVerticalDefault,
      child: Table(
        children: [
          TableRow(
            children: [
              _buildMonth(DateTime.january),
              _buildMonth(DateTime.february),
              _buildMonth(DateTime.march),
            ],
          ),
          TableRow(
            children: [
              _buildMonth(DateTime.april),
              _buildMonth(DateTime.may),
              _buildMonth(DateTime.june),
            ],
          ),
          TableRow(
            children: [
              _buildMonth(DateTime.july),
              _buildMonth(DateTime.august),
              _buildMonth(DateTime.september),
            ],
          ),
          TableRow(
            children: [
              _buildMonth(DateTime.october),
              _buildMonth(DateTime.november),
              _buildMonth(DateTime.december),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonth(int month) {
    VoidCallback? onTap;
    if (_month != month) {
      onTap = () => setState(() => _month = month);
    }
    var borderRadius =
        const BorderRadius.all(Radius.circular(_monthBorderRadius));

    return Align(
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: animDurationDefault,
        height: _monthHeight,
        width: _monthWidth,
        decoration: BoxDecoration(
          color: _month == month
              ? AppConfig.get.colorAppTheme
              : Colors.transparent,
          borderRadius: borderRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: insetsDefault,
              child: Text(
                DateFormats.localized(context, DateFormat.ABBR_MONTH)
                    .format(DateTime(_year, month)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
