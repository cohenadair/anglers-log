import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/notification_permission_page.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("Request permission", (tester) async {
    when(managers.permissionHandlerWrapper.requestNotification()).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 50),
        () => Future.value(false),
      ),
    );

    await pumpContext(tester, (_) => NotificationPermissionPage());

    expect(find.byType(Loading), findsNothing);

    await tester.tap(find.text("SET PERMISSION"));
    await tester.pump();

    expect(find.byType(Loading), findsOneWidget);

    // Finish requestNotification() call.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.byType(NotificationPermissionPage), findsNothing);
  });

  testWidgets("Permission not requested if page is closed", (tester) async {
    await pumpContext(tester, (_) => NotificationPermissionPage());

    await tapAndSettle(tester, find.byType(CloseButton));
    verifyNever(managers.permissionHandlerWrapper.requestNotification());
  });
}
