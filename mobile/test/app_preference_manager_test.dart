import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_preference_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';

void main() {
  MockAppManager appManager;

  AppPreferenceManager preferenceManager;

  setUp(() {
    appManager = MockAppManager(
      mockLocalDatabaseManager: true,
      mockAuthManager: true,
      mockSubscriptionManager: true,
    );

    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);
  });

  test("lastLoggedInUserId is set on login", () async {
    var controller = StreamController<void>.broadcast();
    when(appManager.mockAuthManager.stream)
        .thenAnswer((_) => controller.stream);
    when(appManager.mockAuthManager.userId).thenReturn("ID");

    preferenceManager = AppPreferenceManager(appManager);

    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedIn);
    controller.add(null);
    await Future.delayed(Duration(milliseconds: 50));
    expect(preferenceManager.lastLoggedInUserId, "ID");

    // ID doesn't change on logout.
    when(appManager.mockAuthManager.state).thenReturn(AuthState.loggedOut);
    controller.add(null);
    await Future.delayed(Duration(milliseconds: 50));
    expect(preferenceManager.lastLoggedInUserId, "ID");
  });
}
