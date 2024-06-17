import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/notification_permission_page.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  testWidgets("Request permission", (tester) async {
    when(appManager.permissionHandlerWrapper.requestNotification()).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 50),
        () => Future.value(false),
      ),
    );

    await pumpContext(
      tester,
      (_) => NotificationPermissionPage(),
      appManager: appManager,
    );

    expect(find.byType(Loading), findsNothing);

    await tester.tap(find.text("SET PERMISSION"));
    await tester.pump();

    expect(find.byType(Loading), findsOneWidget);

    // Finish requestNotification() call.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.byType(NotificationPermissionPage), findsNothing);
  });

  testWidgets("Permission not requested if page is closed", (tester) async {
    await pumpContext(
      tester,
      (_) => NotificationPermissionPage(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byType(CloseButton));
    verifyNever(appManager.permissionHandlerWrapper.requestNotification());
  });
}
