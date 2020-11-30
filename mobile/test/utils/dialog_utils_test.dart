import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockPreferencesManager: true,
      mockTimeManager: true,
      mockUrlLauncherWrapper: true,
    );
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

      when(appManager.mockPreferencesManager.didRateApp).thenReturn(false);
      when(appManager.mockPreferencesManager.rateTimerStartedAt)
          .thenReturn(null);
      when(appManager.mockTimeManager.msSinceEpoch).thenReturn(10);

      await tapAndSettle(tester, find.byType(Button));

      verify(appManager.mockPreferencesManager.rateTimerStartedAt = 10);
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

      when(appManager.mockPreferencesManager.didRateApp).thenReturn(false);
      when(appManager.mockPreferencesManager.rateTimerStartedAt).thenReturn(10);
      when(appManager.mockTimeManager.msSinceEpoch)
          .thenReturn((Duration.millisecondsPerDay * (365 / 4) + 10).toInt());

      await tapAndSettle(tester, find.byType(Button));

      verify(appManager.mockPreferencesManager.rateTimerStartedAt).called(2);
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

      when(appManager.mockPreferencesManager.didRateApp).thenReturn(false);
      when(appManager.mockPreferencesManager.rateTimerStartedAt).thenReturn(10);
      when(appManager.mockTimeManager.msSinceEpoch)
          .thenReturn((Duration.millisecondsPerDay * (365 / 4) + 20).toInt());

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

      when(appManager.mockPreferencesManager.didRateApp).thenReturn(false);
      when(appManager.mockPreferencesManager.rateTimerStartedAt).thenReturn(10);
      when(appManager.mockTimeManager.msSinceEpoch)
          .thenReturn((Duration.millisecondsPerDay * (365 / 4) + 20).toInt());

      await tapAndSettle(tester, find.byType(Button));

      verify(appManager.mockPreferencesManager.rateTimerStartedAt).called(2);
      expect(find.byType(AlertDialog), findsOneWidget);

      when(appManager.mockUrlLauncherWrapper.canLaunch(any))
          .thenAnswer((_) => Future.value(true));
      await tapAndSettle(tester, find.text("RATE"));

      verify(appManager.mockPreferencesManager.didRateApp = true);

      when(appManager.mockPreferencesManager.didRateApp).thenReturn(true);
      await tapAndSettle(tester, find.byType(Button));

      verifyNever(appManager.mockPreferencesManager.rateTimerStartedAt);
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
      when(appManager.mockPreferencesManager.didRateApp).thenReturn(false);
      when(appManager.mockPreferencesManager.rateTimerStartedAt).thenReturn(10);
      when(appManager.mockTimeManager.msSinceEpoch).thenReturn(now);

      await tapAndSettle(tester, find.byType(Button));

      verify(appManager.mockPreferencesManager.rateTimerStartedAt).called(2);
      expect(find.byType(AlertDialog), findsOneWidget);

      await tapAndSettle(tester, find.text("LATER"));

      verify(appManager.mockPreferencesManager.rateTimerStartedAt = now);
    });
  });
}
