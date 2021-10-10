import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  late AuthManager authManager;

  setUp(() {
    appManager = StubbedAppManager();

    authManager = AuthManager(appManager.app);
  });

  test("No connection error returned when there is no internet", () async {
    when(appManager.ioWrapper.isConnected())
        .thenAnswer((_) => Future.value(false));
    expect(await authManager.login("", ""), AuthError.noConnection);
  });

  test("Invalid user error when Firebase auth method returns invalid user",
      () async {
    when(appManager.ioWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));

    var userCredential = MockUserCredential();
    when(userCredential.user).thenReturn(null);
    when(appManager.firebaseAuthWrapper.signInWithEmailAndPassword(
            email: anyNamed("email"), password: anyNamed("password")))
        .thenAnswer((realInvocation) => Future.value(userCredential));

    expect(await authManager.login("", ""), AuthError.invalidUserId);
  });

  test("AuthError error when Firebase auth method throws exception", () async {
    when(appManager.ioWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));
    when(appManager.firebaseAuthWrapper.signInWithEmailAndPassword(
            email: anyNamed("email"), password: anyNamed("password")))
        .thenThrow(FirebaseAuthException(message: "", code: ""));

    expect(await authManager.login("", ""), AuthError.unknownFirebaseException);
  });

  test("Successful Firebase auth", () async {
    when(appManager.ioWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));

    var user = MockUser();
    when(user.uid).thenReturn(const Uuid().v4().toString());
    var userCredential = MockUserCredential();
    when(userCredential.user).thenReturn(user);
    when(appManager.firebaseAuthWrapper.signInWithEmailAndPassword(
            email: anyNamed("email"), password: anyNamed("password")))
        .thenAnswer((_) => Future.value(userCredential));

    expect(await authManager.login("", ""), isNull);
  });

  test("FirebaseAuth callback logged out", () async {
    var stream = createMockStreamWithSubscription<User>();
    when(appManager.firebaseAuthWrapper.authStateChanges())
        .thenAnswer((_) => stream);

    await authManager.initialize();

    // In this test, we assume Firestore listeners work as expected, and we
    // capture the listener function passed to snapshots().listen and invoke it
    // manually.
    var result = verify(stream.listen(captureAny));
    result.called(1);

    var listener = result.captured.first;

    // On logout.
    authManager.stream.listen(expectAsync1((_) {
      expect(authManager.state, AuthState.loggedOut);
    }));
    listener(null);
  });

  test("FirebaseAuth callback logged in", () async {
    var stream = createMockStreamWithSubscription<User>();
    when(appManager.firebaseAuthWrapper.authStateChanges())
        .thenAnswer((_) => stream);

    await authManager.initialize();

    // In this test, we assume Firestore listeners work as expected, and we
    // capture the listener function passed to snapshots().listen and invoke it
    // manually.
    var result = verify(stream.listen(captureAny));
    result.called(1);

    var listener = result.captured.first;

    // On login.
    var user = MockUser();
    when(user.uid).thenReturn("UID");

    var callbackStates = <AuthState>[];
    // Initializing state until all managers have been initialized.
    authManager.stream.listen((_) => callbackStates.add(authManager.state));
    listener(user);
    await Future.delayed(const Duration(milliseconds: 50));

    expect(callbackStates.length, 2);
    expect(callbackStates.first, AuthState.initializing);
    expect(callbackStates.last, AuthState.loggedIn);
  });
}
