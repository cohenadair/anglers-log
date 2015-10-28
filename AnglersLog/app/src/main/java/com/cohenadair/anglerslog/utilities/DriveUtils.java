package com.cohenadair.anglerslog.utilities;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.webkit.MimeTypeMap;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.drive.Drive;
import com.google.android.gms.drive.DriveApi;
import com.google.android.gms.drive.DriveContents;
import com.google.android.gms.drive.DriveFile;
import com.google.android.gms.drive.Metadata;
import com.google.android.gms.drive.MetadataBuffer;
import com.google.android.gms.drive.MetadataChangeSet;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;

import static com.google.android.gms.drive.DriveApi.DriveContentsResult;
import static com.google.android.gms.drive.DriveFolder.DriveFileResult;

/**
 * DriveUtils is a utility class for interacting with the Google Drive API. This class requires
 * the <a href="https://commons.apache.org/proper/commons-io/apidocs/org/apache/commons/io/FileUtils.html">Apache Commons FileUtil.java</a> library.
 * 
 * Created by Cohen Adair on 2015-10-27.
 */
public class DriveUtils {

    private static final String TAG = "DriveUtils";
    private static final String KEY_FIRST_RUN = "is_first_run";
    private static final String KEY_BACKUP_ENABLED = "google_backup_enabled";

    private static Activity mActivity;
    private static SharedPreferences mPreferences;
    private static GoogleApiClient mClient;

    public interface OnConfirmBackup {
        void confirm();
    }

    private DriveUtils() {

    }

    public static void init(Activity activity) {
        mActivity = activity;
        mPreferences = activity.getPreferences(Context.MODE_PRIVATE);
    }

    public static void setClient(GoogleApiClient client) {
        mClient = client;
    }

