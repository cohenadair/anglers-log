import 'dart:async';

import 'package:adair_flutter_lib/widgets/enabled_opacity.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/widgets/cloud_auth.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.backupRestoreManager.authStream,
    ).thenAnswer((_) => const Stream.empty());

    var account = MockGoogleSignInAccount();
    when(account.email).thenReturn("test@test.com");
    when(managers.backupRestoreManager.currentUser).thenReturn(account);
  });

  testWidgets("BackupRestoreManager auth changes updates state/shows errors", (
    tester,
  ) async {
    var controller = StreamController<BackupRestoreAuthState>.broadcast(
      sync: true,
    );
    var isSignedIn = false;
    when(
      managers.backupRestoreManager.authStream,
    ).thenAnswer((_) => controller.stream);
    when(
      managers.backupRestoreManager.isSignedIn,
    ).thenAnswer((_) => isSignedIn);

    await pumpContext(tester, (_) => const CloudAuth());

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
        "There was a network error while signing in. Please ensure you are connected to the internet and try again.",
      ),
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

  testWidgets("Sign in button signs in", (tester) async {
    when(managers.backupRestoreManager.isSignedIn).thenReturn(false);
    when(
      managers.backupRestoreManager.signIn(),
    ).thenAnswer((_) => Future.value());

    await pumpContext(tester, (_) => const CloudAuth());
    await tapAndSettle(tester, find.text("Sign in with Google"));

    verify(managers.backupRestoreManager.signIn()).called(1);
    expect(find.byType(Loading), findsNothing);
  });

  testWidgets("Sign in button is disabled and shows loading while signing in", (
    tester,
  ) async {
    var completer = Completer<void>();
    when(managers.backupRestoreManager.isSignedIn).thenReturn(false);
    when(
      managers.backupRestoreManager.signIn(),
    ).thenAnswer((_) => completer.future);

    await pumpContext(tester, (_) => const CloudAuth());
    await tester.tap(find.text("Sign in with Google"));
    await tester.pump();

    expect(find.byType(Loading), findsOneWidget);
    expect(
      tester.widget<EnabledOpacity>(find.byType(EnabledOpacity)).isEnabled,
      isFalse,
    );

    // Tapping again while signing in does nothing.
    await tester.tap(find.text("Sign in with Google"));
    await tester.pump();
    verify(managers.backupRestoreManager.signIn()).called(1);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(
      tester.widget<EnabledOpacity>(find.byType(EnabledOpacity)).isEnabled,
      isTrue,
    );
  });

  testWidgets("Sign in finishing after dispose doesn't throw", (tester) async {
    var completer = Completer<void>();
    when(managers.backupRestoreManager.isSignedIn).thenReturn(false);
    when(
      managers.backupRestoreManager.signIn(),
    ).thenAnswer((_) => completer.future);

    await pumpContext(tester, (_) => const CloudAuth());
    await tester.tap(find.text("Sign in with Google"));
    await tester.pump();

    await pumpContext(tester, (_) => const SizedBox());
    completer.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets("Sign in shows an error and re-enables if sign in throws", (
    tester,
  ) async {
    when(managers.backupRestoreManager.isSignedIn).thenReturn(false);
    when(
      managers.backupRestoreManager.signIn(),
    ).thenAnswer((_) => Future.error(Exception("Test error")));

    await pumpContext(tester, (_) => const CloudAuth());
    await tapAndSettle(tester, find.text("Sign in with Google"));

    expect(
      find.text("Error signing in, please try again later."),
      findsOneWidget,
    );
    expect(find.byType(Loading), findsNothing);
    expect(
      tester.widget<EnabledOpacity>(find.byType(EnabledOpacity)).isEnabled,
      isTrue,
    );
  });

  testWidgets("Starting sign in clears a previous error", (tester) async {
    var controller = StreamController<BackupRestoreAuthState>.broadcast(
      sync: true,
    );
    when(
      managers.backupRestoreManager.authStream,
    ).thenAnswer((_) => controller.stream);
    when(managers.backupRestoreManager.isSignedIn).thenReturn(false);
    when(
      managers.backupRestoreManager.signIn(),
    ).thenAnswer((_) => Future.value());

    await pumpContext(tester, (_) => const CloudAuth());
    controller.add(BackupRestoreAuthState.error);
    await tester.pumpAndSettle();
    expect(
      find.text("Error signing in, please try again later."),
      findsOneWidget,
    );

    await tapAndSettle(tester, find.text("Sign in with Google"));

    expect(
      find.text("Error signing in, please try again later."),
      findsNothing,
    );
  });
}
