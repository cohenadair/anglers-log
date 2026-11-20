import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/io.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/number_utils.dart';
import 'package:mobile/wrappers/drive_api_wrapper.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:path/path.dart';

import 'app_manager.dart';
import 'bait_manager.dart';
import 'local_database_manager.dart';
import 'model/gen/anglers_log.pb.dart';
import 'wrappers/google_sign_in_wrapper.dart';

enum BackupRestoreAuthState { signedOut, signedIn, error, networkError }

enum BackupRestoreProgressEnum {
  // Errors
  authClientError(true),
  createFolderError(true),
  folderNotFound(true),
  apiRequestError(true),
  databaseFileNotFound(true),
  accessDenied(true), // Forwarded from Drive API
  networkError(true),
  signedOut(true),
  storageFull(true),

  // Progress states
  authenticating(false),
  fetchingFiles(false),
  creatingFolder(false),
  backingUpData(false),
  restoringDatabase(false),
  restoringImages(false),
  reloadingData(false),
  finished(false),
  cleared(false);

  final bool isError;

  const BackupRestoreProgressEnum(this.isError);
}

class BackupRestoreProgress {
  final BackupRestoreProgressEnum value;
  final Object? apiError;
  final int? percentage;

  BackupRestoreProgress(this.value, {this.apiError, this.percentage});

  String get percentageString => percentage == null ? "" : " ($percentage%)";

  bool get isError => value.isError;
}

class BackupRestoreManager {
  static BackupRestoreManager of(BuildContext context) =>
      AppManager.get.backupRestoreManager;

  static const _databaseName = "anglerslog.db";
  static const _appDataFolderName = "appDataFolder";

  // Maximum size per
  // https://developers.google.com/drive/api/v3/reference/files/list.
  static const _filesFetchSize = 1000;

  /// The most uploads or downloads to run at once.
  static const _maxConcurrentTransfers = 8;

  /// Rate limit how often automatic backups are made.
  static const _autoBackupInterval = Duration.millisecondsPerMinute * 5;

  /// [PlatformException.code] thrown by AppAuth (used by Google Sign-In on
  /// iOS) when the token request fails due to a network error, such as a
  /// timeout. See OIDErrorCodeNetworkError.
  static const _appAuthNetworkErrorCode = "org.openid.appauth.general: -5";

  /// How long a backup or restore can go without progress before it's
  /// considered stalled; a stall is detected between one and two of these.
  /// Drive requests have no timeout, so a dropped connection (e.g. toggling
  /// airplane mode) would otherwise leave a backup waiting forever, and the
  /// backup page can't be left while one is in progress.
  ///
  /// Progress is a finished file, a fetched page of files, or a chunk of data
  /// read for upload (1 MB at a time) or downloaded. With 8 uploads at once,
  /// only connections slower than about 75 KB/s are cut off.
  static const _stallTimeout = Duration(minutes: 2);

  /// Google Sign-In doesn't provide an access token's expiry. The Drive
  /// client never refreshes the token, so this is never checked.
  static final _accessTokenExpiry = DateTime.utc(9999);

  /// How long to wait for interactive sign in before giving up. On some
  /// devices (e.g. Xiaomi HyperOS), the account picker never appears and
  /// GoogleSignIn.authenticate() never completes, so without a timeout the
  /// sign in button appears frozen. This is generous so users still have time
  /// to pick or add an account.
  static const _authenticateTimeout = Duration(minutes: 1);

  final _log = const Log("BackupRestoreManager");
  final _authController = StreamController<BackupRestoreAuthState>.broadcast();
  final _progressController =
      StreamController<BackupRestoreProgress>.broadcast();

  /// True if a backup or restore is in progress; false otherwise.
  var _isInProgress = false;

  GoogleSignInAccount? _currentUser;
  BackupRestoreProgress? _lastProgressError;

  /// Set while the account signed out by [_disconnectAccount] is being
  /// removed from Google Sign-In. Signing in waits for it, so it doesn't
  /// silently restore the account being removed.
  Future<void>? _pendingDisconnect;