    /**
     * Asks the user if they want to use Google to backup the application's files if it's their
     * first time opening the application. Runs the specified OnConfirmBackup interface if the user
     * has enabled backup.
     */
    public static void requestBackupEnabled(final DriveUtils.OnConfirmBackup onConfirm) {
        boolean isFirstRun = mPreferences.getBoolean(KEY_FIRST_RUN, true);

        if (isFirstRun) {
            mPreferences.edit().putBoolean(KEY_FIRST_RUN, false).apply();

            // ask the user if they want to use Google backup
            new AlertDialog.Builder(mActivity)
                    .setTitle(R.string.backup_alert_title)
                    .setMessage(R.string.backup_alert_msg)
                    .setNegativeButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            disableBackup();
                            dialog.cancel();
                        }
                    })
                    .setPositiveButton(R.string.backup_alert_confirm, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            enableBackup();
                            onConfirm.confirm();
                        }
                    })
                    .show();
        } else
            if (isBackupEnabled())
                onConfirm.confirm();
    }

    public static boolean isBackupEnabled() {
        return mPreferences.getBoolean(KEY_BACKUP_ENABLED, false);
    }

    public static void enableBackup() {
        mPreferences.edit().putBoolean(KEY_BACKUP_ENABLED, true).apply();
    }

    public static void disableBackup() {
        mPreferences.edit().putBoolean(KEY_BACKUP_ENABLED, false).apply();
    }

    /**
     * Syncs local and Drive files by:
     * 1. Reading in all files located in Drive. Cases:
     *      * If the drive file is newer than the local file, or the local file doesn't exist, the
     *        Drive file is copied to local storage.
     *      * If the local file is newer than the Drive file, the local file is copied to Drive.
     *      * If the modification dates on the files are equal, nothing happens.
     * 2. Reading in all files in local storage. Cases:
     *      * If the file doesn't exist in Drive, the local file is copied to Drive.
     *      * All other cases are covered in step 1.
     *
     * Each Drive file's Metadata.getTitle() is equal to the associated local file's name for easy
     * recognition.
     *
     * The actual steps above can be seen in {@link #mListChildrenCallback} declaration.
     */
    public static void sync() {
        Drive.DriveApi
                .getAppFolder(mClient)
                .listChildren(mClient)
                .setResultCallback(mListChildrenCallback);
    }

    /**
     * Gets all the local files that are to be synced with Google Drive.
     * @return An ArrayList of File objects.
     */
    private static ArrayList<File> getLocalFiles() {
        ArrayList<File> files = new ArrayList<>();

        files.add(Logbook.getDatabaseFile());
        files.addAll(Arrays.asList(PhotoUtils.privatePhotoDirectory().listFiles()));

        return files;
    }

    private static boolean fileEqualsMeta(File file, Metadata meta) {
        return file.getName().equals(meta.getTitle());
    }

    private static final ResultCallback<DriveApi.MetadataBufferResult> mListChildrenCallback = new ResultCallback<DriveApi.MetadataBufferResult>() {
        @Override
        public void onResult(DriveApi.MetadataBufferResult metadataBufferResult) {
            if (!metadataBufferResult.getStatus().isSuccess()) {
                Log.e(TAG, "Error getting children from App Folder.");
                return;
            }

            ArrayList<File> localFiles = getLocalFiles();
            MetadataBuffer buffer = metadataBufferResult.getMetadataBuffer();

            // iterate through files found in Drive
            for (Metadata meta : buffer)
                for (File file : localFiles)
                    if (fileEqualsMeta(file, meta)) {
                        // if the local file exists in drive

                        if (file.lastModified() < meta.getModifiedDate().getTime()) {
                            // the drive file is newer than the local file, copy drive file
                        } else if (file.lastModified() > meta.getModifiedDate().getTime()) {
                            // the local file is newer than the drive file, copy local file
                        } else {
                            // the modification dates are the same, do nothing
                        }
                    } else {
                        // if the file doesn't exist in drive, copy it to local storage
                    }

            // remove unused photos before uploading local files
            PhotoUtils.cleanPhotos();

            // iterate through local files
            for (File file : localFiles)
                for (Metadata meta : buffer)
                    if (fileEqualsMeta(file, meta)) {
                        // if the local file exists in drive, do nothing, it's already in sync
                    } else {
                        // if the local file doesn't exist in drive, copy it to drive
                    }

            buffer.release();
        }
    };

    @NonNull
    private ResultCallback<DriveContentsResult> getDriveContentsCallback(final String fileExt, final File toCopy, final boolean fromDriveToLocal) {
        return new ResultCallback<DriveContentsResult>() {
            @Override
            public void onResult(DriveContentsResult driveContentsResult) {
                if (!driveContentsResult.getStatus().isSuccess()) {
                    Log.e(TAG, "Error creating new DriveContents.");
                    return;
                }

                String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExt);
                MetadataChangeSet changeSet = new MetadataChangeSet.Builder()
                        .setTitle(toCopy.getName())
                        .setMimeType(mimeType)
                        .build();

                Drive.DriveApi
                        .getAppFolder(mClient)
                        .createFile(mClient, changeSet, driveContentsResult.getDriveContents())
                        .setResultCallback(getDriveFileCallback(toCopy, fromDriveToLocal));
            }
        };
    }

    @NonNull
    private ResultCallback<DriveFileResult> getDriveFileCallback(final File toCopy, final boolean fromDriveToLocal) {
        return new ResultCallback<DriveFileResult>() {
            @Override
            public void onResult(DriveFileResult driveFileResult) {
                if (!driveFileResult.getStatus().isSuccess()) {
                    Log.e(TAG, "Error creating DriveFile.");
                    return;
                }

                DriveFile driveFile = driveFileResult.getDriveFile();
                new CopyFileAsyncTask(toCopy, fromDriveToLocal).execute(driveFile);
            }
        };
    }

    private class CopyFileAsyncTask extends AsyncTask<DriveFile, Void, Boolean> {

        private static final String TAG = "CopyFilesAsyncTask";

        private File mFileToCopy;
        private boolean mFromDriveToLocal;

        public CopyFileAsyncTask(File toCopy, boolean fromDriveToLocal) {
            super();
            mFileToCopy = toCopy;
            mFromDriveToLocal = fromDriveToLocal;
        }

        @Override
        protected Boolean doInBackground(DriveFile... params) {
            Boolean result = true;
            DriveFile driveFile = params[0];

            int openMode = mFromDriveToLocal ? DriveFile.MODE_READ_ONLY : DriveFile.MODE_WRITE_ONLY;
            DriveContentsResult driveContentsResult = driveFile.open(mClient, openMode, null).await();
            if (!driveContentsResult.getStatus().isSuccess()) {
                Log.e(TAG, "Error opening DriveFile.");
                return false;
            }

            DriveContents driveContents = driveContentsResult.getDriveContents();

            try {
                result = mFromDriveToLocal ? fromDriveToLocal(mFileToCopy, driveContents) : fromLocalToDrive(mFileToCopy, driveContents);
            } catch (IOException e) {
                Log.e(TAG, "Error copying file: " + mFileToCopy.getName());
                e.printStackTrace();
            }

            return result;
        }

        private boolean fromLocalToDrive(File localFile, DriveContents driveContents) throws IOException {
            return FileUtils.copyFile(localFile, driveContents.getOutputStream()) != localFile.length();
        }

        private boolean fromDriveToLocal(File localFile, DriveContents driveContents) throws IOException {
            FileUtils.copyInputStreamToFile(driveContents.getInputStream(), localFile);
            return localFile.exists();
        }
    }

}
