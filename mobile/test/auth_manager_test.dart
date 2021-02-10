import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  MockAppManager appManager;

  AuthManager authManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockCatchManager: true,
      mockComparisonReportManager: true,
      mockCustomEntityManager: true,
      mockFishingSpotManager: true,
      mockImageManager: true,
      mockSpeciesManager: true,
      mockSummaryReportManager: true,
      mockUserPreferenceManager: true,
      mockFirebaseAuthWrapper: true,
      mockIoWrapper: true,
    );

    authManager = AuthManager(appManager);
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
    when(appManager.mockFirebaseAuthWrapper.signInWithEmailAndPassword(
            email: anyNamed("email"), password: anyNamed("password")))
        .thenAnswer((realInvocation) => Future.value(null));

    expect(await authManager.login("", ""), AuthError.invalidUserId);
  });

  test("AuthError error when Firebase auth method throws exception", () async {
    when(appManager.mockIoWrapper.isConnected())
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockFirebaseAuthWrapper.signInWithEmailAndPassword(
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
    when(appManager.mockFirebaseAuthWrapper.signInWithEmailAndPassword(
            email: anyNamed("email"), password: anyNamed("password")))
        .thenAnswer((_) => Future.value(userCredential));

    expect(await authManager.login("", ""), isNull);
  });

  test("FirebaseAuth callback logged out", () async {
    var stream = MockStream<User>();
    when(appManager.mockFirebaseAuthWrapper.authStateChanges())
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
    var stream = MockStream<User>();
    when(appManager.mockFirebaseAuthWrapper.authStateChanges())
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
    await Future.delayed(Duration(milliseconds: 50));

    expect(callbackStates.length, 2);
    expect(callbackStates.first, AuthState.initializing);
    expect(callbackStates.last, AuthState.loggedIn);
  });
}
