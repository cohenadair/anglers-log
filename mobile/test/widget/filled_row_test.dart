import 'package:adair_flutter_lib/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/filled_row.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("Filled container has correct width", (tester) async {
    await pumpContext(
      tester,
      (_) => const FilledRow(
        height: 60,
        maxValue: 100,
        value: 50,
        label: "Test Label",
        padding: EdgeInsets.only(left: 10, right: 10),
      ),
      mediaQueryData: const MediaQueryData(size: Size(400, 600)),
    );

    var container = findFirst<AnimatedContainer>(tester);
    expect(container.constraints?.maxWidth, 190);
    expect((container.child as Container).color, AppConfig.get.colorAppTheme);
  });

  testWidgets("Filled container has 0 width when value is hidden", (
    tester,
  ) async {
    await pumpContext(
      tester,
      (_) => const FilledRow(
        height: 60,
        maxValue: 100,
        value: 50,
        label: "Test Label",
        showValue: false,
        fillColor: Colors.red,
        padding: EdgeInsets.only(left: 10, right: 10),
      ),
      mediaQueryData: const MediaQueryData(size: Size(400, 600)),
    );

    var container = findFirst<AnimatedContainer>(tester);
    expect(container.constraints?.maxWidth, 0);
    expect((container.child as Container).color, Colors.red);
  });

  testWidgets("Value text is hidden", (tester) async {
    await pumpContext(
      tester,
      (_) => const FilledRow(
        height: 60,
        maxValue: 100,
        value: 50,
        label: "Test Label",
        showValue: false,
      ),
    );
    expect(find.text("Test Label"), findsOneWidget);
  });

  testWidgets("Value text is shown", (tester) async {
    await pumpContext(
      tester,
      (_) => const FilledRow(
        height: 60,
        maxValue: 100,
        value: 50,
        label: "Test Label",
        showValue: true,
      ),
    );
    expect(find.text("Test Label (50)"), findsOneWidget);
  });
}
