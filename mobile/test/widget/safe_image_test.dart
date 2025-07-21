import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/safe_image.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  setUp(() async {
    await StubbedManagers.create();
  });

  testWidgets("Image for file", (tester) async {
    await pumpContext(
      tester,
      (_) => SafeImage.file(
        File("test/resources/anglers_log_logo.png"),
        fallback: const SizedBox(),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SizedBox), findsNothing);
  });

  testWidgets("Image for memory", (tester) async {
    await pumpContext(
      tester,
      (_) => SafeImage.memory(
        File("test/resources/anglers_log_logo.png").readAsBytesSync(),
        fallback: const SizedBox(),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(Container), findsNothing);
    expect(find.byType(SizedBox), findsNothing);
  });

  testWidgets("Image with default fallback", (tester) async {
    await pumpContext(tester, (_) => const SafeImage.memory(null));
    expect(find.byType(SizedBox), findsNothing);
    expect(find.byType(Container), findsOneWidget);
  });

  testWidgets("Image with custom fallback", (tester) async {
    await pumpContext(
      tester,
      (_) => const SafeImage.memory(null, fallback: SizedBox()),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.byType(Container), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