  /// Used so we don't show multiple [BackupRestorePage] instances when a user
  /// taps the backup error notification.
  bool isBackupRestorePageShowing = false;

  BaitManager get _baitManager => AppManager.get.baitManager;

  DriveApiWrapper get _driveApiWrapper => AppManager.get.driveApiWrapper;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.get;

  GoogleSignInWrapper get _googleSignInWrapper =>
      AppManager.get.googleSignInWrapper;

  HttpWrapper get _httpWrapper => AppManager.get.httpWrapper;

  ImageManager get _imageManager => AppManager.get.imageManager;

  TripManager get _tripManager => AppManager.get.tripManager;

  BackupRestoreManager();

  /// A [Stream] that fires events when a user's authentication changes.
  Stream<BackupRestoreAuthState> get authStream => _authController.stream;

  /// A [Stream] that fires events when the progress of a backup or restore
  /// changes.
  Stream<BackupRestoreProgress> get progressStream =>
      _progressController.stream;

  GoogleSignInAccount? get currentUser => _currentUser;

  BackupRestoreProgress? get lastProgressError => _lastProgressError;

  bool get hasLastProgressError => lastProgressError != null;

  bool get isSignedIn => currentUser != null;

  bool get isInProgress => _isInProgress;

  int? get lastBackupAt => UserPreferenceManager.get.lastBackupAt;

  Future<void> initialize() async {
    // Per google_sign_in's contract, this must be called exactly once, before
    // any other GoogleSignIn method.
    await _googleSignInWrapper.initialize(
      serverClientId: PropertiesManager.get.googleSignInServerClientId,
    );

    // Signing in is done explicitly via signIn(). This listener fires for every
    // preference change, so it only handles signing out.
    UserPreferenceManager.get.stream.listen((_) {
      if (!UserPreferenceManager.get.didSetupBackup) {
        _disconnectAccount();
      }
    });
    CatchManager.get.listen(_createEntityListener<Catch>());
    _tripManager.listen(_createEntityListener<Trip>());
    _baitManager.listen(_createEntityListener<Bait>());
    _fishingSpotManager.listen(_createEntityListener<FishingSpot>());

    if (!UserPreferenceManager.get.didSetupBackup) {
      _log.d("Skipping auth; user hasn't setup backup");
      return;
    }

    _log.d("Authenticating user for data backup and restore");
    await _authenticateAndSetupAutoBackup(allowInteractiveSignIn: false);
  }

  EntityListener<T> _createEntityListener<T>() {
    return EntityListener<T>(
      onAdd: (_) => _autoBackupIfNeeded(),
      onDelete: (_) => _autoBackupIfNeeded(),
      onUpdate: (_) => _autoBackupIfNeeded(),
    );
  }

  Future<void> _authenticateAndSetupAutoBackup({
    bool allowInteractiveSignIn = true,
  }) async {
    await _authenticateUser(allowInteractiveSignIn: allowInteractiveSignIn);
  }

