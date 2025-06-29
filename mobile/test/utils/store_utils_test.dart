import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/store_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.ioWrapper.isAndroid).thenReturn(false);
    when(managers.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));
  });

  testWidgets("Error shown if can't open URL", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => Scaffold(
          body: Builder(
            builder: (context) => Button(
              text: "Test",
              onPressed: () => launchStore(context),
            ),
          ),
        ),
        managers: managers,
      ),
    );

    when(managers.urlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(false));
    when(managers.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(false));

    await tapAndSettle(tester, find.byType(Button));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
        find.text("Device does not have App Store installed."), findsOneWidget);
  });

  testWidgets("Successful launch", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => Scaffold(
          body: Builder(
            builder: (context) => Button(
              text: "Test",
              onPressed: () => launchStore(context),
            ),
          ),
        ),
        managers: managers,
      ),
    );

    when(managers.urlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(true));
    when(managers.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await tapAndSettle(tester, find.byType(Button));
    expect(find.byType(SnackBar), findsNothing);
    verify(managers.urlLauncherWrapper.launch(any)).called(1);
  });

  testWidgets("Android launch error", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(true);

    await tester.pumpWidget(
      Testable(
        (_) => Scaffold(
          body: Builder(
            builder: (context) => Button(
              text: "Test",
              onPressed: () => launchStore(context),
            ),
          ),
        ),
        managers: managers,
      ),
    );

    when(managers.urlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(false));

    await tapAndSettle(tester, find.byType(Button));

    var result = verify(managers.urlLauncherWrapper.canLaunch(captureAny));
    result.called(1);

    expect(result.captured.first.contains("play.google.com"), isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
        find.text("Device has no web browser app installed."), findsOneWidget);
  });
}
