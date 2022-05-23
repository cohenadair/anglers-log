import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/floating_container.dart';

import '../test_utils.dart';

void main() {
  testWidgets("onTap includes InkWell", (tester) async {
    await pumpContext(
      tester,
      (_) => FloatingContainer(
        child: const SizedBox(width: 100, height: 100),
        onTap: () {},
      ),
    );
    expect(find.byType(InkWell), findsOneWidget);
  });

  testWidgets("Null onTap doesn't includes InkWell", (tester) async {
    await pumpContext(
      tester,
      (_) => const FloatingContainer(
        onTap: null,
        child: SizedBox(width: 100, height: 100),
      ),
    );
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets("Circle", (tester) async {
    await pumpContext(
      tester,
      (_) => const FloatingContainer(
        isCircle: true,
        child: SizedBox(width: 100, height: 100),
      ),
    );
    expect(
      (findFirst<Container>(tester).decoration as BoxDecoration).shape,
      BoxShape.circle,
    );
  });

  testWidgets("Rectangle", (tester) async {
    await pumpContext(
      tester,
      (_) => const FloatingContainer(
        isCircle: false,
        child: SizedBox(width: 100, height: 100),
      ),
    );
    expect(
      (findFirst<Container>(tester).decoration as BoxDecoration).shape,
      BoxShape.rectangle,
    );
  });

  testWidgets("Transparent", (tester) async {
    await pumpContext(
      tester,
      (_) => const FloatingContainer(
        isTransparent: true,
        child: SizedBox(width: 100, height: 100),
      ),
    );
    expect(findFirst<Container>(tester).decoration, isNull);
    expect(findFirst<Container>(tester).clipBehavior, Clip.none);
  });

  testWidgets("Opaque", (tester) async {
    await pumpContext(
      tester,
      (_) => const FloatingContainer(
        isTransparent: false,
        child: SizedBox(width: 100, height: 100),
      ),
    );
    expect(findFirst<Container>(tester).decoration, isNotNull);
    expect(findFirst<Container>(tester).clipBehavior, Clip.antiAlias);
  });
}
