import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/search_timer.dart';

void main() {
  test("Callback is called immediately with an empty query", () {
    var called = false;
    var timer = SearchTimer(() {
      called = true;
    });

    timer.reset("");
    expect(called, true);

    called = false;
    timer.reset(null);
    expect(called, true);
  });

  test("Callback is eventually called with a non-empty query", () {
    var timer = SearchTimer(expectAsync0(() {}));
    timer.reset("Test");
  });

  test("Callback is not called if timer is cancelled", () async {
    var called = false;
    var timer = SearchTimer(() {
      called = true;
    });

    timer.reset("test");
    timer.finish();

    // Use a Future to simulate a timeout.
    await Future.delayed(const Duration(milliseconds: 500), () {});
    expect(called, false);
  });
}
