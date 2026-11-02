import 'package:screenshots_capture/seed.dart';

/// Anglers' Log's UUID for a seed key. Shared by `build_seed.dart` (host)
/// and `capture_app.dart` (device).
String anglersLogSeedUuid(String key) =>
    seedUuid(key, namespace: "anglers-log-seed");
