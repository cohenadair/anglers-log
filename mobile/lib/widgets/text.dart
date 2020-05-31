import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/string_utils.dart';

/// A default text Widget that should be used in place of [Text].
class Label extends StatelessWidget {
  final String text;
  final TextStyle style;

  Label(this.text, {
    this.style,
  });

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: style,
    overflow: TextOverflow.ellipsis,
  );
}

class HeadingLabel extends StatelessWidget {
  final String text;

  HeadingLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Label(
      text,
      style: Theme.of(context).textTheme.bodyText1.copyWith(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

/// Text that matches the primary label in a [ListTile].
class PrimaryLabel extends StatelessWidget {
  final String text;
  final bool enabled;

  PrimaryLabel(this.text, {
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Label(text, style: _style(context));
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

class SecondaryLabel extends StatelessWidget {
  final String text;

  SecondaryLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return PrimaryLabel(text, enabled: false);
  }
}

class TitleLabel extends StatelessWidget {
  final String text;

  TitleLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // For large text, there is some additional leading padding for some
      // reason, so large text won't horizontally align with widgets around it.
      // Offset the leading padding to compensate for this.
      padding: const EdgeInsets.only(
        left: paddingDefault - 2.0,
      ),
      child: Label(text, style: styleTitle),
    );
  }
}

class SubtitleLabel extends StatelessWidget {
  final String text;

  SubtitleLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Label(
      text,
      style: Theme.of(context).textTheme.subtitle2.copyWith(
        color: Colors.grey,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}

/// A [Text] widget with an enabled state. If `enabled = false`, the [Text] is
/// rendered with a `Theme.of(context).disabledColor` color.
class EnabledLabel extends StatelessWidget {
  final String text;
  final bool enabled;

  EnabledLabel(this.text, {
    this.enabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Label(
      text,
      style: TextStyle(
        color: enabled ? null : Theme.of(context).disabledColor,
      ),
    );
  }
}

class DisabledLabel extends StatelessWidget {
  final String text;

  DisabledLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return EnabledLabel(text, enabled: false);
  }
}

/// A formatted Text widget for a date.
///
/// Example:
///   Dec. 8, 2018
class DateLabel extends StatelessWidget {
  final DateTime date;
  final bool enabled;

  DateLabel(this.date, {
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return EnabledLabel(
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
class TimeLabel extends StatelessWidget {
  final TimeOfDay time;
  final bool enabled;

  TimeLabel(this.time, {
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return EnabledLabel(
      _format(context),
      enabled: enabled,
    );
  }

  String _format(BuildContext context) {
    return formatTimeOfDay(context, time);
  }
}