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

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(false));
    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);
  });

  test("lastLoggedInUserId is set on login", () async {
    var controller = StreamController<void>.broadcast();
    when(appManager.authManager.stream).thenAnswer((_) => controller.stream);
    when(appManager.authManager.userId).thenReturn("ID");

    preferenceManager = AppPreferenceManager(appManager.app);

    when(appManager.authManager.state).thenReturn(AuthState.loggedIn);
    controller.add(null);
    await Future.delayed(Duration(milliseconds: 50));
    expect(preferenceManager.lastLoggedInUserId, "ID");

    // ID doesn't change on logout.
    when(appManager.authManager.state).thenReturn(AuthState.loggedOut);
    controller.add(null);
    await Future.delayed(Duration(milliseconds: 50));
    expect(preferenceManager.lastLoggedInUserId, "ID");
  });
}
