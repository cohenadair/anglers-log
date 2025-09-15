import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/location_permission_page.dart';
import 'package:mockito/mockito.dart';

import '../../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("onNext not called if not mounted", (tester) async {
    when(managers.lib.permissionHandlerWrapper.isLocationGranted).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 2000), () => true),
    );

    var onNextCalled = false;
    await pumpContext(
      tester,
      (context) => LocationPermissionPage(onNext: (_) => onNextCalled = true),
    );

    // Trigger the async call.
    await tester.tap(find.text("SET PERMISSION"));
    verify(managers.lib.permissionHandlerWrapper.isLocationGranted).called(1);

    // Dismount the LocationPermissionPage by tapping the back button.
    await tapAndSettle(tester, find.byType(BackButtonIcon));
    expect(find.byType(LocationPermissionPage), findsNothing);

    // Wait for isLocationGranted future and verify onNext wasn't called.
    await tester.pump(const Duration(milliseconds: 2000));
    expect(onNextCalled, isFalse);
  });

  testWidgets("onNext not called if permission request is in progress", (
    tester,
  ) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenThrow(PlatformException(code: "permissions is already running"));

    var onNextCalled = false;
    await pumpContext(
      tester,
      (context) => LocationPermissionPage(onNext: (_) => onNextCalled = true),
    );

    // Trigger the async call.
    await tester.tap(find.text("SET PERMISSION"));
    verify(managers.lib.permissionHandlerWrapper.isLocationGranted).called(1);

    // Wait for isLocationGranted future and verify onNext is not called.
    await tester.pump(const Duration(milliseconds: 50));
    expect(onNextCalled, isFalse);
  });

  testWidgets("onNext is called", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));

    var onNextCalled = false;
    await pumpContext(
      tester,
      (context) => LocationPermissionPage(onNext: (_) => onNextCalled = true),
    );

    // Trigger the async call.
    await tester.tap(find.text("SET PERMISSION"));
    verify(managers.lib.permissionHandlerWrapper.isLocationGranted).called(1);

    // Wait for isLocationGranted future and verify onNext is called.
    await tester.pump(const Duration(milliseconds: 50));
    expect(onNextCalled, isTrue);
  });
}
