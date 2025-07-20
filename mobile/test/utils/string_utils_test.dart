import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/string_utils.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("Format coordinates", (tester) async {
    var context = await buildContext(tester);
    expect(
      formatLatLng(context: context, lat: 0.003, lng: 0.004),
      "Lat: 0.003000, Lng: 0.004000",
    );
    expect(
      formatLatLng(context: context, lat: 0.123456789, lng: 0.123456789),
      "Lat: 0.123457, Lng: 0.123457",
    );
  });
}
