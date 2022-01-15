import 'dart:async';
import 'dart:io' as io;

import 'package:collection/collection.dart' show IterableExtension;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/number_utils.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'local_database_manager.dart';
import 'log.dart';
import 'time_manager.dart';
import 'wrappers/google_sign_in_wrapper.dart';
import 'wrappers/io_wrapper.dart';

enum BackupAndRestoreAuthState {
  signedOut,
  signedIn,
  error,
}

enum BackupAndRestoreProgressEnum {
  // Errors
  authClientError,
  createFolderError,
  folderNotFound,
  apiRequestError,
  databaseFileNotFound,

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

class BackupAndRestoreProgress {
  final BackupAndRestoreProgressEnum value;
  final Object? apiError;
  final int? percentage;

  BackupAndRestoreProgress(
    this.value, {
    this.apiError,
    this.percentage,
  });
}

class BackupAndRestoreManager {
  static BackupAndRestoreManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).backupAndRestoreManager;

  static const _folderName = "AnglersLogBackup";
  static const _databaseName = "anglerslog.db";
  static const _mimeTypeFolder = "application/vnd.google-apps.folder";

  // Maximum size per
  // https://developers.google.com/drive/api/v3/reference/files/list.
  static const _filesFetchSize = 1000;

  final _log = const Log("BackupManager");
  final _authController =
      StreamController<BackupAndRestoreAuthState>.broadcast();
  final _progressController =
      StreamController<BackupAndRestoreProgress>.broadcast();

  final AppManager _appManager;

  /// True if a backup or restore is in progress; false otherwise.
  var _isInProgress = false;

  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;

  GoogleSignInWrapper get _googleSignInWrapper =>
      _appManager.googleSignInWrapper;

  ImageManager get _imageManager => _appManager.imageManager;

  IoWrapper get _ioWrapper => _appManager.ioWrapper;

  LocalDatabaseManager get _localDatabaseManager =>
      _appManager.localDatabaseManager;

  TimeManager get _timeManager => _appManager.timeManager;

  UserPreferenceManager get _userPreferenceManager =>
      _appManager.userPreferenceManager;

  BackupAndRestoreManager(this._appManager);

  /// A [Stream] that fires events when a user's authentication changes.
  Stream<BackupAndRestoreAuthState> get authStream => _authController.stream;

  /// A [Stream] that fires events when the progress of a backup or restore
  /// changes.
  Stream<BackupAndRestoreProgress> get progressStream =>
      _progressController.stream;

  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => currentUser != null;

  bool get isInProgress => _isInProgress;

  int? get lastBackupAt => _userPreferenceManager.lastBackupAt;

  Future<void> initialize() async {
    _userPreferenceManager.stream.listen((_) {
      if (_userPreferenceManager.didSetupBackup) {
        _authenticateUser();
      } else {
        _disconnectAccount();
      }
    });

    if (!_userPreferenceManager.didSetupBackup) {
      _log.d("Skipping backup init; user hasn't setup backup");
      return;
    }

    _log.d("Authenticating user for data backup and restore");
    await _authenticateUser();
  }

  Future<void> _authenticateUser() async {
    if (_currentUser != null) {
      return;
    }

    _googleSignIn = _googleSignInWrapper.newInstance([DriveApi.driveScope]);

    try {
      _currentUser =
          await _googleSignIn?.signInSilently(reAuthenticate: true) ??
              await _googleSignIn?.signIn();
      _log.d("Current user: ${_currentUser?.email}");
    } catch (error) {
      _log.e("Sign in error: $error");
      _authController.add(BackupAndRestoreAuthState.error);
    }

    if (_currentUser == null) {
      // Sign in failed.
      _userPreferenceManager.setDidSetupBackup(false);
    } else {
      _authController.add(BackupAndRestoreAuthState.signedIn);
    }
  }

