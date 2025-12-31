import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_managers.dart';
import 'test_utils.dart';

void main() {
  late StubbedManagers managers;
  late MockGoogleSignInAccount account;
  late MockGoogleSignIn googleSignIn;
  late MockDriveApi driveApi;

  late BackupRestoreManager backupRestoreManager;

  var imgExt = ".jpg"; // From BackupRestoreManager.
  var databaseName = "anglerslog.db"; // From BackupRestoreManager.
  var databasePath = "path/to/db/$databaseName";

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.catchManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());
    when(
      managers.tripManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());
    when(
      managers.baitManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());
    when(
      managers.fishingSpotManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());

    driveApi = MockDriveApi();
    when(managers.driveApiWrapper.newInstance(any)).thenReturn(driveApi);

    when(
      managers.imageManager.save(any, compress: anyNamed("compress")),
    ).thenAnswer((_) => Future.value([]));

    when(
      managers.localDatabaseManager.insertOrReplace(any, any),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.localDatabaseManager.delete(
        any,
        where: anyNamed("where"),
        whereArgs: anyNamed("whereArgs"),
      ),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.localDatabaseManager.closeAndDeleteDatabase(),
    ).thenAnswer((_) => Future.value());

    when(managers.userPreferenceManager.didSetupBackup).thenReturn(true);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());

    account = MockGoogleSignInAccount();
    when(account.email).thenReturn("test@test.com");
    googleSignIn = MockGoogleSignIn();
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenAnswer((_) => Future.value(account));
    when(googleSignIn.disconnect()).thenAnswer((_) => Future.value());
    when(
      managers.googleSignInWrapper.newInstance(any),
    ).thenReturn(googleSignIn);
    when(
      managers.googleSignInWrapper.authenticatedClient(any),
    ).thenAnswer((_) => Future.value(MockAuthClient()));

    backupRestoreManager = BackupRestoreManager();
  });

  /// Verifies events of [BackupRestoreManager.progressStream], in the order of
  /// [values].
  void verifyProgressStream(List<BackupRestoreProgressEnum> values) {
    int calls = 0;
    backupRestoreManager.progressStream.listen(
      expectAsync1((progress) {
        expect(progress.value, values[calls]);
        calls++;
      }, count: values.length),
    );
  }

  MockFilesResource stubSuccessfulBackup({required bool createDatabase}) {
    var allFileNames = [
      "0$imgExt",
      "1$imgExt",
      "2$imgExt",
      "3$imgExt",
      "4$imgExt",
      "5$imgExt",
    ];

    when(
      managers.imageManager.imageFiles,
    ).thenAnswer((_) => Future.value(allFileNames));

    var mockFile = MockFile();
    when(mockFile.openRead()).thenAnswer((_) => const Stream.empty());
    when(mockFile.lengthSync()).thenReturn(0);
    when(managers.lib.ioWrapper.file(any)).thenReturn(mockFile);

    when(managers.localDatabaseManager.databasePath()).thenReturn(databasePath);

    when(
      managers.userPreferenceManager.setLastBackupAt(any),
    ).thenAnswer((_) => Future.value());

    var fileList = MockFileList();
    when(fileList.files).thenReturn([
      File(name: "1$imgExt"),
      File(name: "2$imgExt"),
      File(name: "3$imgExt"),
      ...createDatabase ? [] : [File(id: "db-id", name: databaseName)],
    ]);
    when(fileList.nextPageToken).thenReturn(null);

    var filesResource = MockFilesResource();
    when(
      filesResource.list(
        $fields: anyNamed("\$fields"),
        spaces: anyNamed("spaces"),
        pageToken: anyNamed("pageToken"),
        pageSize: anyNamed("pageSize"),
      ),
    ).thenAnswer((_) => Future.value(fileList));
    when(
      filesResource.update(
        any,
        any,
        uploadOptions: anyNamed("uploadOptions"),
        uploadMedia: anyNamed("uploadMedia"),
      ),
    ).thenAnswer((_) => Future.value(File()));
    when(
      filesResource.create(
        any,
        uploadOptions: anyNamed("uploadOptions"),
        uploadMedia: anyNamed("uploadMedia"),
      ),
    ).thenAnswer((_) => Future.value(File()));

    when(driveApi.files).thenReturn(filesResource);

    return filesResource;
  }

  MockFile mockFileForDownload({bool exists = false}) {
    var mockIOSink = MockIOSink();
    when(mockIOSink.addStream(any)).thenAnswer((_) => Future.value());

    var mockFile = MockFile();
    when(mockFile.openWrite()).thenReturn(mockIOSink);
    when(mockFile.existsSync()).thenReturn(exists);

    return mockFile;
  }

  test("BackupRestoreProgress percentage is null", () async {
    expect(
      BackupRestoreProgress(
        BackupRestoreProgressEnum.apiRequestError,
        percentage: null,
      ).percentageString,
      "",
    );
  });

  test("BackupRestoreProgress percentage is not null", () async {
    expect(
      BackupRestoreProgress(
        BackupRestoreProgressEnum.apiRequestError,
        percentage: 50,
      ).percentageString,
      " (50%)",
    );
  });

  test("User is logged in when preferences changes", () async {
    // Use real UserPreferenceManager to test listener.
    UserPreferenceManager.reset();
    UserPreferenceManager.get.setDidSetupBackup(false);

    await backupRestoreManager.initialize();
    verifyNever(managers.googleSignInWrapper.newInstance(any));

    await UserPreferenceManager.get.setDidSetupBackup(true);
    verify(managers.googleSignInWrapper.newInstance(any)).called(1);
  });

  test("User is logged out when preferences changes", () async {
    // Use real UserPreferenceManager to test listener.
    UserPreferenceManager.reset();
    UserPreferenceManager.get.setDidSetupBackup(true);

    await backupRestoreManager.initialize();

    await UserPreferenceManager.get.setDidSetupBackup(false);
    await untilCalled(googleSignIn.disconnect());
    verify(googleSignIn.disconnect()).called(1);
  });

  test("Authentication is skipped when the user hasn't setup backup", () async {
    when(managers.userPreferenceManager.didSetupBackup).thenReturn(false);
    await backupRestoreManager.initialize();
    verifyNever(managers.googleSignInWrapper.newInstance(any));
  });

  test("Authentication is setup when app starts", () async {
    when(managers.userPreferenceManager.didSetupBackup).thenReturn(true);
    await backupRestoreManager.initialize();
    verify(managers.googleSignInWrapper.newInstance(any)).called(1);
  });

  test("Authentication exits early if already signed in", () async {
    when(managers.userPreferenceManager.didSetupBackup).thenReturn(true);
    await backupRestoreManager.initialize();
    verify(managers.googleSignInWrapper.newInstance(any)).called(1);

    // Verify re-initializing doesn't authenticate user again.
    await backupRestoreManager.initialize();
    verifyNever(managers.googleSignInWrapper.newInstance(any));
  });

  test("UI is shown if silent authentication fails", () async {
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenAnswer((_) => Future.value(null));
    when(googleSignIn.signIn()).thenAnswer((_) => Future.value(account));

    await backupRestoreManager.initialize();
    verify(googleSignIn.signIn()).called(1);
  });

  test("Auth fails", () async {
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenThrow(ApiRequestError("Test Error"));

    backupRestoreManager.authStream.listen(
      expectAsync1((state) {
        expect(state, BackupRestoreAuthState.error);
      }),
    );
    await backupRestoreManager.initialize();

    var result = verify(
      managers.userPreferenceManager.setDidSetupBackup(captureAny),
    );
    result.called(1);
    expect(result.captured.first, false);
  });

  test("Auth access denied is a no-op", () async {
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenThrow(PlatformException(code: "null", details: "access_denied"));

    backupRestoreManager.authStream.listen(
      expectAsync1((state) {
        expect(state, BackupRestoreAuthState.signedOut);
      }),
    );
    await backupRestoreManager.initialize();
  });

  test("Auth network error is adds network error event", () async {
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenThrow(PlatformException(code: GoogleSignIn.kNetworkError));

    backupRestoreManager.authStream.listen(
      expectAsync1((state) {
        expect(state, BackupRestoreAuthState.networkError);
      }),
    );
    await backupRestoreManager.initialize();
  });

  test("Auth failed sign in error is still an error", () async {
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenThrow(PlatformException(code: GoogleSignIn.kSignInFailedError));

    backupRestoreManager.authStream.listen(
      expectAsync1((state) {
        expect(state, BackupRestoreAuthState.error);
      }),
    );
    await backupRestoreManager.initialize();
  });

  test("Stream adds event when auth is successful", () async {
    backupRestoreManager.authStream.listen(
      expectAsync1((state) {
        expect(state, BackupRestoreAuthState.signedIn);
      }),
    );
    await backupRestoreManager.initialize();

    verify(
      managers.userPreferenceManager.setUserEmail("test@test.com"),
    ).called(1);
  });

  test("Logout exits early if already logged out", () async {
    // Use real UserPreferenceManager to test listener.
    UserPreferenceManager.reset();
    UserPreferenceManager.get.setDidSetupBackup(true);

    // Ensure auth fails to currentUser isn't set.
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenThrow(ApiRequestError("Test Error"));

    backupRestoreManager.authStream.listen(
      expectAsync1((state) {
        expect(state, BackupRestoreAuthState.error);
      }),
    );
    await backupRestoreManager.initialize();
    await UserPreferenceManager.get.setDidSetupBackup(false);
    verifyNever(googleSignIn.disconnect());
  });

  test("Stream adds event when sign out is successful", () async {
    // Use real UserPreferenceManager to test listener.
    UserPreferenceManager.reset();
    UserPreferenceManager.get.setDidSetupBackup(true);

    await backupRestoreManager.initialize();

    backupRestoreManager.authStream.listen(
      expectAsync1((state) {
        expect(state, BackupRestoreAuthState.signedOut);
      }),
    );
    await UserPreferenceManager.get.setDidSetupBackup(false);
    await UserPreferenceManager.get.setUserEmail(null);
    verify(googleSignIn.disconnect()).called(1);
  });

  test("Auto backup exits if user is free", () async {
    // Use real CatchManager to test listener.
    CatchManager.reset();

    when(managers.lib.subscriptionManager.isFree).thenReturn(true);

    await backupRestoreManager.initialize();

    // Trigger catch update.
    await CatchManager.get.addOrUpdate(Catch(id: randomId()));

    await untilCalled(managers.lib.subscriptionManager.isFree);
    verify(managers.lib.subscriptionManager.isFree).called(1);
    verifyNever(managers.userPreferenceManager.autoBackup);
    verifyNever(managers.userPreferenceManager.lastBackupAt);
  });

  test("Auto backup exits if user isn't signed in", () async {
    // Use real UserPreferenceManager to test listener.
    UserPreferenceManager.reset();
    UserPreferenceManager.get.setDidSetupBackup(true);

    // Use real CatchManager to test listener.
    CatchManager.reset();

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);

    await backupRestoreManager.initialize();

    // Verify sign out.
    backupRestoreManager.authStream.listen(
      expectAsync1((state) {
        expect(state, BackupRestoreAuthState.signedOut);
      }),
    );
    await UserPreferenceManager.get.setDidSetupBackup(false);

    // Trigger catch update.
    await CatchManager.get.addOrUpdate(Catch(id: randomId()));

    await untilCalled(managers.lib.subscriptionManager.isFree);
    verify(managers.lib.subscriptionManager.isFree).called(1);
    verifyNever(managers.userPreferenceManager.autoBackup);
    verifyNever(managers.userPreferenceManager.lastBackupAt);
  });

  test("Auto backup exits if autoBackup isn't set to true", () async {
    // Use real CatchManager to test listener.
    CatchManager.reset();

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoBackup).thenReturn(false);

    await backupRestoreManager.initialize();

    // Trigger catch update.
    await CatchManager.get.addOrUpdate(Catch(id: randomId()));

    await untilCalled(managers.userPreferenceManager.autoBackup);
    verify(managers.userPreferenceManager.autoBackup).called(1);
    verifyNever(managers.userPreferenceManager.lastBackupAt);
  });

  test("Auto backup exits if there's no internet connection", () async {
    // Use real CatchManager to test listener.
    CatchManager.reset();

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoBackup).thenReturn(true);
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(null);
    when(
      managers.lib.ioWrapper.lookup(any),
    ).thenAnswer((_) => Future.value([]));

    backupRestoreManager.progressStream.listen(
      expectAsync1(
        (e) => expect(e.value, BackupRestoreProgressEnum.networkError),
      ),
    );
    await backupRestoreManager.initialize();

    // Trigger catch update.
    await CatchManager.get.addOrUpdate(Catch(id: randomId()));
    await untilCalled(managers.lib.ioWrapper.lookup(any));

    verify(managers.lib.ioWrapper.lookup(any)).called(1);
  });

  test("Auto backup exits if threshold hasn't passed", () async {
    // Use real CatchManager to test listener.
    CatchManager.reset();

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoBackup).thenReturn(true);
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(99999999);
    when(
      managers.lib.ioWrapper.lookup(any),
    ).thenAnswer((_) => Future.value([InternetAddress("192.168.2.211")]));
    when(
      managers.googleSignInWrapper.authenticatedClient(any),
    ).thenAnswer((_) => Future.value(null));
    managers.lib.stubCurrentTime(dateTimestamp(100000000));

    await backupRestoreManager.initialize();

    // Trigger catch update.
    await CatchManager.get.addOrUpdate(Catch(id: randomId()));

    await untilCalled(managers.userPreferenceManager.lastBackupAt);
    verify(managers.userPreferenceManager.lastBackupAt).called(1);
    verify(managers.lib.timeManager.currentTimestamp).called(1);
    verifyNever(managers.googleSignInWrapper.authenticatedClient(any));
  });

  test("Auto backup is invoked", () async {
    // Use real CatchManager to test listener.
    CatchManager.reset();

    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoBackup).thenReturn(true);
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(null);
    when(
      managers.lib.ioWrapper.lookup(any),
    ).thenAnswer((_) => Future.value([InternetAddress("192.168.2.211")]));
    when(
      managers.googleSignInWrapper.authenticatedClient(any),
    ).thenAnswer((_) => Future.value(null));
    managers.lib.stubCurrentTime(dateTimestamp(100000000));

    await backupRestoreManager.initialize();

    // Trigger catch update.
    await CatchManager.get.addOrUpdate(Catch(id: randomId()));
    await untilCalled(managers.lib.ioWrapper.lookup(any));

    await untilCalled(managers.userPreferenceManager.lastBackupAt);
    verify(managers.userPreferenceManager.lastBackupAt).called(1);
    verify(managers.googleSignInWrapper.authenticatedClient(any)).called(1);
  });

  test("Backup or restore exits early if in progress", () async {
    await backupRestoreManager.initialize();

    backupRestoreManager.backup();
    backupRestoreManager.backup();
    verify(managers.googleSignInWrapper.authenticatedClient(any)).called(1);
  });

  test(
    "Backup or restore exits early if authenticating client fails",
    () async {
      when(
        managers.googleSignInWrapper.authenticatedClient(any),
      ).thenAnswer((_) => Future.value(null));

      await backupRestoreManager.initialize();

      verifyProgressStream([
        BackupRestoreProgressEnum.authenticating,
        BackupRestoreProgressEnum.authClientError,
      ]);
      await backupRestoreManager.backup();
    },
  );

  test("Backup or restore throws ApiRequestError", () async {
    when(driveApi.files).thenThrow(ApiRequestError("Test Error"));

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.apiRequestError,
    ]);
    await backupRestoreManager.backup();
  });

  test("Backup or restore throws AccessDeniedException", () async {
    when(driveApi.files).thenThrow(AccessDeniedException(""));

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.accessDenied,
    ]);
    await backupRestoreManager.backup();
  });

  test("User's storage quota is full", () async {
    when(driveApi.files).thenThrow(
      DetailedApiRequestError(
        403,
        "The user's Drive storage quota has been exceeded.",
      ),
    );

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.storageFull,
    ]);
    await backupRestoreManager.backup();
  });

  test("Normal backup succeeds", () async {
    var filesResource = stubSuccessfulBackup(createDatabase: false);

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.finished,
    ]);

    await backupRestoreManager.backup();

    // Verify only images that don't exist in Google Drive are created.
    var createResult = verify(
      filesResource.create(
        captureAny,
        uploadOptions: anyNamed("uploadOptions"),
        uploadMedia: anyNamed("uploadMedia"),
      ),
    );
    createResult.called(3);
    expect(createResult.captured[0].name, "0.jpg");
    expect(createResult.captured[1].name, "4.jpg");
    expect(createResult.captured[2].name, "5.jpg");

    // Verify database is updated.
    verify(
      filesResource.update(
        any,
        any,
        uploadOptions: anyNamed("uploadOptions"),
        uploadMedia: anyNamed("uploadMedia"),
      ),
    ).called(1);

    verify(managers.userPreferenceManager.setLastBackupAt(any)).called(1);
    expect(backupRestoreManager.isInProgress, isFalse);
  });

  test("Backup with creating database file", () async {
    var filesResource = stubSuccessfulBackup(createDatabase: true);

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.backingUpData,
      BackupRestoreProgressEnum.finished,
    ]);

    await backupRestoreManager.backup();

    // Verify database was created.
    var createResult = verify(
      filesResource.create(
        captureAny,
        uploadOptions: anyNamed("uploadOptions"),
        uploadMedia: anyNamed("uploadMedia"),
      ),
    );
    createResult.called(4);
    expect(createResult.captured[0].name, "anglerslog.db");
  });

  test("Restore exist early if database file can't be found", () async {
    var fileList = MockFileList();
    when(fileList.files).thenReturn([]);
    when(fileList.nextPageToken).thenReturn(null);

    var filesResource = MockFilesResource();
    when(
      filesResource.list(
        $fields: anyNamed("\$fields"),
        spaces: anyNamed("spaces"),
        pageToken: anyNamed("pageToken"),
        pageSize: anyNamed("pageSize"),
      ),
    ).thenAnswer((_) => Future.value(fileList));

    when(driveApi.files).thenReturn(filesResource);

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.databaseFileNotFound,
    ]);
    await backupRestoreManager.restore();
  });

  test("A normal restore is successful", () async {
    when(
      managers.localDatabaseManager.databasePath(),
    ).thenReturn("path/to/anglerslog.db");
    var mockFile = mockFileForDownload();
    when(managers.lib.ioWrapper.file(any)).thenReturn(mockFile);

    var fileList = MockFileList();
    when(fileList.files).thenReturn([
      File(id: "1", name: "1$imgExt"),
      File(id: "2", name: "2$imgExt"),
      File(id: "3", name: "3$imgExt"),
      File(id: "abc123", name: databaseName),
    ]);
    when(fileList.nextPageToken).thenReturn(null);

    var filesResource = MockFilesResource();
    when(
      filesResource.list(
        $fields: anyNamed("\$fields"),
        spaces: anyNamed("spaces"),
        pageToken: anyNamed("pageToken"),
        pageSize: anyNamed("pageSize"),
      ),
    ).thenAnswer((_) => Future.value(fileList));
    when(
      filesResource.get(any, downloadOptions: anyNamed("downloadOptions")),
    ).thenAnswer((_) => Future.value(Media(const Stream.empty(), 0)));

    when(driveApi.files).thenReturn(filesResource);

    var mockFile1 = mockFileForDownload(exists: false);
    when(managers.imageManager.imageFile("1$imgExt")).thenReturn(mockFile1);
    var mockFile2 = mockFileForDownload(exists: true);
    when(managers.imageManager.imageFile("2$imgExt")).thenReturn(mockFile2);
    var mockFile3 = mockFileForDownload(exists: false);
    when(managers.imageManager.imageFile("3$imgExt")).thenReturn(mockFile3);

    verifyProgressStream([
      BackupRestoreProgressEnum.authenticating,
      BackupRestoreProgressEnum.fetchingFiles,
      BackupRestoreProgressEnum.restoringDatabase,
      BackupRestoreProgressEnum.restoringImages,
      BackupRestoreProgressEnum.restoringImages,
      BackupRestoreProgressEnum.restoringImages,
      BackupRestoreProgressEnum.reloadingData,
      BackupRestoreProgressEnum.finished,
    ]);

    await backupRestoreManager.restore();

    var createResult = verify(
      filesResource.get(
        captureAny,
        downloadOptions: anyNamed("downloadOptions"),
      ),
    );
    createResult.called(3);
    expect(createResult.captured[0], "abc123");
    expect(createResult.captured[1], "1");
    expect(createResult.captured[2], "3");

    verify(managers.app.init(isStartup: false)).called(1);
    expect(backupRestoreManager.isInProgress, isFalse);
  });

  test("Fetch files in multiple batches", () async {
    when(
      managers.localDatabaseManager.databasePath(),
    ).thenReturn("path/to/$databaseName");
    var mockDatabase = mockFileForDownload();
    when(managers.lib.ioWrapper.file(any)).thenReturn(mockDatabase);

    String? nextPageToken;
    var batchNumber = 0;
    var fileList = MockFileList();
    when(fileList.files).thenAnswer((_) {
      List<File> result = [];
      for (var i = 0; i < 5; i++) {
        result.add(File(name: "$i$imgExt"));
      }
      if (batchNumber == 3) {
        result.add(File(id: "db-id", name: databaseName));
      }
      return result;
    });
    when(fileList.nextPageToken).thenAnswer((_) => nextPageToken);

    var filesResource = MockFilesResource();
    when(
      filesResource.list(
        $fields: anyNamed("\$fields"),
        spaces: anyNamed("spaces"),
        pageToken: anyNamed("pageToken"),
        pageSize: anyNamed("pageSize"),
      ),
    ).thenAnswer((_) {
      nextPageToken = ++batchNumber == 3 ? null : "random_token";
      return Future.value(fileList);
    });
    when(
      filesResource.get(any, downloadOptions: anyNamed("downloadOptions")),
    ).thenAnswer((_) => Future.value(Media(const Stream.empty(), 0)));

    when(driveApi.files).thenReturn(filesResource);

    var mockFile = MockFile();
    when(mockFile.existsSync()).thenReturn(true);
    when(managers.imageManager.imageFile(any)).thenReturn(mockFile);

    await backupRestoreManager.restore();

    // 15 calls, one for each 5 item batch.
    verify(managers.imageManager.imageFile(any)).called(15);
  });

  test("Fetch files skips non-image and non-database files", () async {
    when(
      managers.localDatabaseManager.databasePath(),
    ).thenReturn("path/to/anglerslog.db");
    var mockDatabase = mockFileForDownload();
    when(managers.lib.ioWrapper.file(any)).thenReturn(mockDatabase);

    var fileList = MockFileList();
    when(fileList.files).thenReturn([
      File(id: "1", name: "1$imgExt"),
      File(id: "2", name: "2$imgExt"),
      File(id: "5", name: "2.zip"),
      File(id: "3", name: "3$imgExt"),
      File(id: "6", name: "2.doc"),
      File(id: "abc123", name: databaseName),
    ]);
    when(fileList.nextPageToken).thenReturn(null);

    var filesResource = MockFilesResource();
    when(
      filesResource.list(
        $fields: anyNamed("\$fields"),
        spaces: anyNamed("spaces"),
        pageToken: anyNamed("pageToken"),
        pageSize: anyNamed("pageSize"),
      ),
    ).thenAnswer((_) => Future.value(fileList));
    when(
      filesResource.get(any, downloadOptions: anyNamed("downloadOptions")),
    ).thenAnswer((_) => Future.value(Media(const Stream.empty(), 0)));

    when(driveApi.files).thenReturn(filesResource);

    var mockFile = mockFileForDownload(exists: false);
    when(mockFile.existsSync()).thenReturn(false);
    when(managers.imageManager.imageFile(any)).thenReturn(mockFile);

    await backupRestoreManager.restore();

    verify(managers.imageManager.imageFile(any)).called(3);
  });

  test("Notify error sets in-progress to false", () async {
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenThrow(ApiRequestError("Test Error"));

    await backupRestoreManager.initialize();
    expect(backupRestoreManager.isInProgress, isFalse);
  });

  test("Notify signed out exits early if signed in", () async {
    await backupRestoreManager.initialize(); // Sign in.
    backupRestoreManager.notifySignedOutIfNeeded();
    expect(backupRestoreManager.hasLastProgressError, isFalse);
  });

  test("Notify signed out exits early if auto-backup not set", () async {
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenThrow(ApiRequestError("Test Error"));
    when(managers.userPreferenceManager.autoBackup).thenReturn(false);

    await backupRestoreManager.initialize();
    backupRestoreManager.notifySignedOutIfNeeded();
    verify(managers.userPreferenceManager.autoBackup).called(1);
    expect(backupRestoreManager.hasLastProgressError, isFalse);
  });

  test("Notify signed out event", () async {
    when(
      googleSignIn.signInSilently(reAuthenticate: anyNamed("reAuthenticate")),
    ).thenThrow(ApiRequestError("Test Error"));
    when(managers.userPreferenceManager.autoBackup).thenReturn(true);

    await backupRestoreManager.initialize();

    verifyProgressStream([
      BackupRestoreProgressEnum.signedOut,
      BackupRestoreProgressEnum.cleared,
    ]);
    backupRestoreManager.notifySignedOutIfNeeded();
    expect(backupRestoreManager.hasLastProgressError, isTrue);

    // Clear error.
    backupRestoreManager.clearLastProgressError();
    expect(backupRestoreManager.hasLastProgressError, isFalse);
  });

  test("Clear last error exits early if error isn't set", () async {
    var called = false;
    backupRestoreManager.progressStream.listen(
      expectAsync1((_) => called = true, count: 0),
    );

    backupRestoreManager.clearLastProgressError();
    expect(backupRestoreManager.hasLastProgressError, isFalse);
    expect(called, isFalse);
  });
}
