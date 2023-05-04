import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/date_time_utils.dart';
import 'widget.dart';

class SingleLineText extends StatelessWidget {
  final String? text;
  final TextStyle? style;

  const SingleLineText(
    this.text, {
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty(text)) {
      return const Empty();
    }

    return Text(
      text!,
      style: style,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}

/// A text widget that inserts an [Widget] into a [String]. The given [String]
/// can only have a single "%s" substitution.
class IconLabel extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextAlign? align;
  final TextOverflow? overflow;
  final Widget textArg;

  IconLabel({
    required this.text,
    required this.textArg,
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
            child: textArg,
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

class TitleLabel extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final TextOverflow? overflow;
  final int? maxLines;

  final TextStyle _style;
  final double _offset;

  const TitleLabel.style1(
    this.text, {
    this.align,
    this.overflow,
    this.maxLines,
  })  : _style = styleTitle1,
        _offset = 2.0;

  TitleLabel.style2(
    BuildContext context,
    this.text, {
    this.align,
    this.overflow,
    this.maxLines,
  })  : _style = styleTitle2(context),
        _offset = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // For large text, there is some additional leading padding for some
      // reason, so large text won't horizontally align with widgets around it.
      // Offset the leading padding to compensate for this.
      padding: EdgeInsets.only(
        left: paddingDefault - _offset,
        right: paddingDefault,
      ),
      child: Text(
        text,
        style: _style,
        textAlign: align,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}

class AlertTitleLabel extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final TextOverflow? overflow;

  const AlertTitleLabel(
    this.text, {
    this.align,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: styleTitleAlert(context),
      textAlign: align,
      overflow: overflow,
    );
  }
}

/// A [Text] widget with an enabled state. If `enabled = false`, the [Text] is
/// rendered with a `Theme.of(context).disabledColor` color.
class EnabledLabel extends StatelessWidget {
  final String text;
  final bool enabled;

  const EnabledLabel(
    this.text, {
    this.enabled = false,
  });

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

class DisabledLabel extends StatelessWidget {
  final String text;

  const DisabledLabel(this.text);

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

  const DateLabel(
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

  const TimeLabel(
    this.time, {
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return EnabledLabel(
      formatTimeOfDay(context, time),
      enabled: enabled,
    );
  }
}