  /// Authenticates the user with Google Sign-In. [allowInteractiveSignIn]
  /// must be false when called during app startup, before a
  /// presentingViewController is available to show sign in UI; interactive
  /// sign in is only safe once the user has taken an action (i.e. changed
  /// backup preferences) after startup has finished.
  Future<void> _authenticateUser({bool allowInteractiveSignIn = true}) async {
    if (_currentUser != null) {
      return;
    }

    final pendingDisconnect = _pendingDisconnect;
    if (pendingDisconnect != null) {
      await pendingDisconnect;
    }

    try {
      try {
        _currentUser = await _googleSignInWrapper
            .attemptLightweightAuthentication();
      } catch (error) {
        if (!allowInteractiveSignIn) {
          // No fallback to try; let the outer catch handle and report this
          // like any other sign in failure.
          rethrow;
        }
        // A cached token can be expired or revoked server-side, causing
        // this to throw instead of returning null. Treat it the same as
        // "no cached session" so the interactive sign in below still runs.
        _log.d("Lightweight authentication failed, prompting for sign in");
      }

      if (_currentUser == null && allowInteractiveSignIn) {
        _currentUser = await _googleSignInWrapper.authenticate().timeout(
          _authenticateTimeout,
        );
      }

      // Don't log the account's email; logs are sent to Crashlytics.
      _log.d("Signed in: ${_currentUser != null}");
    } catch (error) {
      if (error is GoogleSignInException &&
          error.code == GoogleSignInExceptionCode.canceled) {
        // User didn't grant permissions, notify that we're still signed out.
        _authController.add(BackupRestoreAuthState.signedOut);
      } else if ((error is GoogleSignInException &&
              error.code == GoogleSignInExceptionCode.interrupted) ||
          (error is PlatformException &&
              error.code == _appAuthNetworkErrorCode)) {
        // Network errors are expected occasionally; don't log to Firebase.
        _authController.add(BackupRestoreAuthState.networkError);
      } else if (error is GoogleSignInException &&
          error.code == GoogleSignInExceptionCode.unknownError) {
        // Unknown error from SDK, don't log an error to Firebase.
        _authController.add(BackupRestoreAuthState.error);
      } else if (error is TimeoutException) {
        _log.e(error, reason: "Sign in timed out");
        _authController.add(BackupRestoreAuthState.error);
      } else {
        _log.e(error, reason: "Sign in error");
        _authController.add(BackupRestoreAuthState.error);
      }
    }

    // A failed sign in must not reset didSetupBackup. Doing so turned backups
    // off whenever startup sign in failed (e.g. offline), and they silently
    // stopped for good. Startup sign in is retried on the next launch instead.
    if (_currentUser != null) {
      _authController.add(BackupRestoreAuthState.signedIn);
      UserPreferenceManager.get.setUserEmail(_currentUser!.email);
    }
  }

  Future<void> _disconnectAccount() async {
    if (_currentUser == null) {
      return;
    }

    // Sign out locally first, so the UI updates even if disconnecting fails.
    _currentUser = null;
    _authController.add(BackupRestoreAuthState.signedOut);
    UserPreferenceManager.get.setUserEmail(null);

    final disconnect = _disconnect();
    _pendingDisconnect = disconnect;
    await disconnect;
    _pendingDisconnect = null;
  }

  /// Removes the signed in account from Google Sign-In. Never throws.
  Future<void> _disconnect() async {
    try {
      await _googleSignInWrapper.disconnect();
    } catch (error) {
      // On iOS, disconnecting revokes access over the network, and fails if
      // access was already revoked (e.g. from Google Drive), or the device is
      // offline. The SDK then skips signing out, leaving the account cached,
      // so the next sign in would silently reuse it, along with its revoked
      // token. Sign out locally instead.
      _log.w("Disconnect failed, signing out: $error");
      try {
        await _googleSignInWrapper.signOut();
      } catch (error) {
        _log.e(error, reason: "Sign out failed");
      }
    }
  }

  /// Returns [_currentUser]'s authorization for [scopes], requested silently,
  /// falling back to an interactive prompt if needed. Returns null if there's
  /// no signed in user.
  Future<GoogleSignInClientAuthorization?> _authorize(
    List<String> scopes,
  ) async {
    var user = _currentUser;
    if (user == null) {
      return null;
    }

    GoogleSignInClientAuthorization? authorization;
    try {
      authorization = await user.authorizationClient.authorizationForScopes(
        scopes,
      );
    } catch (error) {
      // A cached authorization can be expired or revoked server-side,
      // causing this to throw instead of returning null. Treat it the same
      // as "no cached authorization" so the interactive request below still
      // runs.
      _log.d("Silent authorization failed: $error");
    }
    return authorization ??
        await user.authorizationClient.authorizeScopes(scopes);
  }

  /// Removes [authorization]'s token from Google Sign-In's cache, so a new
  /// one is requested next time. Called when Drive rejects the token, such as
  /// when access was revoked from Google Drive.
  Future<void> _clearAuthorization(
    GoogleSignInClientAuthorization authorization,
  ) async {
    try {
      await _currentUser?.authorizationClient.clearAuthorizationToken(
        accessToken: authorization.accessToken,
      );
    } catch (error) {
      _log.e(error, reason: "Clear authorization token failed");
    }
  }

