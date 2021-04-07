import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_preference_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;

  late AppPreferenceManager preferenceManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.sharedPreferencesWrapper.setString(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.sharedPreferencesWrapper.remove(any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);
  });

  test("lastLoggedInUserEmail is set on login", () async {
    var controller = StreamController<void>.broadcast();
    when(appManager.authManager.stream).thenAnswer((_) => controller.stream);
    when(appManager.authManager.userEmail).thenReturn("test@test.com");

    preferenceManager = AppPreferenceManager(appManager.app);
    await preferenceManager.initialize();

    when(appManager.authManager.state).thenReturn(AuthState.loggedIn);
    controller.add(null);
    await Future.delayed(Duration(milliseconds: 50));
    expect(preferenceManager.lastLoggedInEmail, "test@test.com");

    // ID doesn't change on logout.
    when(appManager.authManager.state).thenReturn(AuthState.loggedOut);
    controller.add(null);
    await Future.delayed(Duration(milliseconds: 50));
    expect(preferenceManager.lastLoggedInEmail, "test@test.com");
  });

  test("lastLoggedInUserEmail is deleted when set to null", () async {
    preferenceManager = AppPreferenceManager(appManager.app);

    preferenceManager.lastLoggedInEmail = "test@test.com";
    verify(appManager.sharedPreferencesWrapper.setString(any, any)).called(1);
    verifyNever(appManager.sharedPreferencesWrapper.remove(any));
    expect(preferenceManager.lastLoggedInEmail, "test@test.com");

    preferenceManager.lastLoggedInEmail = "";
    verifyNever(appManager.sharedPreferencesWrapper.setString(any, any));
    verify(appManager.sharedPreferencesWrapper.remove(any)).called(1);
    expect(preferenceManager.lastLoggedInEmail, isNull);

    preferenceManager.lastLoggedInEmail = null;
    verifyNever(appManager.sharedPreferencesWrapper.setString(any, any));
    verify(appManager.sharedPreferencesWrapper.remove(any)).called(1);
    expect(preferenceManager.lastLoggedInEmail, isNull);
  });
}
