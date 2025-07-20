import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/bool_utils.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("displayValue", (tester) async {
    var context = await buildContext(tester);
    expect(true.displayValue(context), "Yes");
    expect(false.displayValue(context), "No");
  });
}
