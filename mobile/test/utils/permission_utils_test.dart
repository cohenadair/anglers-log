import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/permission_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.locationMonitor.initialize())
        .thenAnswer((_) => Future.value());
  });

  testWidgets("Location exit early if granted", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(true));

    var context = await buildContext(tester, appManager: appManager);
    expect(
      await requestLocationPermissionWithResultIfNeeded(
        context: context,
        deniedMessage: "Denied message",
        requestAlwaysMessage: "Request always message",
      ),
      RequestLocationResult.granted,
    );
    verify(appManager.locationMonitor.initialize()).called(1);

    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));

    expect(
      await requestLocationPermissionWithResultIfNeeded(
        context: context,
        deniedMessage: "Denied message",
        requestAlwaysMessage: null,
      ),
      RequestLocationResult.granted,
    );
    verify(appManager.locationMonitor.initialize()).called(1);
  });

  testWidgets("Location iOS request always", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.permissionHandlerWrapper.requestLocationAlways())
        .thenAnswer((_) => Future.value(true));
    when(appManager.ioWrapper.isIOS).thenReturn(true);
    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () {
          requestLocationPermissionIfNeeded(
            context: context,
            requestAlways: true,
          );
        },
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("TEST"));
    await tester.pumpAndSettle();

    verify(appManager.permissionHandlerWrapper.requestLocationAlways())
        .called(1);
    verify(appManager.locationMonitor.initialize()).called(1);

    expect(
      find.text(
          "To show your current location, you must grant Anglers' Log access to read your device's location. To do so, open your device settings."),
      findsNothing,
    );
  });

  testWidgets("Location Android request always", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.permissionHandlerWrapper.requestLocationAlways())
        .thenAnswer((_) => Future.value(true));
    when(appManager.ioWrapper.isIOS).thenReturn(false);
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () {
          requestLocationPermissionIfNeeded(
            context: context,
            requestAlways: true,
          );
        },
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("TEST"));

    expect(
      find.text(
          "To create an accurate GPS trail, Anglers' Log must be able to access your device's location at all times while tracking is active. To grant the required permission, open your device's settings."),
      findsOneWidget,
    );

    await tapAndSettle(tester, find.text("OPEN SETTINGS"));
    verify(appManager.locationMonitor.initialize()).called(1);
  });

  testWidgets("Location Android non-background", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(true));
    when(appManager.ioWrapper.isIOS).thenReturn(false);

    var context = await buildContext(tester, appManager: appManager);
    expect(
      await requestLocationPermissionIfNeeded(
        context: context,
        requestAlways: false,
      ),
      isTrue,
    );
    verify(appManager.locationMonitor.initialize()).called(1);
  });

  testWidgets("Location denied dialog is shown on Android", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.requestLocationAlways())
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.requestLocation())
        .thenAnswer((_) => Future.value(false));
    when(appManager.ioWrapper.isIOS).thenReturn(false);
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () {
          requestLocationPermissionIfNeeded(
            context: context,
            requestAlways: true,
          );
        },
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("TEST"));

    verifyNever(appManager.locationMonitor.initialize());
    expect(
      find.text(
          "To show your current location, you must grant Anglers' Log access to read your device's location. To do so, open your device settings."),
      findsOneWidget,
    );
  });

  // TODO: Behaviour will be removed once GitHub issue is fixed:
  //  https://github.com/Baseflow/flutter-permission-handler/issues/1152.
  testWidgets("Location denied dialog not shown on iOS", (tester) async {
    when(appManager.permissionHandlerWrapper.isLocationAlwaysGranted)
        .thenAnswer((_) => Future.value(false));
    when(appManager.permissionHandlerWrapper.isLocationGranted)
        .thenAnswer((_) => Future.value(true));
    when(appManager.permissionHandlerWrapper.requestLocationAlways())
        .thenAnswer((_) => Future.value(false));
    when(appManager.ioWrapper.isIOS).thenReturn(true);
    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    await pumpContext(
      tester,
      (context) => Button(
        text: "Test",
        onPressed: () {
          requestLocationPermissionIfNeeded(
            context: context,
            requestAlways: true,
          );
        },
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("TEST"));
    await tester.pumpAndSettle();

    expect(
      find.text(
          "To show your current location, you must grant Anglers' Log access to read your device's location. To do so, open your device settings."),
      findsNothing,
    );
  });
}