  Future<void> _autoBackupIfNeeded() async {
    if (SubscriptionManager.get.isFree ||
        !UserPreferenceManager.get.autoBackup) {
      return;
    }

    var lastBackupAt = UserPreferenceManager.get.lastBackupAt;
    if (lastBackupAt != null &&
        TimeManager.get.currentTimestamp - lastBackupAt < _autoBackupInterval) {
      _log.d("Last backup was < interval, skipping...");
      return;
    }

    if (!isSignedIn) {
      _notifyError(BackupRestoreProgress(BackupRestoreProgressEnum.signedOut));
      return;
    }

    if (!(await isConnected())) {
      _notifyError(
        BackupRestoreProgress(BackupRestoreProgressEnum.networkError),
      );
      return;
    }

    await backup();
  }

  /// Notifies listeners if the user is signed out and has auto-backup enabled.
  /// This should only be called when the app starts, after the main view has
  /// been rendered.
  void notifySignedOutIfNeeded() {
    if (isSignedIn || !UserPreferenceManager.get.autoBackup) {
      return;
    }
    _notifyError(BackupRestoreProgress(BackupRestoreProgressEnum.signedOut));
  }

  /// Signs the user in, showing Google's sign in UI if needed. Backup is only
  /// marked as set up once sign in succeeds, so a canceled or failed attempt
  /// can be retried.
  Future<void> signIn() async {
    await _authenticateAndSetupAutoBackup();
    if (isSignedIn) {
      await UserPreferenceManager.get.setDidSetupBackup(true);
    }
  }

  Future<void> backup() async {
    await _backupOrRestore(backup: true);
  }

  Future<void> restore() async {
    await _backupOrRestore(backup: false);
  }

  void clearLastProgressError() {
    // Only notify if needed.
    if (_lastProgressError == null) {
      return;
    }

    _lastProgressError = null;
    _notifyProgress(
      BackupRestoreProgress(BackupRestoreProgressEnum.cleared),
      killProcess: true,
    );
  }

  Future<void> _backupOrRestore({required bool backup}) async {
    if (_isInProgress) {
      return;
    }

    GoogleSignInClientAuthorization? authorization;
    _StallWatchdog? watchdog;
    try {
      _isInProgress = true;

      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.authenticating),
      );

      final scopes = [DriveApi.driveAppdataScope];
      authorization = await _authorize(scopes);
      if (authorization == null) {
        _notifyError(
          BackupRestoreProgress(BackupRestoreProgressEnum.authClientError),
        );
        return;
      }

