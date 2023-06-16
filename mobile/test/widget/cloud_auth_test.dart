import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/widgets/cloud_auth.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.backupRestoreManager.authStream)
        .thenAnswer((_) => const Stream.empty());

    var account = MockGoogleSignInAccount();
    when(account.email).thenReturn("test@test.com");
    when(appManager.backupRestoreManager.currentUser).thenReturn(account);
  });

  testWidgets("BackupRestoreManager auth changes updates state/shows errors",
      (tester) async {
    var controller =
        StreamController<BackupRestoreAuthState>.broadcast(sync: true);
    var isSignedIn = false;
    when(appManager.backupRestoreManager.authStream)
        .thenAnswer((_) => controller.stream);
    when(appManager.backupRestoreManager.isSignedIn)
        .thenAnswer((_) => isSignedIn);

    await pumpContext(tester, (_) => const CloudAuth(), appManager: appManager);

    // Sign in.
    expect(find.text("Sign in with Google"), findsOneWidget);

    // Sign in generic error.
    controller.add(BackupRestoreAuthState.error);
    await tester.pumpAndSettle();

    expect(
      find.text("Error signing in, please try again later."),
      findsOneWidget,
    );
    expect(find.text("Sign in with Google"), findsOneWidget);

    // Sign in network error.
    controller.add(BackupRestoreAuthState.networkError);
    await tester.pumpAndSettle();

    expect(
      find.text(
          "There was a network error while signing in. Please ensure you are connected to the internet and try again."),
      findsOneWidget,
    );
    expect(find.text("Sign in with Google"), findsOneWidget);

    // Signed in.
    isSignedIn = true;
    controller.add(BackupRestoreAuthState.signedIn);
    await tester.pumpAndSettle();

    expect(find.text("Sign in with Google"), findsNothing);
    expect(find.text("SIGN OUT"), findsOneWidget);
  });
}
