import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/bool_utils.dart';

import '../test_utils.dart';

void main() {
  testWidgets("displayValue", (tester) async {
    var context = await buildContext(tester);
    expect(true.displayValue(context), "Yes");
    expect(false.displayValue(context), "No");
  });
}
