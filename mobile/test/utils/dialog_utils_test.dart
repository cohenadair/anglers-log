import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
    when(appManager.ioWrapper.isAndroid).thenReturn(false);
  });

  group("Rate dialog", () {
    testWidgets("First run sets timer", (tester) async {
      await tester.pumpWidget(
        Testable(
          (context) => Button(
            text: "Test",
            onPressed: () => showRateDialogIfNeeded(context),
          ),
          appManager: appManager,
        ),
      );

      when(appManager.userPreferenceManager.didRateApp).thenReturn(false);
      when(appManager.userPreferenceManager.rateTimerStartedAt)
          .thenReturn(null);
      when(appManager.userPreferenceManager.setRateTimerStartedAt(any))
          .thenAnswer((_) => Future.value());
      when(appManager.timeManager.currentTimestamp).thenReturn(10);

      await tapAndSettle(tester, find.byType(Button));

      verify(appManager.userPreferenceManager.setRateTimerStartedAt(10));
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets("Not enough time as passed; dialog not shown", (tester) async {
      await tester.pumpWidget(
        Testable(
          (context) => Button(
            text: "Test",
            onPressed: () => showRateDialogIfNeeded(context),
          ),
          appManager: appManager,
        ),
      );

      when(appManager.userPreferenceManager.didRateApp).thenReturn(false);
      when(appManager.userPreferenceManager.rateTimerStartedAt).thenReturn(10);
      when(appManager.timeManager.currentTimestamp)
          .thenReturn((Duration.millisecondsPerDay * (365 / 12) + 10).toInt());

      await tapAndSettle(tester, find.byType(Button));
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets("Enough time as passed; dialog is shown", (tester) async {
      await tester.pumpWidget(
        Testable(
          (context) => Button(
            text: "Test",
            onPressed: () => showRateDialogIfNeeded(context),
          ),
          appManager: appManager,
        ),
      );

      when(appManager.userPreferenceManager.didRateApp).thenReturn(false);
      when(appManager.userPreferenceManager.rateTimerStartedAt).thenReturn(10);
      when(appManager.timeManager.currentTimestamp)
          .thenReturn((Duration.millisecondsPerDay * (365 / 12) + 20).toInt());

      await tapAndSettle(tester, find.byType(Button));
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets("Rate pressed sets didRateApp to true; dialog not shown again",
        (tester) async {
      await tester.pumpWidget(
        Testable(
          (context) => Button(
            text: "Test",
            onPressed: () => showRateDialogIfNeeded(context),
          ),
          appManager: appManager,
        ),
      );

      when(appManager.userPreferenceManager.didRateApp).thenReturn(false);
      when(appManager.userPreferenceManager.rateTimerStartedAt).thenReturn(10);
      when(appManager.timeManager.currentTimestamp)
          .thenReturn((Duration.millisecondsPerDay * (365 / 4) + 20).toInt());

      await tapAndSettle(tester, find.byType(Button));

      expect(find.byType(AlertDialog), findsOneWidget);

      when(appManager.urlLauncherWrapper.canLaunch(any))
          .thenAnswer((_) => Future.value(true));
      when(appManager.urlLauncherWrapper.launch(any))
          .thenAnswer((_) => Future.value(true));
      await tapAndSettle(tester, find.text("RATE"));

      verify(appManager.userPreferenceManager.setDidRateApp(true));

      when(appManager.userPreferenceManager.didRateApp).thenReturn(true);
      await tapAndSettle(tester, find.byType(Button));

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets("Later pressed; timer is reset", (tester) async {
      await tester.pumpWidget(
        Testable(
          (context) => Button(
            text: "Test",
            onPressed: () => showRateDialogIfNeeded(context),
          ),
          appManager: appManager,
        ),
      );

      var now = (Duration.millisecondsPerDay * (365 / 4) + 20).toInt();
      when(appManager.userPreferenceManager.didRateApp).thenReturn(false);
      when(appManager.userPreferenceManager.rateTimerStartedAt).thenReturn(10);
      when(appManager.userPreferenceManager.setRateTimerStartedAt(any))
          .thenAnswer((_) => Future.value());
      when(appManager.timeManager.currentTimestamp).thenReturn(now);

      await tapAndSettle(tester, find.byType(Button));

      expect(find.byType(AlertDialog), findsOneWidget);

      await tapAndSettle(tester, find.text("LATER"));

      verify(appManager.userPreferenceManager.setRateTimerStartedAt(now));
    });
  });

  testWidgets("DialogButton popsOnTap=true", (tester) async {
    await pumpContext(
      tester,
      (_) => const DialogButton(
        label: "Test",
        isEnabled: true,
        popOnTap: true,
      ),
    );

    await tapAndSettle(tester, find.text("TEST"));
    expect(find.byType(DialogButton), findsNothing);
  });

  testWidgets("DialogButton popsOnTap=false", (tester) async {
    await pumpContext(
      tester,
      (_) => const DialogButton(
        label: "Test",
        isEnabled: true,
        popOnTap: false,
      ),
    );

    await tapAndSettle(tester, find.text("TEST"));
    expect(find.byType(DialogButton), findsOneWidget);
  });

  testWidgets("DialogButton disabled", (tester) async {
    await pumpContext(
      tester,
      (_) => const DialogButton(
        label: "Test",
        isEnabled: false,
      ),
    );

    var button = findFirstWithText<TextButton>(tester, "TEST");
    expect(button.onPressed, isNull);
  });

  testWidgets("Discard dialog pops by default", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) => Button(
          text: "Test",
          onPressed: () => showDiscardChangesDialog(context),
        ),
        appManager: appManager,
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
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.byType(Button));
    await tapAndSettle(tester, find.text("DISCARD"));
    expect(find.byType(Button), findsOneWidget);
    expect(invoked, isTrue);
  });
}
