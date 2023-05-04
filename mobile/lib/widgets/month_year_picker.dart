import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:timezone/timezone.dart';

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

  TimeManager get _timeManager => TimeManager.of(context);

  @override
  void initState() {
    super.initState();
    _year = _timeManager.currentDateTime.year;
    _month = _timeManager.currentDateTime.month;
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
        DialogButton(label: Strings.of(context).cancel),
        DialogButton(
          label: Strings.of(context).ok,
          popOnTap: false,
          onTap: () => Navigator.pop(
              context, _timeManager.toTZDateTime(DateTime(_year, _month))),
        ),
      ],
    );
  }

  Widget _buildYearPicker() {
    return Container(
      color: context.colorDefault,
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
          color: _month == month ? context.colorDefault : Colors.transparent,
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
                DateFormat(DateFormat.ABBR_MONTH)
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
