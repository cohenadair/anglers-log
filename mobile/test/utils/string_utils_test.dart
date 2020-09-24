import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/string_utils.dart';

import '../test_utils.dart';

void main() {
  test("Format function", () {
    var formatString = format("You caught %s fish in %s days.", [5, 3]);
    expect(formatString, "You caught 5 fish in 3 days.");

    formatString = format("You've added angler %s to your log.",
        ["Cohen Adair"]);
    expect(formatString, "You've added angler Cohen Adair to your log.");
  });

  testWidgets("Format coordinates", (WidgetTester tester) async {
    BuildContext context = await buildContext(tester);
    expect(formatLatLng(context: context, lat: 0.003, lng: 0.004),
        "Lat: 0.003000, Lng: 0.004000");
    expect(formatLatLng(context: context, lat: 0.123456789, lng: 0.123456789),
        "Lat: 0.123457, Lng: 0.123457");
  });

  test("Parse boolean", () {
    expect(parseBool("123123"), false);
    expect(parseBool("0"), false);
    expect(parseBool("1"), true);
  });
}