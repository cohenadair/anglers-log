package com.cohenadair.anglerslog.utilities;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.webkit.MimeTypeMap;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.database.LogbookHelper;
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
import com.google.android.gms.drive.events.ChangeEvent;
import com.google.android.gms.drive.events.ChangeListener;
import com.google.android.gms.drive.metadata.CustomPropertyKey;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

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
    private static final String KEY_SYNC_DATE = "file_sync_date";
    private static final String KEY_DB_MOD_DATE = "key_last_modified";

    private static Activity mActivity;
    private static SharedPreferences mPreferences;
    private static GoogleApiClient mClient;
    private static OnSyncListener mOnSyncListener;

    /**
     * Used to keep track of sync files.
     */
    private static int mFilesAttempted = 0;
    private static int mFilesSucceeded = 0;
    private static int mFilesFailed = 0;

    public interface OnConfirmBackup {
        void confirm();
    }

    public interface OnSyncListener {
        void onFinish();
    }

    private DriveUtils() {

    }

    public static void init(Activity activity, OnSyncListener onSyncListener) {
        mActivity = activity;
        mPreferences = activity.getPreferences(Context.MODE_PRIVATE);
        mOnSyncListener = onSyncListener;
    }

    public static void setClient(GoogleApiClient client) {
        mClient = client;
    }

    public static void onConnected() {
        // listen for changes in the App Folder
        Drive.DriveApi.getAppFolder(mClient).addChangeListener(mClient, new ChangeListener() {
            @Override
            public void onChange(ChangeEvent changeEvent) {
                Log.i(TAG, "Something changed!");
            }
        });
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
     * The actual steps above can be seen in {@link #syncCallback(MetadataBuffer)} declaration.
     */
    public static void sync() {
        Drive.DriveApi.getAppFolder(mClient).listChildren(mClient).setResultCallback(getListChildrenCallback());
    }

    /**
     * The meat of the syncing process. See {@link #sync()} for full explanation.
     *
     * @param driveFiles A MetadataBuffer used for getting DriveFile objects.
     */
    private static void syncCallback(MetadataBuffer driveFiles) {
        ArrayList<File> localFiles = getLocalFiles();

        Log.d(TAG, "Files found in Drive: " + driveFiles.getCount());
        Log.d(TAG, "Files found in local storage: " + localFiles.size());

        // iterate through files found in Drive
        for (Metadata meta : driveFiles) {
            Log.d(TAG, "Found file in Drive: " + meta.getTitle());
            File localFile = metaExistsLocally(localFiles, meta);
            syncWithDrive(localFile, meta);
        }

        // remove unused photos before uploading local files
        PhotoUtils.cleanPhotos();

        // iterate through local files
        for (File file : localFiles) {
            Metadata meta = fileExistsInDrive(driveFiles, file);

            if (meta == null) {
                Log.d(TAG, "Drive file " + file.getName() + " not found, creating one.");
                mFilesAttempted++;
                copyLocalFileToDrive(file);
            }

            // if the file exists in Drive it's already up to date from the original Metadata buffer iteration
        }
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

    /**
     * Called after each file sync. Checks to see if all files are finished, prints some debug, and
     * calls the associated OnSyncListener.onFinish().
     */
    private static void checkSyncFinished() {
        // if all files are done
        if ((mFilesSucceeded + mFilesFailed) == mFilesAttempted) {
            Log.i(TAG, "Finished sync: " + mFilesSucceeded + " files succeeded, " + mFilesFailed + " files failed, " + mFilesAttempted + " files attempted.");
            mFilesAttempted = 0;
            mFilesFailed = 0;
            mFilesSucceeded = 0;
            mOnSyncListener.onFinish();
        }
    }

    /**
     * Called after each file sync is finished.
     * @param success True if the file sync was successful, false otherwise.
     */
    private static void onSingleSyncFinished(boolean success) {
        if (success)
            mFilesSucceeded++;
        else
            mFilesFailed++;
    }

    /**
     * Syncs the specified File wit the specified Drive Metadata.
     *
     * @param file The local file.
     * @param meta The Metadata of the Drive file.
     */
    private static void syncWithDrive(File file, Metadata meta) {
        Map<CustomPropertyKey, String> customProperties = meta.getCustomProperties();
        long metaModDate = Long.parseLong(customProperties.get(getPropertyKey()));

        // This is the case where the database file in Drive is newer than the database file in
        // local storage. The database file's modification date needs to be updated because it
        // is ALWAYS reset when the app starts, so the app will incorrectly think the local file
        // is newer.
        if (file != null && file.getName().equals(LogbookHelper.DATABASE_NAME)) {
            SharedPreferences prefs = mActivity.getPreferences(Context.MODE_PRIVATE);
            long lastSyncDate = prefs.getLong(KEY_DB_MOD_DATE, 0);
            long startupDate = Logbook.getDatabaseInitialDate();
            long lastModified = Logbook.getModificationDate();

            // if the database was modified since startup, leave as is
            if (lastModified > startupDate && lastModified > lastSyncDate) {
                Log.d(TAG, "Database modified since startup and last sync.");
            } else

            // if it wasn't modified, reset modification date to lasy sync
            if (file.setLastModified(lastSyncDate))
                Log.d(TAG, "Updated database modification date.");
        }

        // if the meta's associated file doesn't exist locally, create one and sync
        if (file == null) {
            Log.d(TAG, "Local file " + meta.getTitle() + " not found, creating one.");
            copyDriveFileToLocal(meta, getLocalFileFromMeta(meta));
            mFilesAttempted++;
        } else

        // if the drive file is newer than the local file, copy drive file
        if (file.lastModified() < metaModDate) {
            Log.d(TAG, "Updating local file from Drive: " + file.getName());
            copyDriveFileToLocal(meta, file);
            mFilesAttempted++;
        } else

        // if the local file is newer than the drive file, copy local file
        if (file.lastModified() > metaModDate) {
            Log.d(TAG, "Updating Drive file from local storage: " + meta.getTitle());
            updateDriveFileFromLocal(meta, file);
            mFilesAttempted++;
        } else

        // the modification dates are the same, do nothing
        {
            Log.d(TAG, "The files are the same, do nothing.");
        }
    }

    /**
     * Copies the given file to the Drive.
     *
     * @param file The local file to copy.
     */
    private static void copyLocalFileToDrive(File file) {
        Drive.DriveApi
                .newDriveContents(mClient)
                .setResultCallback(getDriveContentsCallback(file, false));
    }

    /**
     * Copies a given file associated with the specified Metadata to local storage.
     *
     * @param meta The Metadata of the file to copy.
     * @param file The location of the copied file.
     */
    private static void copyDriveFileToLocal(final Metadata meta, final File file) {
        DriveFile driveFile = Drive.DriveApi.getFile(mClient, meta.getDriveId());
        new CopyFileAsyncTask(file, true).execute(driveFile);
    }

    /**
     * Updates the specified Metadata with the contents from the specified file.
     *
     * @param meta The Metadata of the file to be updated.
     * @param file The local file to be copied to Drive.
     */
    private static void updateDriveFileFromLocal(final Metadata meta, final File file) {
        DriveFile driveFile = Drive.DriveApi.getFile(mClient, meta.getDriveId());
        new CopyFileAsyncTask(file, false).execute(driveFile);
    }

    /**
     * Checks to see if the specified File and Metadata are associated with one another.
     *
     * @param file The File object.
     * @param meta The Metadata object.
     * @return True if they are partners, false otherwise.
     */
    private static boolean fileEqualsMeta(File file, Metadata meta) {
        return !(file == null || meta == null) && file.getName().equals(meta.getTitle());
    }

    /**
     * Checks to see if the specified Metadata exists in the list of local files.
     *
     * @param localFiles The local File objects to check.
     * @param meta The Metadata to look for.
     * @return The File associated with the given Metadata, or null if it doesn't exist.
     */
    @Nullable
    private static File metaExistsLocally(ArrayList<File> localFiles, Metadata meta) {
        for (File f : localFiles)
            if (fileEqualsMeta(f, meta))
                return f;
        return null;
    }

    /**
     * Checks to see if the specified File exists in the list of Drive files.
     *
     * @param buffer The buffer containing all Drive files.
     * @param file the local file to look for.
     * @return The Metadata associated with the given File, or null if it doesn't exist.
     */
    @Nullable
    private static Metadata fileExistsInDrive(MetadataBuffer buffer, File file) {
        for (Metadata m : buffer)
            if (fileEqualsMeta(file, m))
                return m;
        return null;
    }

    /**
     * Gets a local File object from the specified Metadata.
     *
     * @param meta The Metadata object.
     * @return A File object associated with the specified Metadata.
     */
    private static File getLocalFileFromMeta(Metadata meta) {
        return meta.getFileExtension().equals(LogbookHelper.DATABASE_EXT) ?
                mActivity.getDatabasePath(LogbookHelper.DATABASE_NAME) :
                PhotoUtils.privatePhotoFile(meta.getTitle());
    }

    /**
     * Gets a ResultCallback for a DriveFolder.listChildren() call. Used for application syncing.
     * @return A ResultCallback<MetadataBufferResult>.
     */
    @NonNull
    private static ResultCallback<DriveApi.MetadataBufferResult> getListChildrenCallback() {
        return new ResultCallback<DriveApi.MetadataBufferResult>() {
            @Override
            public void onResult(DriveApi.MetadataBufferResult metadataBufferResult) {
                if (!metadataBufferResult.getStatus().isSuccess()) {
                    Log.e(TAG, "Error getting children from App Folder.");
                    return;
                }

                MetadataBuffer buffer = metadataBufferResult.getMetadataBuffer();
                syncCallback(buffer);
                buffer.release();
            }
        };
    }

    /**
     * Gets a CustomPropertyKey used to keep Drive and local files in sync.
     * @return A CustomPropertyKey object.
     */
    @NonNull
    private static CustomPropertyKey getPropertyKey() {
        return new CustomPropertyKey(KEY_SYNC_DATE, CustomPropertyKey.PRIVATE);
    }

    /**
     * Gets a ResultCallback used for a DriveApi.newFileContents() call. Used to copy a local file to
     * Drive if the Drive file doesn't already exist.
     *
     * @param toCopy The File object to be copied.
     * @param fromDriveToLocal True if transferring from Drive to local storage, false otherwise.
     * @return A ResultCallback<DriveContentsResult> used for creating new DriveContents.
     */
    @NonNull
    private static ResultCallback<DriveContentsResult> getDriveContentsCallback(final File toCopy, final boolean fromDriveToLocal) {
        return new ResultCallback<DriveContentsResult>() {
            @Override
            public void onResult(DriveContentsResult driveContentsResult) {
                if (!driveContentsResult.getStatus().isSuccess()) {
                    Log.e(TAG, "Error creating new DriveContents.");
                    return;
                }

                String fileExt = Utils.extractExtension(toCopy.getName());

                // if syncing the database file, save the last modified date so it can be referenced later
                if (fileExt.equals("db"))
                    mActivity.getPreferences(Context.MODE_PRIVATE)
                            .edit()
                            .putLong(KEY_DB_MOD_DATE, toCopy.lastModified())
                            .apply();

                String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExt);
                MetadataChangeSet changeSet = new MetadataChangeSet.Builder()
                        .setTitle(toCopy.getName())
                        .setMimeType(mimeType)
                        .setCustomProperty(getPropertyKey(), Long.toString(toCopy.lastModified()))
                        .build();

                Drive.DriveApi
                        .getAppFolder(mClient)
                        .createFile(mClient, changeSet, driveContentsResult.getDriveContents())
                        .setResultCallback(getDriveFileCallback(toCopy, fromDriveToLocal));
            }
        };
    }

    /**
     * Gets a ResultCallback used for a DriveApi.createFile() call. Used to copy a local file to
     * Drive if the Drive file doesn't already exist.
     *
     * @param toCopy The File object to be copied.
     * @param fromDriveToLocal True if transferring from Drive to local storage, false otherwise.
     * @return A ResultCallback<DriveFileResult> used for creating a new DriveFile.
     */
    @NonNull
    private static ResultCallback<DriveFileResult> getDriveFileCallback(final File toCopy, final boolean fromDriveToLocal) {
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

    /**
     * An AsyncTask subclass used to copy files to and from Drive.
     */
    private static class CopyFileAsyncTask extends AsyncTask<DriveFile, Void, Boolean> {

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

            Log.d(TAG, "Attempted to copy file: " + mFileToCopy.getName() + ", result: " + result);

            if (driveContents.getMode() == DriveFile.MODE_WRITE_ONLY)
                driveContents.commit(mClient, null).setResultCallback(new ResultCallback<com.google.android.gms.common.api.Status>() {
                    @Override
                    public void onResult(com.google.android.gms.common.api.Status status) {
                        if (!status.getStatus().isSuccess()) {
                            Log.e(TAG, "Error committing DriveContent.");
                            return;
                        }

                        Log.d(TAG, "Successfully committed DriveContents.");
                        onSingleSyncFinished(true);
                        checkSyncFinished();
                    }
                });
            else {
                onSingleSyncFinished(result);
                checkSyncFinished();
            }

            return result;
        }

        /**
         * Copies a local file to Drive.
         *
         * @param localFile The local file to copy.
         * @param driveContents The DriveContents to be written to.
         * @return True if the copy was successful, false otherwise.
         * @throws IOException
         */
        private boolean fromLocalToDrive(File localFile, DriveContents driveContents) throws IOException {
            FileUtils.copyFile(localFile, driveContents.getOutputStream());
            return true;
        }

        /**
         * Copies a Drive file to local storage.
         *
         * @param localFile The location of the copied file.
         * @param driveContents The DriveContents to be copied.
         * @return True if the copy was successful, false otherwise.
         * @throws IOException
         */
        private boolean fromDriveToLocal(File localFile, DriveContents driveContents) throws IOException {
            FileUtils.copyInputStreamToFile(driveContents.getInputStream(), localFile);
            return true;
        }
    }

}
