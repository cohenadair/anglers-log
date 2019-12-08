import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/string_utils.dart';

const monthDayFormat = "MMM. d";
const monthDayYearFormat = "MMM. d, yyyy";

class HeadingText extends StatelessWidget {
  final String _text;

  HeadingText(this._text);

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: Theme.of(context).textTheme.body2.copyWith(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class ErrorText extends StatelessWidget {
  final String text;

  ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: styleError,
    );
  }
}

/// Text that matches the primary label in a [ListTile].
class LabelText extends StatelessWidget {
  final String text;

  LabelText(this.text);

  static TextStyle style(BuildContext context) =>
      Theme.of(context).textTheme.subhead;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style(context),
    );
  }
}

class BoldLabelText extends StatelessWidget {
  final String text;

  BoldLabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: LabelText.style(context).copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// A [Text] widget with an enabled state. If `enabled = false`, the [Text] is
/// rendered with a `Theme.of(context).disabledColor` color.
class EnabledText extends StatelessWidget {
  final String text;
  final bool enabled;

  EnabledText(this.text, {this.enabled = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: enabled ? null : Theme.of(context).disabledColor,
      ),
    );
  }
}

/// A formatted Text widget for a date.
///
/// Example:
///   Dec. 8, 2018
class DateText extends StatelessWidget {
  final DateTime date;
  final bool enabled;

  DateText(this.date, {
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return EnabledText(
      DateFormat(monthDayYearFormat).format(date),
      enabled: enabled,
    );
  }
}

/// A formatted Text widget for a time of day. The display format depends on a
/// combination of the current locale and the user's system time format setting.
///
/// Example:
///   21:35, or
///   9:35 PM
class TimeText extends StatelessWidget {
  final TimeOfDay time;
  final bool enabled;

  TimeText(this.time, {
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return EnabledText(
      _format(context),
      enabled: enabled,
    );
  }

  String _format(BuildContext context) {
    return formatTimeOfDay(context, time);
  }
}

class DisabledText extends StatelessWidget {
  final String text;

  DisabledText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Theme.of(context).disabledColor),
    );
  }
}