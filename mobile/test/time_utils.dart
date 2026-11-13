import 'package:timezone/timezone.dart';

// Kept separate from test_utils.dart so test/mocks/mocks.dart can import it.
// test_utils.dart imports adair-flutter-lib test files by relative path,
// which mockito's builder can't resolve when generating mocks.

// TODO: Can replace with TimeManager.get.currentTimezone
const defaultTimeZone = "America/New_York";

TZDateTime now() {
  return TZDateTime.now(getLocation(defaultTimeZone));
}
