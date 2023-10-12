import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/number_utils.dart';
import 'package:mobile/wrappers/drive_api_wrapper.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'bait_manager.dart';
import 'local_database_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'time_manager.dart';
import 'wrappers/google_sign_in_wrapper.dart';
import 'wrappers/io_wrapper.dart';

enum BackupRestoreAuthState {
  signedOut,
  signedIn,
  error,
  networkError,
}

enum BackupRestoreProgressEnum {
  // Errors
  authClientError,
  createFolderError,
  folderNotFound,
  apiRequestError,
  databaseFileNotFound,
  accessDenied, // Forwarded from Drive API

  // Progress states
  authenticating,
  fetchingFiles,
  creatingFolder,
  backingUpDatabase,
  backingUpImages,
  restoringDatabase,
  restoringImages,
  reloadingData,
  finished,
}

class BackupRestoreProgress {
  final BackupRestoreProgressEnum value;
  final Object? apiError;
  final int? percentage;

  BackupRestoreProgress(
    this.value, {
    this.apiError,
    this.percentage,
  });

  String get percentageString => percentage == null ? "" : " ($percentage%)";
}

class BackupRestoreManager {
  static BackupRestoreManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).backupRestoreManager;

  static const _databaseName = "anglerslog.db";
  static const _appDataFolderName = "appDataFolder";

  // Maximum size per
  // https://developers.google.com/drive/api/v3/reference/files/list.
  static const _filesFetchSize = 1000;

  /// Rate limit how often automatic backups are made.
  static const _autoBackupInterval = Duration.millisecondsPerMinute * 5;

  final _log = const Log("BackupRestoreManager");
  final _authController = StreamController<BackupRestoreAuthState>.broadcast();
  final _progressController =
      StreamController<BackupRestoreProgress>.broadcast();

  final AppManager _appManager;

  // Keep reference to listeners so it isn't added multiple times.
  late final EntityListener<Catch> _catchManagerListener;
  late final EntityListener<Trip> _tripManagerListener;
  late final EntityListener<Bait> _baitManagerListener;
  late final EntityListener<FishingSpot> _fishingSpotManagerListener;

  /// True if a backup or restore is in progress; false otherwise.
  var _isInProgress = false;

  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;

  CatchManager get _catchManager => _appManager.catchManager;

  BaitManager get _baitManager => _appManager.baitManager;

  DriveApiWrapper get _driveApiWrapper => _appManager.driveApiWrapper;

  FishingSpotManager get _fishingSpotManager => _appManager.fishingSpotManager;

  GoogleSignInWrapper get _googleSignInWrapper =>
      _appManager.googleSignInWrapper;

  ImageManager get _imageManager => _appManager.imageManager;

  IoWrapper get _ioWrapper => _appManager.ioWrapper;

  LocalDatabaseManager get _localDatabaseManager =>
      _appManager.localDatabaseManager;

  SubscriptionManager get _subscriptionManager =>
      _appManager.subscriptionManager;

  TimeManager get _timeManager => _appManager.timeManager;

  TripManager get _tripManager => _appManager.tripManager;

  UserPreferenceManager get _userPreferenceManager =>
      _appManager.userPreferenceManager;

  BackupRestoreManager(this._appManager) {
    _catchManagerListener = _createEntityListener<Catch>();
    _tripManagerListener = _createEntityListener<Trip>();
    _baitManagerListener = _createEntityListener<Bait>();
    _fishingSpotManagerListener = _createEntityListener<FishingSpot>();
  }

  /// A [Stream] that fires events when a user's authentication changes.
  Stream<BackupRestoreAuthState> get authStream => _authController.stream;

  /// A [Stream] that fires events when the progress of a backup or restore
  /// changes.
  Stream<BackupRestoreProgress> get progressStream =>
      _progressController.stream;

  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => currentUser != null;

  bool get isInProgress => _isInProgress;

  int? get lastBackupAt => _userPreferenceManager.lastBackupAt;

  Future<void> initialize() async {
    _userPreferenceManager.stream.listen((_) {
      if (_userPreferenceManager.didSetupBackup) {
        _authenticateAndSetupAutoBackup();
      } else {
        _disconnectAccount();
      }
    });

    if (!_userPreferenceManager.didSetupBackup) {
      _log.d("Skipping backup init; user hasn't setup backup");
      return;
    }

    _log.d("Authenticating user for data backup and restore");
    await _authenticateAndSetupAutoBackup();
  }

  EntityListener<T> _createEntityListener<T>() {
    return EntityListener<T>(
      onAdd: (_) => _autoBackupIfNeeded(),
      onDelete: (_) => _autoBackupIfNeeded(),
      onUpdate: (_) => _autoBackupIfNeeded(),
    );
  }

  Future<void> _authenticateAndSetupAutoBackup() async {
    await _authenticateUser();
    _catchManager.listen(_catchManagerListener);
    _tripManager.listen(_tripManagerListener);
    _baitManager.listen(_baitManagerListener);
    _fishingSpotManager.listen(_fishingSpotManagerListener);
  }

  Future<void> _authenticateUser() async {
    if (_currentUser != null) {
      return;
    }

    _googleSignIn =
        _googleSignInWrapper.newInstance([DriveApi.driveAppdataScope]);

    try {
      _currentUser =
          await _googleSignIn?.signInSilently(reAuthenticate: true) ??
              await _googleSignIn?.signIn();
      _log.d("Current user: ${_currentUser?.email}");
    } catch (error) {
      if (error is PlatformException && error.details == "access_denied") {
        // User didn't grant permissions, notify that we're still signed out.
        _authController.add(BackupRestoreAuthState.signedOut);
      } else if (error is PlatformException &&
          error.code == GoogleSignIn.kNetworkError) {
        _authController.add(BackupRestoreAuthState.networkError);
      } else if (error is PlatformException &&
          error.code == GoogleSignIn.kSignInFailedError) {
        // Unknown error from SDK, don't log an error to Firebase.
        _authController.add(BackupRestoreAuthState.error);
      } else {
        _log.e(StackTrace.current, "Sign in error: $error");
        _authController.add(BackupRestoreAuthState.error);
      }
    }

    if (_currentUser == null) {
      // Sign in failed.
      _userPreferenceManager.setDidSetupBackup(false);
    } else {
      _authController.add(BackupRestoreAuthState.signedIn);
      _userPreferenceManager.setUserEmail(_currentUser!.email);
    }
  }

  Future<void> _disconnectAccount() async {
    if (_currentUser == null) {
      return;
    }
    _currentUser = await _googleSignIn?.disconnect();
    _authController.add(BackupRestoreAuthState.signedOut);
    _userPreferenceManager.setUserEmail(null);
  }

  Future<void> _autoBackupIfNeeded() async {
    if (_subscriptionManager.isFree ||
        !isSignedIn ||
        !_userPreferenceManager.autoBackup ||
        !(await _ioWrapper.isConnected())) {
      return;
    }

    var lastBackupAt = _userPreferenceManager.lastBackupAt;
    if (lastBackupAt != null &&
        _timeManager.currentTimestamp - lastBackupAt < _autoBackupInterval) {
      _log.d("Last backup was < interval, skipping...");
      return;
    }

    await backup();
  }

  Future<void> backup() async {
    await _backupOrRestore(backup: true);
  }

  Future<void> restore() async {
    await _backupOrRestore(backup: false);
  }

  Future<void> _backupOrRestore({required bool backup}) async {
    if (_isInProgress) {
      return;
    }

    try {
      _isInProgress = true;

      _notifyProgress(
          BackupRestoreProgress(BackupRestoreProgressEnum.authenticating));

      var authClient =
          await _googleSignInWrapper.authenticatedClient(_googleSignIn);
      if (authClient == null) {
        _notifyError(
            BackupRestoreProgress(BackupRestoreProgressEnum.authClientError));
        return;
      }

      _notifyProgress(
          BackupRestoreProgress(BackupRestoreProgressEnum.fetchingFiles));

      var drive = _driveApiWrapper.newInstance(authClient);
      if (backup) {
        return await _backup(drive);
      } else {
        return await _restore(drive);
      }
    } on AccessDeniedException catch (_) {
      _notifyError(
          BackupRestoreProgress(BackupRestoreProgressEnum.accessDenied));
    } catch (error) {
      _log.d("Unknown backup or restore error: ${error.runtimeType} - $error");

      _notifyError(BackupRestoreProgress(
        BackupRestoreProgressEnum.apiRequestError,
        apiError: error,
      ));
    }
  }

  Future<void> _backup(DriveApi drive) async {
    var backupFiles = await _fetchFiles(drive, backup: true);
    var imageFiles = await _imageManager.imageFiles;

    // Remove images that are already backed up.
    for (var file in backupFiles.images) {
      imageFiles.removeWhere((e) => e.contains(basename(file.name!)));
    }

    // Create or update the database file.
    var db = _ioWrapper.file(_localDatabaseManager.databasePath());
    var newDriveDatabaseFile = File(name: _databaseName);
    var databaseMedia = Media(db.openRead(), db.lengthSync());

    _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.backingUpDatabase));

    if (backupFiles.databaseId == null) {
      _log.d("Creating database file");

      await drive.files.create(
        newDriveDatabaseFile..parents = [_appDataFolderName],
        uploadMedia: databaseMedia,
      );
    } else {
      _log.d("Updating database file");

      await drive.files.update(
        newDriveDatabaseFile,
        backupFiles.databaseId!,
        uploadMedia: databaseMedia,
      );
    }

    // Upload images.
    _log.d("Images to upload: ${imageFiles.length}");

    var numberOfImagesUploaded = 0;
    for (var image in imageFiles) {
      _notifyProgress(BackupRestoreProgress(
        BackupRestoreProgressEnum.backingUpImages,
        percentage: percent(numberOfImagesUploaded, imageFiles.length),
      ));

      var localFile = _ioWrapper.file(image);

      await drive.files.create(
        File(
          name: basename(image),
          parents: [_appDataFolderName],
        ),
        uploadMedia: Media(localFile.openRead(), localFile.lengthSync()),
      );

      _log.d("Uploaded image ${basename(image)}");
      numberOfImagesUploaded++;
    }

    _userPreferenceManager.setLastBackupAt(_timeManager.currentTimestamp);

    _notifyProgress(BackupRestoreProgress(BackupRestoreProgressEnum.finished));
    _isInProgress = false;
  }

  Future<void> _restore(DriveApi drive) async {
    var backupFiles = await _fetchFiles(drive, backup: false);
    if (backupFiles.databaseId == null) {
      _notifyError(BackupRestoreProgress(
          BackupRestoreProgressEnum.databaseFileNotFound));
      return;
    }

    _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.restoringDatabase));

    // Ensure database is cleaned up before downloading a new one.
    await _localDatabaseManager.closeAndDeleteDatabase();

    // Download the database file first. If there's an error with this file,
    // there's no point in downloading images.
    await _downloadAndWriteFile(drive, backupFiles.databaseId!,
        _ioWrapper.file(_localDatabaseManager.databasePath()));

    var numberOfImagesDownloaded = 0;
    for (var file in backupFiles.images) {
      _notifyProgress(BackupRestoreProgress(
        BackupRestoreProgressEnum.restoringImages,
        percentage:
            percent(numberOfImagesDownloaded, backupFiles.images.length),
      ));

      var imageFile = _imageManager.imageFile(file.name!);

      // If the image file already exists, skip downloading it.
      if (imageFile.existsSync()) {
        _log.d("Image ${file.name} already exists, skipping restore...");
        continue;
      }

      _log.d("Downloading image: ${file.name}");
      await _downloadAndWriteFile(drive, file.id!, imageFile);

      numberOfImagesDownloaded++;
    }

    _notifyProgress(
        BackupRestoreProgress(BackupRestoreProgressEnum.reloadingData));

    // Reinitializing AppManager will reload data from the new database.
    await _appManager.initialize(isStartup: false);

    _notifyProgress(BackupRestoreProgress(BackupRestoreProgressEnum.finished));
    _isInProgress = false;
  }

  /// Fetches files on the user's Google Drive using pagination, filtered by
  /// only what we need.
  Future<_BackupFiles> _fetchFiles(
    DriveApi drive, {
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
      DriveApi drive, String driveId, io.File outFile) async {
    var media = await drive.files.get(
      driveId,
      downloadOptions: DownloadOptions.fullMedia,
    ) as Media;
    await outFile.openWrite().addStream(media.stream);
  }

  void _notifyProgress(
    BackupRestoreProgress progress, {
    bool killProcess = false,
  }) {
    if (killProcess) {
      _isInProgress = false;
    }
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
