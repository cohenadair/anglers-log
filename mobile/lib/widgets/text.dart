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
      style: Theme.of(context).textTheme.bodyText1.copyWith(
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
  final TextOverflow overflow;
  final bool enabled;

  LabelText(this.text, {
    this.overflow = TextOverflow.fade,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _style(context),
      overflow: overflow,
    );
  }

  TextStyle _style(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.subtitle1;
    if (!enabled) {
      style = style.copyWith(
        color: Theme.of(context).disabledColor,
      );
    }
    return style;
  }
}

class SecondaryLabelText extends StatelessWidget {
  final String text;

  SecondaryLabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return LabelText(text, enabled: false);
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

/// A text [Widget] that formats given arguments as bold. Supported formats:
///   - %s
class InsertedBoldText extends StatelessWidget {
  final String text;
  final List<String> args;

  InsertedBoldText({
    this.text,
    this.args,
  });

  @override
  Widget build(BuildContext context) {
    var components = text.split(RegExp(r'%s'));
    assert (args.length == components.length - 1);

    List<TextSpan> spans = [];
    for (var i = 0; i < components.length; i++) {
      spans.add(TextSpan(
        text: components[i],
      ));
      if (i < args.length) {
        spans.add(TextSpan(
          text: args[i],
          style: TextStyle(
            fontWeight: fontWeightBold,
          ),
        ));
      }
    }

    // TODO: Check that text style and weight is fixed on next beta release.
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}