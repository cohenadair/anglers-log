import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/date_time_utils.dart';

/// A default text Widget that should be used in place of [Text].
class Label extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final TextOverflow? overflow;
  final TextStyle? style;

  Label(
    this.text, {
    this.align,
    this.overflow,
    this.style,
  });

  Label.multiline(
    this.text, {
    this.align,
    this.style,
  }) : overflow = TextOverflow.visible;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: style,
    );
  }
}

class HeadingLabel extends StatelessWidget {
  final String text;

  HeadingLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Label(
      text,
      style: Theme.of(context).textTheme.bodyText1!.copyWith(
            color: Theme.of(context).primaryColor,
          ),
    );
  }
}

class NoteLabel extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final TextOverflow? overflow;

  NoteLabel(
    this.text, {
    this.align,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Label(
      text,
      align: align,
      overflow: overflow,
      style: styleNote(context),
    );
  }
}

/// A text widget that inserts an [Icon] into a [String]. The given [String]
/// can only have a single "%s" substitution.
class IconLabel extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextAlign? align;
  final TextOverflow? overflow;
  final Icon icon;

  IconLabel({
    required this.text,
    required this.icon,
    this.align,
    this.overflow,
    this.textStyle,
  })  : assert(isNotEmpty(text)),
        assert(text.split("%s").length == 2);

  @override
  Widget build(BuildContext context) {
    var strings = text.split("%s");
    var style = textStyle ?? styleNote(context);

    return RichText(
      overflow: overflow ?? TextOverflow.clip,
      textAlign: align ?? TextAlign.start,
      text: TextSpan(
        children: [
          TextSpan(
            text: strings.first,
            style: style,
          ),
          WidgetSpan(
            child: icon,
            alignment: PlaceholderAlignment.middle,
          ),
          TextSpan(
            text: strings.last,
            style: style,
          ),
        ],
      ),
    );
  }
}

/// Text that matches the primary label in a [ListTile].
class PrimaryLabel extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final bool enabled;

  PrimaryLabel(
    this.text, {
    this.align,
    this.overflow,
    this.fontWeight,
    this.enabled = true,
  });

  PrimaryLabel.multiline(
    this.text, {
    this.align,
    this.fontWeight,
    this.enabled = true,
  }) : overflow = TextOverflow.visible;

  @override
  Widget build(BuildContext context) {
    return Label(
      text,
      align: align,
      overflow: overflow,
      style: stylePrimary(
        context,
        enabled: enabled,
        fontWeight: fontWeight,
      ),
    );
  }
}

class SecondaryLabel extends StatelessWidget {
  final String text;
  final TextAlign? align;

  SecondaryLabel(
    this.text, {
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryLabel(
      text,
      enabled: false,
      align: align,
    );
  }
}

class TitleLabel extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final TextOverflow? overflow;

  TitleLabel(
    this.text, {
    this.align,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // For large text, there is some additional leading padding for some
      // reason, so large text won't horizontally align with widgets around it.
      // Offset the leading padding to compensate for this.
      padding: const EdgeInsets.only(
        left: paddingDefault - 2.0,
        right: paddingDefault,
      ),
      child: Label(
        text,
        style: styleTitle1,
        align: align,
        overflow: overflow,
      ),
    );
  }
}

class AlertTitleLabel extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final TextOverflow? overflow;

  AlertTitleLabel(
    this.text, {
    this.align,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Label(
      text,
      style: styleTitleAlert,
      align: align,
      overflow: overflow,
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
      style: Theme.of(context).textTheme.subtitle2!.copyWith(
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

  EnabledLabel(
    this.text, {
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
///   Dec 8, 2018
class DateLabel extends StatelessWidget {
  final DateTime date;
  final bool enabled;

  DateLabel(
    this.date, {
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

  TimeLabel(
    this.time, {
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
