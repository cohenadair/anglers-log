package com.cohenadair.anglerslog.model.backup;

import android.content.ContentResolver;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.utilities.PhotoUtils;

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

    public static final int ERROR_URI_NOT_FOUND = 0;
    public static final int ERROR_ZIP_CLOSE = 1;
    public static final int ERROR_ZIP_ITERATE = 2;
    public static final int ERROR_JSON_PARSE = 3;
    public static final int ERROR_JSON_READ = 4;
    public static final int ERROR_IMAGE_IMPORT = 5;

    private static ContentResolver mContentResolver;
    private static Uri mUri;
    private static OnProgressListener mCallbacks;
    private static Handler mHandler;

    /**
     * Used to determine UI behavior during different times in the importing process.
     */
    public interface OnProgressListener {
        void onFinish();
        void onError(int errorNo);
    }

    /**
     * Takes a given {@link Uri} of a zip archive and imports its data to the application's
     * Logbook. This method should always be called after some sort of UI interaction, such as a
     * button click.
     *
     * @param contentResolver The {@link ContentResolver} used to open input streams.
     * @param uri The Uri of the zip archive.
     * @param onProgress Callbacks for importing progress.
     */
    public static void importFromUri(ContentResolver contentResolver, Uri uri, OnProgressListener onProgress) {
        mContentResolver = contentResolver;
        mUri = uri;
        mCallbacks = onProgress;
        mHandler = new Handler();

        new Thread(new UnzipRunnable()).start();
    }

    /**
     * Handles all importing using the class's {@link #mUri} object. This method should always be
     * run in a background thread.
     */
    private static void importData() {
        InputStream is;

        try {
            is = mContentResolver.openInputStream(mUri);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            error(ERROR_URI_NOT_FOUND);
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
                    importLogbook(zip);
                else
                    importImage(zip, entry);
            }
        } catch (IOException e) {
            e.printStackTrace();
            error(ERROR_ZIP_ITERATE);
            return;
        } finally {
            try {
                zip.close();
            } catch (IOException e) {
                e.printStackTrace();
                error(ERROR_ZIP_CLOSE);
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
     * @see #importData()
     *
     * @param in The {@link ZipInputStream} to read from.
     */
    private static void importLogbook(ZipInputStream in) {
        StringBuilder jsonStr = new StringBuilder();
        BufferedReader reader = new BufferedReader(new InputStreamReader(in));

        // read in the JSON string
        try {
            String next;
            while ((next = reader.readLine()) != null)
                jsonStr.append(next);
        } catch (IOException e) {
            e.printStackTrace();
            error(ERROR_JSON_READ);
            return;
        }

        // convert String to JSON
        try {
            JsonImporter.parse(new JSONObject(jsonStr.toString()));
        } catch (JSONException e) {
            e.printStackTrace();
            error(ERROR_JSON_PARSE);
        }
    }

    /**
     * Copies the image represented by the given ZipEntry to the application's pictures folder.
     * @see #importData()
     *
     * @param in The InputStream being read from.
     * @param entry The ZipEntry containing the image to copy.
     */
    private static void importImage(ZipInputStream in, ZipEntry entry) {
        File newFile = PhotoUtils.privatePhotoFile(entry.getName());
        Log.d(TAG, "Importing image: " + entry.getName());

        if (newFile == null || newFile.exists())
            return;

        try {
            FileOutputStream out = new FileOutputStream(newFile);
            IOUtils.copy(in, out);
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
            error(ERROR_IMAGE_IMPORT);
        }
    }

    /**
     * A simple method for error handling.
     * @param errorNo The error constant.
     */
    private static void error(final int errorNo) {
        if (mCallbacks != null)
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mCallbacks.onError(errorNo);
                }
            });
    }

    /**
     * A simple {@link Runnable} subclass for importing Logbook data.
     */
    private static class UnzipRunnable implements Runnable {
        @Override
        public void run() {
            Logbook.reset(false);
            importData();
        }
    }
}
