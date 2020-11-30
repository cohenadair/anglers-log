import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/store_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockUrlLauncherWrapper: true,
    );
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
        appManager: appManager,
      ),
    );

    when(appManager.mockUrlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(false));

    await tapAndSettle(tester, find.byType(Button));
    expect(find.byType(SnackBar), findsOneWidget);
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
        appManager: appManager,
      ),
    );

    when(appManager.mockUrlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(true));

    await tapAndSettle(tester, find.byType(Button));
    expect(find.byType(SnackBar), findsNothing);
    verify(appManager.mockUrlLauncherWrapper.launch(any)).called(1);
  });
}
