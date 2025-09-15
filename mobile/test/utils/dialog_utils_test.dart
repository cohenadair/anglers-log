import 'package:adair_flutter_lib/widgets/button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Discard dialog pops by default", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) => Button(
          text: "Test",
          onPressed: () => showDiscardChangesDialog(context),
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(Button));
    await tapAndSettle(tester, find.text("DISCARD"));
    expect(find.byType(Button), findsNothing);
  });

  testWidgets("Discard dialog calls onDiscard", (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      Testable(
        (context) => Button(
          text: "Test",
          onPressed: () =>
              showDiscardChangesDialog(context, () => invoked = true),
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(Button));
    await tapAndSettle(tester, find.text("DISCARD"));
    expect(find.byType(Button), findsOneWidget);
    expect(invoked, isTrue);
  });
}
