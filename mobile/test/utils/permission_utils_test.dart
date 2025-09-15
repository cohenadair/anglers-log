import 'package:adair_flutter_lib/widgets/button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/permission_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.locationMonitor.initialize(),
    ).thenAnswer((_) => Future.value());
  });

  testWidgets("Location exit early if granted", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(true));

    var context = await buildContext(tester);
    expect(
      await requestLocationPermissionWithResultIfNeeded(
        context,
        deniedMessage: "Denied message",
        requestAlways: true,
      ),
      RequestLocationResult.granted,
    );
    verify(managers.locationMonitor.initialize()).called(1);

    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));

    expect(
      await requestLocationPermissionWithResultIfNeeded(
        context,
        deniedMessage: "Denied message",
        requestAlways: false,
      ),
      RequestLocationResult.granted,
    );
    verify(managers.locationMonitor.initialize()).called(1);
  });

  testWidgets("Location iOS request always", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.lib.permissionHandlerWrapper.requestLocationAlways(),
    ).thenAnswer((_) => Future.value(true));
    when(managers.lib.ioWrapper.isIOS).thenReturn(true);
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () {
          requestLocationPermissionIfNeeded(context, requestAlways: true);
        },
      ),
    );
    await tapAndSettle(tester, find.text("TEST"));
    await tester.pumpAndSettle();

    verify(
      managers.lib.permissionHandlerWrapper.requestLocationAlways(),
    ).called(1);
    verify(managers.locationMonitor.initialize()).called(1);

    expect(
      find.text(
        "To show your current location, you must grant Anglers' Log access to read your device's location. To do so, open your device settings.",
      ),
      findsNothing,
    );
  });

  testWidgets("Location Android request always", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.lib.permissionHandlerWrapper.requestLocationAlways(),
    ).thenAnswer((_) => Future.value(true));
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () {
          requestLocationPermissionIfNeeded(context, requestAlways: true);
        },
      ),
    );
    await tapAndSettle(tester, find.text("TEST"));

    expect(
      find.text(
        "To create an accurate GPS trail, Anglers' Log must be able to access your device's location at all times while tracking is active. To grant the required permission, open your device's settings.",
      ),
      findsOneWidget,
    );

    await tapAndSettle(tester, find.text("OPEN SETTINGS"));
    verify(managers.locationMonitor.initialize()).called(1);
  });

  testWidgets("Location Android non-background", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.requestLocation(),
    ).thenAnswer((_) => Future.value(true));
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);

    var context = await buildContext(tester);
    expect(
      await requestLocationPermissionIfNeeded(context, requestAlways: false),
      isTrue,
    );
    verify(managers.locationMonitor.initialize()).called(1);
  });

  testWidgets("Location denied dialog is shown on Android", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.requestLocationAlways(),
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.requestLocation(),
    ).thenAnswer((_) => Future.value(false));
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () {
          requestLocationPermissionIfNeeded(context, requestAlways: true);
        },
      ),
    );
    await tapAndSettle(tester, find.text("TEST"));

    verifyNever(managers.locationMonitor.initialize());
    expect(
      find.text(
        "To show your current location, you must grant Anglers' Log access to read your device's location. To do so, open your device settings.",
      ),
      findsOneWidget,
    );
  });

  // TODO: Behaviour will be removed once GitHub issue is fixed:
  //  https://github.com/Baseflow/flutter-permission-handler/issues/1152.
  testWidgets("Location denied dialog not shown on iOS", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationAlwaysGranted,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.lib.permissionHandlerWrapper.requestLocationAlways(),
    ).thenAnswer((_) => Future.value(false));
    when(managers.lib.ioWrapper.isIOS).thenReturn(true);
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () {
          requestLocationPermissionIfNeeded(context, requestAlways: true);
        },
      ),
    );
    await tapAndSettle(tester, find.text("TEST"));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "To show your current location, you must grant Anglers' Log access to read your device's location. To do so, open your device settings.",
      ),
      findsNothing,
    );
  });

  testWidgets("Location returns in progress exception", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenThrow(PlatformException(code: "permissions is already running"));
    expect(
      await requestLocationPermissionWithResultIfNeeded(
        await buildContext(tester),
      ),
      RequestLocationResult.inProgress,
    );
  });

  testWidgets("Location returns error", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isLocationGranted,
    ).thenThrow(PlatformException(code: "unknown error"));
    expect(
      await requestLocationPermissionWithResultIfNeeded(
        await buildContext(tester),
      ),
      RequestLocationResult.error,
    );
  });
}
