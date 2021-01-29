import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'mock_app_manager.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  MockAppManager appManager;
  MockFirebaseAuth firebaseAuth;

  AuthManager authManager;

  setUp(() {
    appManager = MockAppManager(
      mockIoWrapper: true,
    );

    firebaseAuth = MockFirebaseAuth();
    authManager = AuthManager(appManager, firebaseAuth);
  });

  test("No connection error returned when there is no internet", () async {
    when(appManager.mockIoWrapper.isConnected())
        .thenAnswer((_) => Future.value(false));
    expect(await authManager.login("", ""), AuthError.noConnection);
  });

  test("Invalid user error when Firebase auth method returns invalid user",
      () async {
    when(appManager.mockIoWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));
    when(firebaseAuth.signInWithEmailAndPassword(
            email: anyNamed("email"), password: anyNamed("password")))
        .thenAnswer((realInvocation) => Future.value(null));

    expect(await authManager.login("", ""), AuthError.invalidUserId);
  });

  test("AuthError error when Firebase auth method throws exception", () async {
    when(appManager.mockIoWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));
    when(firebaseAuth.signInWithEmailAndPassword(
            email: anyNamed("email"), password: anyNamed("password")))
        .thenThrow(FirebaseAuthException(message: "", code: ""));

    expect(await authManager.login("", ""), AuthError.unknownFirebaseException);
  });

  test("Successful Firebase auth", () async {
    when(appManager.mockIoWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));

    var user = MockUser();
    when(user.uid).thenReturn(Uuid().v4().toString());
    var userCredential = MockUserCredential();
    when(userCredential.user).thenReturn(user);
    when(firebaseAuth.signInWithEmailAndPassword(
            email: anyNamed("email"), password: anyNamed("password")))
        .thenAnswer((_) => Future.value(userCredential));

    expect(await authManager.login("", ""), isNull);
  });
}
