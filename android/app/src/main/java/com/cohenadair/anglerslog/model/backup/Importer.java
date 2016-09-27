package com.cohenadair.anglerslog.model.backup;

import android.content.ContentResolver;
import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;
import android.webkit.MimeTypeMap;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;

import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * The Importer class is used to import data from a given {@link Uri}. In this case the {@link Uri}
 * must be pointing to a ZIP archive.
 *
 * @author Cohen Adair
 */
public class Importer {

    private static final String TAG = "Importer";

    private enum Error {
        ERROR_URI_NOT_FOUND(0, "File not found"),
        ERROR_ZIP_CLOSE(1, "Error closing file"),
        ERROR_ZIP_ITERATE(2, "Error extracting file"),
        ERROR_JSON_PARSE(3, "Error reading data file"),
        ERROR_JSON_READ(4, "Invalid data format"),
        ERROR_IMAGE_IMPORT(5, "Error importing photos"),
        ERROR_INVALID_FILE_EXT(6, "Not a .zip file");

        private final int mId;
        private final String mMsg;

        Error(int id, String msg) {
            mId = id;
            mMsg = msg;
        }

        public String getMessage() {
            return mMsg + " (Error no. " + mId + ")";
        }
    }

    private static ContentResolver mContentResolver;
    private static Uri mUri;
    private static OnProgressListener mCallbacks;
    private static Handler mHandler;

    /**
     * Used to determine UI behavior during different times in the importing process.
     */
    public interface OnProgressListener {
        void onFinish();
        void onError(String errorMsg);
    }

    /**
     * Takes a given {@link Uri} of a zip archive and imports its data to the application's
     * Logbook. This method should always be called after some sort of UI interaction, such as a
     * button click.
     *
     * @param uri The Uri of the zip archive.
     * @param onProgress Callbacks for importing progress.
     */
    public static void importFromUri(final Context context, Uri uri, OnProgressListener onProgress) {
        mContentResolver = context.getContentResolver();
        mUri = uri;
        mCallbacks = onProgress;
        mHandler = new Handler();

        String fileExt = MimeTypeMap.getSingleton().getExtensionFromMimeType(mContentResolver.getType(uri));
        Log.d("Importer", "File extension: " + fileExt);

        if (fileExt != null && fileExt.equals(Utils.FILE_EXTENSION_ZIP)) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    Logbook.reset(context, false);
                    importData(context);
                }
            }).start();
        } else {
            error(Error.ERROR_INVALID_FILE_EXT);
        }
    }

    /**
     * Handles all importing using the class's {@link #mUri} object. This method should always be
     * run in a background thread.
     */
    private static void importData(Context context) {
        InputStream is;

        try {
            is = mContentResolver.openInputStream(mUri);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            error(Error.ERROR_URI_NOT_FOUND);
            return;
        }

        if (is == null)
            return;

        ZipInputStream zip = new ZipInputStream(is);
        ZipEntry entry;

        try {
            while ((entry = zip.getNextEntry()) != null) {
                String name = entry.getName();

                if (name.endsWith(".json"))
                    importLogbook(context, zip);
                else
                    importImage(context, zip, entry);
            }
        } catch (IOException e) {
            e.printStackTrace();
            error(Error.ERROR_ZIP_ITERATE);
            return;
        } finally {
            try {
                zip.close();
            } catch (IOException e) {
                e.printStackTrace();
                error(Error.ERROR_ZIP_CLOSE);
            }
        }

        /**
         * Handler.post() is used to run the callbacks on the original thread, not the new one
         * created by {@link #importFromUri(ContentResolver, Uri, OnProgressListener)}.
         */
        if (mCallbacks != null)
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mCallbacks.onFinish();
                }
            });
    }

    /**
     * Uses the given {@link ZipInputStream} to extract, parse, and import new Logbook data.
     * @see #importData(Context)
     *
     * @param in The {@link ZipInputStream} to read from.
     */
    private static void importLogbook(Context context, ZipInputStream in) {
        StringBuilder jsonStr = new StringBuilder();
        BufferedReader reader = new BufferedReader(new InputStreamReader(in));

        // read in the JSON string
        try {
            String next;
            while ((next = reader.readLine()) != null)
                jsonStr.append(next);
        } catch (IOException e) {
            e.printStackTrace();
            error(Error.ERROR_JSON_READ);
            return;
        }

        // convert String to JSON
        try {
            JsonImporter.parse(context, new JSONObject(jsonStr.toString()));
        } catch (JSONException e) {
            e.printStackTrace();
            error(Error.ERROR_JSON_PARSE);
        }
    }

    /**
     * Copies the image represented by the given ZipEntry to the application's pictures folder.
     * @see #importData(Context)
     *
     * @param in The InputStream being read from.
     * @param entry The ZipEntry containing the image to copy.
     */
    private static void importImage(Context context, ZipInputStream in, ZipEntry entry) {
        File newFile = PhotoUtils.privatePhotoFile(context, entry.getName());
        Log.d(TAG, "Importing image: " + entry.getName());

        if (newFile == null || newFile.exists())
            return;

        try {
            FileOutputStream out = new FileOutputStream(newFile);
            IOUtils.copy(in, out);
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
            error(Error.ERROR_IMAGE_IMPORT);
        }
    }

    /**
     * A simple method for error handling.
     * @param err The error value.
     */
    private static void error(final Error err) {
        if (mCallbacks != null)
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mCallbacks.onError(err.getMessage());
                }
            });
    }
}
