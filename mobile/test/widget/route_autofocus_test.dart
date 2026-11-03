import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/route_autofocus.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late FocusNode childNode;

  setUp(() async {
    await StubbedManagers.create();
    childNode = FocusNode();
  });

  tearDown(() {
    childNode.dispose();
  });

  Widget routeAutofocus({bool isEnabled = true}) {
    return RouteAutofocus(
      isEnabled: isEnabled,
      child: Focus(focusNode: childNode, child: const SizedBox()),
    );
  }

  Future<NavigatorState> pushRouteAutofocus(
    WidgetTester tester, {
    Widget? page,
  }) async {
    final navigator = Navigator.of(
      await pumpContext(tester, (_) => const SizedBox()),
    );
    navigator.push(MaterialPageRoute(builder: (_) => page ?? routeAutofocus()));
    // Build the route's first frame; the push animation is still running.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return navigator;
  }

  testWidgets("Child isn't focused when disabled", (tester) async {
    await pumpContext(tester, (_) => routeAutofocus(isEnabled: false));
    await tester.pumpAndSettle();
    expect(childNode.hasFocus, isFalse);
  });

  testWidgets("Child is focused immediately when not in a route", (
    tester,
  ) async {
    // pumpContext always provides a route, so pump the widget directly.
    await tester.pumpWidget(routeAutofocus());
    await tester.pump();
    expect(childNode.hasFocus, isTrue);
  });

  testWidgets("Child is focused immediately when route animation completed", (
    tester,
  ) async {
    await pumpContext(tester, (_) => routeAutofocus());
    await tester.pump();
    expect(childNode.hasFocus, isTrue);
  });

  testWidgets("Child is focused after route animation completes", (
    tester,
  ) async {
    await pushRouteAutofocus(tester);
    expect(childNode.hasFocus, isFalse);

    await tester.pumpAndSettle();
    expect(childNode.hasFocus, isTrue);
  });

  testWidgets("Child isn't focused when route is popped while animating", (
    tester,
  ) async {
    final navigator = await pushRouteAutofocus(tester);
    navigator.pop();
    await tester.pumpAndSettle();

    expect(find.byType(RouteAutofocus), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("Child isn't focused when a route is pushed on top", (
    tester,
  ) async {
    final navigator = await pushRouteAutofocus(tester);
    navigator.push(MaterialPageRoute(builder: (_) => const SizedBox()));
    await tester.pumpAndSettle();

    expect(childNode.hasFocus, isFalse);
  });

  testWidgets("Child doesn't take focus from a node focused mid-animation", (
    tester,
  ) async {
    final otherNode = FocusNode();
    addTearDown(otherNode.dispose);

    await pushRouteAutofocus(
      tester,
      page: Column(
        children: [
          Focus(focusNode: otherNode, child: const SizedBox()),
          routeAutofocus(),
        ],
      ),
    );
    otherNode.requestFocus();
    await tester.pumpAndSettle();

    expect(otherNode.hasFocus, isTrue);
    expect(childNode.hasFocus, isFalse);
  });

  testWidgets("Nothing is focused when child has no focusable nodes", (
    tester,
  ) async {
    await pumpContext(tester, (_) => const SizedBox());
    final focusBefore = FocusManager.instance.primaryFocus;

    await pumpContext(tester, (_) => const RouteAutofocus(child: SizedBox()));
    await tester.pumpAndSettle();

    expect(FocusManager.instance.primaryFocus, focusBefore);
    expect(tester.takeException(), isNull);
  });
}
