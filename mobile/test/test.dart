import 'package:flutter/foundation.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void main() {
  test("Date time isolate", () async {
    initializeTimeZones();
    expect(await compute(func, null), isTrue);
  });
}

bool func(int? input) {
  initializeTimeZones();
  var dt = TZDateTime.fromMillisecondsSinceEpoch(
      getLocation("America/New_York"), 1000);
  return true;
}