  Future<void> _disconnectAccount() async {
    if (_currentUser == null) {
      return;
    }
    _currentUser = await _googleSignIn?.disconnect();
    _authController.add(BackupAndRestoreAuthState.signedOut);
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
      _notifyProgress(BackupAndRestoreProgress(
          BackupAndRestoreProgressEnum.authenticating));

      var authClient = await _googleSignIn?.authenticatedClient();
      if (authClient == null) {
        _notifyError(BackupAndRestoreProgress(
            BackupAndRestoreProgressEnum.authClientError));
        return;
      }

      _notifyProgress(
          BackupAndRestoreProgress(BackupAndRestoreProgressEnum.fetchingFiles));

      var drive = DriveApi(authClient);
      if (backup) {
        return await _backup(drive);
      } else {
        return await _restore(drive);
      }
    } catch (error) {
      _log.e("Unknown backup or restore error: $error");

      _notifyError(BackupAndRestoreProgress(
        BackupAndRestoreProgressEnum.apiRequestError,
        apiError: error,
      ));
    }
  }

  Future<void> _backup(DriveApi drive) async {
    var backupFiles = await _fetchFiles(drive, backup: true);
    if (backupFiles == null) {
      return;
    }

    var imageFiles = await _imageManager.imageFiles;

    // Remove images that are already backed up.
    for (var file in backupFiles.images) {
      imageFiles.removeWhere((e) => e.contains(basename(file.name!)));
    }

    // Create or update the database file.
    var db = _ioWrapper.file(_localDatabaseManager.databasePath());
    var newDriveDatabaseFile = File(name: _databaseName);
    var databaseMedia = Media(db.openRead(), db.lengthSync());

    _notifyProgress(BackupAndRestoreProgress(
        BackupAndRestoreProgressEnum.backingUpDatabase));

    if (backupFiles.databaseId == null) {
      _log.d("Creating database file");

      await drive.files.create(
        newDriveDatabaseFile..parents = [backupFiles.folderId],
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
      _notifyProgress(BackupAndRestoreProgress(
        BackupAndRestoreProgressEnum.backingUpImages,
        percentage: percent(numberOfImagesUploaded, imageFiles.length),
      ));

      var localFile = _ioWrapper.file(image);

      await drive.files.create(
        File(
          name: basename(image),
          parents: [backupFiles.folderId],
        ),
        uploadMedia: Media(localFile.openRead(), localFile.lengthSync()),
      );

      _log.d("Uploaded image ${basename(image)}");
      numberOfImagesUploaded++;
    }

    _userPreferenceManager.setLastBackupAt(_timeManager.msSinceEpoch);

    _notifyProgress(
        BackupAndRestoreProgress(BackupAndRestoreProgressEnum.finished));
  }

  Future<void> _restore(DriveApi drive) async {
    var backupFiles = await _fetchFiles(drive, backup: false);
    if (backupFiles == null) {
      return;
    }

    if (backupFiles.databaseId == null) {
      _notifyError(BackupAndRestoreProgress(
          BackupAndRestoreProgressEnum.databaseFileNotFound));
      return;
    }

    _notifyProgress(BackupAndRestoreProgress(
        BackupAndRestoreProgressEnum.restoringDatabase));

    // Download the database file first. If there's an error with this file,
    // there's no point in downloading images.
    await _downloadAndWriteFile(drive, backupFiles.databaseId!,
        _ioWrapper.file(_localDatabaseManager.databasePath()));

    var numberOfImagesDownloaded = 0;
    for (var file in backupFiles.images) {
      _notifyProgress(BackupAndRestoreProgress(
        BackupAndRestoreProgressEnum.restoringImages,
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
    }

    _notifyProgress(
        BackupAndRestoreProgress(BackupAndRestoreProgressEnum.reloadingData));

    // Reinitializing AppManager will reload data from the new database.
    await _appManager.initialize(isStartup: false);

    _notifyProgress(
        BackupAndRestoreProgress(BackupAndRestoreProgressEnum.finished));
  }

  /// Fetches files on the user's Google Drive using pagination, filtered by
  /// only what we need.
  Future<_BackupFiles?> _fetchFiles(
    DriveApi drive, {
    required bool backup,
  }) async {
    // Fetch backup folder.
    var folders = await drive.files.list(
      q: "mimeType = '$_mimeTypeFolder' "
          "and name = '$_folderName' "
          "and trashed = false",
    );

    // Exit early if we're trying to restore and the backup folder doesn't
    // exist.
    if (!backup && (folders.files == null || folders.files!.isEmpty)) {
      _notifyError(BackupAndRestoreProgress(
          BackupAndRestoreProgressEnum.folderNotFound));
      return null;
    }

    if (backup) {
      _notifyProgress(BackupAndRestoreProgress(
          BackupAndRestoreProgressEnum.creatingFolder));
    }

    // Fetched folders should only ever have one value. If not, use the first.
    // If the folder doesn't exist, create it.
    var folderId = folders.files?.firstOrNull?.id ??
        (await drive.files.create(File()
              ..name = _folderName
              ..mimeType = _mimeTypeFolder))
            .id;

    if (folderId == null) {
      _notifyError(BackupAndRestoreProgress(
          BackupAndRestoreProgressEnum.createFolderError));
      return null;
    }

    var images = <File>[];
    String? databaseId;

    String? nextPageToken;
    while (true) {
      var fileList = await drive.files.list(
        $fields: "files(id,name),nextPageToken",
        pageToken: nextPageToken,
        pageSize: _filesFetchSize,
        q: "'$folderId' in parents "
            "and trashed = false "
            "and name != ''",
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

    return _BackupFiles(folderId, databaseId, images);
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
    BackupAndRestoreProgress progress, {
    bool killProcess = false,
  }) {
    if (killProcess) {
      _isInProgress = false;
    }
    _progressController.add(progress);
  }

  void _notifyError(BackupAndRestoreProgress error) =>
      _notifyProgress(error, killProcess: true);
}

class _BackupFiles {
  final String folderId;

  /// Can be null if the database hasn't yet been backed up.
  final String? databaseId;

  final List<File> images;

  _BackupFiles(this.folderId, this.databaseId, this.images);
}