      _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.fetchingFiles),
      );

      final authClient = authenticatedClient(
        _httpWrapper.newClient(),
        AccessCredentials(
          AccessToken("Bearer", authorization.accessToken, _accessTokenExpiry),
          null,
          scopes,
        ),
        // So closing it aborts in-flight requests.
        closeUnderlyingClient: true,
      );
      final drive = _driveApiWrapper.newInstance(authClient);

      // Closing the client fails the stalled requests, so the abandoned
      // backup or restore stops instead of resuming in the background.
      watchdog = _StallWatchdog(_stallTimeout, authClient.close);
      await Future.any([
        backup ? _backup(drive, watchdog) : _restore(drive, watchdog),
        watchdog.stalled,
      ]);
    } on AccessDeniedException catch (_) {
      // Only Drive requests throw this, so authorization is always set.
      await _clearAuthorization(authorization!);
      _notifyError(
        BackupRestoreProgress(BackupRestoreProgressEnum.accessDenied),
      );
    } catch (error, stackTrace) {
      if (error is DetailedApiRequestError &&
          "The user's Drive storage quota has been exceeded." ==
              error.message) {
        _notifyError(
          BackupRestoreProgress(BackupRestoreProgressEnum.storageFull),
        );
      } else {
        // A StateError indicates a programming bug rather than a network
        // issue, so it's sent to Crashlytics. Other errors are usually network
        // related and would be too noisy to report.
        if (error is StateError) {
          _log.e(
            error,
            reason: "Backup or restore state error",
            stackTrace: stackTrace,
          );
        } else {
          _log.d(
            "Unknown backup or restore error: ${error.runtimeType} - $error",
          );
        }
        _notifyError(
          BackupRestoreProgress(
            BackupRestoreProgressEnum.apiRequestError,
            apiError: error,
          ),
        );
      }
    } finally {
      watchdog?.cancel();
    }
  }

  Future<void> _backup(DriveApi drive, _StallWatchdog watchdog) async {
    var backupFiles = await _fetchFiles(drive, watchdog, backup: true);
    var imageFiles = await _imageManager.imageFiles;

    // Remove images that are already backed up. This runs on the UI thread,
    // and users can have thousands of images, so it must be a single pass.
    // Comparing every local image to every backed up image caused ANRs.
    final backedUpNames = backupFiles.images.map((e) => e.name).toSet();
    imageFiles.removeWhere((e) => backedUpNames.contains(basename(e)));

    // Read each image's length once, asynchronously; a first backup can have
    // thousands of images, and blocking reads on the UI thread cause ANRs.
    // Empty images are skipped. Google Drive's resumable upload throws a
    // StateError for 0-byte files, which would fail every backup. An empty
    // image can't be displayed or restored, so there's nothing to back up.
    final images = <({String path, int length})>[];
    for (var path in imageFiles) {
      final length = await IoWrapper.get.file(path).length();
      if (length > 0) {
        images.add((path: path, length: length));
      } else {
        _log.w("Skipping empty image: $path");
      }
    }

    // +1 for the database.
    final fileCount = images.length + 1;

    // Listing and reading images is local work, so it counts as progress.
    // This also stops an abandoned backup before it notifies progress.
    watchdog.recordProgress();
    final onProgress = _startPercentageProgress(.backingUpData, fileCount);
    void onFileUploaded() {
      watchdog.recordProgress();
      onProgress();
    }

    // Create or update the database.
    var db = IoWrapper.get.file(LocalDatabaseManager.get.databasePath());
    var newDriveDatabaseFile = File(name: _databaseName);
    var databaseMedia = Media(watchdog.watch(db.openRead()), await db.length());
    final databaseUpload = backupFiles.databaseId == null
        ? _createDriveFile(drive, newDriveDatabaseFile, databaseMedia)
        : drive.files
              .update(
                newDriveDatabaseFile,
                backupFiles.databaseId!,
                uploadOptions: ResumableUploadOptions(),
                uploadMedia: databaseMedia,
              )
              .then((_) => _log.d("Database file updated"));

    await _timeFileNetworkTask(
      "Uploading",
      "Uploaded",
      fileCount,
      Future.wait([
        databaseUpload.then((_) => onFileUploaded()),
        _forEachConcurrently(images, (image) async {
          await _createDriveFile(
            drive,
            File(name: basename(image.path)),
            Media(
              watchdog.watch(IoWrapper.get.file(image.path).openRead()),
              image.length,
            ),
          );
          onFileUploaded();
        }),
      ]),
    );
    watchdog.finish();
    UserPreferenceManager.get.setLastBackupAt(TimeManager.get.currentTimestamp);

    _notifyProgress(BackupRestoreProgress(BackupRestoreProgressEnum.finished));
    _isInProgress = false;
  }

  Future<void> _restore(DriveApi drive, _StallWatchdog watchdog) async {
    var backupFiles = await _fetchFiles(drive, watchdog, backup: false);
    if (backupFiles.databaseId == null) {
      _notifyError(
        BackupRestoreProgress(BackupRestoreProgressEnum.databaseFileNotFound),
      );
      return;
    }

    _notifyProgress(
      BackupRestoreProgress(BackupRestoreProgressEnum.restoringDatabase),
    );

    // Ensure database is cleaned up before downloading a new one.
    await LocalDatabaseManager.get.closeAndDeleteDatabase();

    // Download the database file first. If there's an error with this file,
    // there's no point in downloading images.
    await _downloadAndWriteFile(
      drive,
      watchdog,
      backupFiles.databaseId!,
      IoWrapper.get.file(LocalDatabaseManager.get.databasePath()),
    );

    // Skip images that already exist. One directory listing replaces an
    // existence check per image, which blocked the UI thread for users with
    // thousands of images. An empty image is downloaded again, since it can't
    // be displayed or backed up.
    final localNames = (await _imageManager.imageFiles).map(basename).toSet();
    final downloads = <({File driveFile, io.File localFile})>[];
    for (var file in backupFiles.images) {
      final imageFile = _imageManager.imageFile(file.name!);
      if (localNames.contains(file.name) && await imageFile.length() > 0) {
        continue;
      }
      downloads.add((driveFile: file, localFile: imageFile));
    }
    _log.d(
      "Skipping ${backupFiles.images.length - downloads.length} images that "
      "already exist",
    );

    // The database download and listing images count as progress. This also
    // stops an abandoned restore before it notifies progress.
    watchdog.recordProgress();
    final onProgress = _startPercentageProgress(
      .restoringImages,
      downloads.length,
    );
    void onImageDownloaded() {
      watchdog.recordProgress();
      onProgress();
    }

    await _timeFileNetworkTask(
      "Downloading",
      "Downloaded",
      downloads.length,
      _forEachConcurrently(downloads, (download) async {
        await _downloadAndWriteFile(
          drive,
          watchdog,
          download.driveFile.id!,
          download.localFile,
        );
        onImageDownloaded();
      }),
    );

    // Reloading data doesn't use the network, and can't be abandoned midway.
    watchdog.finish();
    _notifyProgress(
      BackupRestoreProgress(BackupRestoreProgressEnum.reloadingData),
    );

    // Reinitializing AppManager will reload data from the new database.
    await AppManager.get.init(isStartup: false);

    _notifyProgress(BackupRestoreProgress(BackupRestoreProgressEnum.finished));
    _isInProgress = false;
  }

  Future<File> _createDriveFile(DriveApi drive, File file, Media media) {
    return drive.files.create(
      file..parents = [_appDataFolderName],
      uploadOptions: ResumableUploadOptions(),
      uploadMedia: media,
    );
  }

  /// Runs [task] for each of [items], at most [_maxConcurrentTransfers] at a
  /// time. Starting thousands of uploads or downloads at once floods the UI
  /// thread. If a task throws, no new tasks are started, and the returned
  /// [Future] completes with the error once running tasks finish.
  Future<void> _forEachConcurrently<T>(
    List<T> items,
    Future<void> Function(T item) task,
  ) {
    final iterator = items.iterator;
    var hasFailed = false;

    Future<void> runNext() async {
      while (!hasFailed && iterator.moveNext()) {
        // The error isn't caught, so it reaches the caller, which reports it
        // with _notifyError.
        var isSuccessful = false;
        try {
          await task(iterator.current);
          isSuccessful = true;
        } finally {
          if (!isSuccessful) {
            hasFailed = true;
          }
        }
      }
    }

    return Future.wait(
      List.generate(min(_maxConcurrentTransfers, items.length), (_) {
        return runNext();
      }),
    );
  }

  /// Notifies that [value] has started at 0%, and returns a function to call
  /// each time one of [total] items finishes. Progress is only notified when
  /// the whole percentage changes, so thousands of images don't send
  /// thousands of events to the UI.
  void Function() _startPercentageProgress(
    BackupRestoreProgressEnum value,
    int total,
  ) {
    var finished = 0;
    var lastPercentage = 0;
    _notifyProgress(BackupRestoreProgress(value, percentage: lastPercentage));

    return () {
      final percentage = percent(++finished, total);
      if (percentage == lastPercentage) {
        return;
      }
      lastPercentage = percentage;
      _notifyProgress(BackupRestoreProgress(value, percentage: percentage));
    };
  }

  Future<void> _timeFileNetworkTask(
    String preLabel,
    String postLabel,
    int fileCount,
    Future<void> task,
  ) async {
    _log.d("$preLabel $fileCount files...");

    final now = TimeManager.get.currentTimestamp;
    await task;
    final duration = Duration(
      milliseconds: TimeManager.get.currentTimestamp - now,
    );
    _log.d("$postLabel $fileCount files in ${duration.inSeconds} seconds");
  }

  /// Fetches files on the user's Google Drive using pagination, filtered by
  /// only what we need.
  Future<_BackupFiles> _fetchFiles(
    DriveApi drive,
    _StallWatchdog watchdog, {
    required bool backup,
  }) async {
    var images = <File>[];
    String? databaseId;

    String? nextPageToken;
    while (true) {
      var fileList = await drive.files.list(
        $fields: "files(id,name),nextPageToken",
        spaces: _appDataFolderName,
        pageToken: nextPageToken,
        pageSize: _filesFetchSize,
      );

      watchdog.recordProgress();
      nextPageToken = fileList.nextPageToken;

      for (var file in fileList.files ?? []) {
        if (file.name == _databaseName) {
          databaseId = file.id;
        } else if (file.name!.contains(ImageManager.imgExtension)) {
          images.add(file);
        }
      }

      if (nextPageToken == null) {
        break;
      }
    }

    return _BackupFiles(databaseId, images);
  }

  Future<void> _downloadAndWriteFile(
    DriveApi drive,
    _StallWatchdog watchdog,
    String driveId,
    io.File outFile,
  ) async {
    var media =
        await drive.files.get(
              driveId,
              downloadOptions: DownloadOptions.fullMedia,
            )
            as Media;
    var sink = outFile.openWrite();
    var isComplete = false;
    try {
      await sink.addStream(watchdog.watch(media.stream));
      isComplete = true;
    } finally {
      await sink.close();

      // Don't leave a partial file behind; restore skips images that already
      // exist, so it would never be downloaded again.
      if (!isComplete) {
        await outFile.delete();
      }
    }
  }

  void _notifyProgress(
    BackupRestoreProgress progress, {
    bool killProcess = false,
  }) {
    if (killProcess) {
      _isInProgress = false;
    }
    _lastProgressError = progress.isError ? progress : null;
    _progressController.add(progress);
  }

  void _notifyError(BackupRestoreProgress error) =>
      _notifyProgress(error, killProcess: true);
}

