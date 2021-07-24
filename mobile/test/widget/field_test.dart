import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/field.dart';
import 'package:mobile/widgets/input_controller.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Required field without description", (tester) async {
    var context = await buildContext(tester);
    var field = Field(
      id: randomId(),
      controller: InputController(),
      isRemovable: false,
    );
    expect(field.description, isNotNull);
    expect(field.description!(context), "Required");
  });

  testWidgets("Required field with description", (tester) async {
    var context = await buildContext(tester);
    var field = Field(
      id: randomId(),
      controller: InputController(),
      description: (_) => "Test",
      isRemovable: false,
    );
    expect(field.description, isNotNull);
    expect(field.description!(context), "Test");
  });
}
