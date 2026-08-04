import 'package:adair_flutter_lib/l10n/sf_localizations_en_base.dart';

/// Allows overriding of default text values in an [SfCalendar] widget
/// (English).
class SfLocalizationsEnOverride extends SfLocalizationsEnBase {
  SfLocalizationsEnOverride();

  @override
  String get noEventsCalendarLabel => "No catches or trips";
}