class _BackupFiles {
  /// Can be null if the database hasn't yet been backed up.
  final String? databaseId;

  final List<File> images;

  _BackupFiles(this.databaseId, this.images);
}

/// Fails a backup or restore that makes no progress for a whole [timeout].
/// Progress is reported with [recordProgress], or by passing data through
/// [watch].
///
/// Progress only sets a flag, which is checked when the timer fires. Data
/// arrives in thousands of chunks, and restarting a timer for each one is
/// wasteful.
class _StallWatchdog {
  final Duration timeout;

  /// Called when progress has stalled, before [stalled] completes.
  final VoidCallback onStall;

  final _stalled = Completer<Never>();
  late Timer _timer;
  var _hasProgressed = false;

  _StallWatchdog(this.timeout, this.onStall) {
    // Marked as handled, so an unawaited stall isn't an uncaught error.
    _stalled.future.ignore();
    _timer = Timer(timeout, _onTimeout);
  }

  /// Completes with a [TimeoutException] when progress stalls; never
  /// completes otherwise.
  Future<Never> get stalled => _stalled.future;

  /// Throws if progress has already stalled, so an abandoned backup or
  /// restore stops at its next step, instead of continuing in the background
  /// while the user retries.
  void recordProgress() {
    _throwIfStalled();
    _hasProgressed = true;
  }

  /// Stops watching. Throws if progress has already stalled; call this before
  /// a step that must not run once a backup or restore is abandoned.
  void finish() {
    _throwIfStalled();
    cancel();
  }

  void cancel() => _timer.cancel();

  /// Returns [stream], recording progress each time it emits data.
  Stream<List<int>> watch(Stream<List<int>> stream) {
    return stream.map((data) {
      recordProgress();
      return data;
    });
  }

  void _onTimeout() {
    if (_hasProgressed) {
      _hasProgressed = false;
      _timer = Timer(timeout, _onTimeout);
      return;
    }
    onStall();
    _stalled.completeError(
      TimeoutException("Backup or restore stalled", timeout),
    );
  }

  void _throwIfStalled() {
    if (_stalled.isCompleted) {
      throw TimeoutException("Backup or restore was abandoned", timeout);
    }
  }
}
