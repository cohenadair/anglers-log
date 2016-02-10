package com.cohenadair.anglerslog.model.backup;

import android.content.ContentResolver;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;

import com.cohenadair.anglerslog.utilities.PhotoUtils;

import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * The Importer class is used to import data from a given {@link Uri} (i.e. a zip archive).
 * @author Cohen Adair
 */
public class Importer {

    private static final String TAG = "Importer";

    private static ContentResolver mContentResolver;
    private static Uri mUri;
    private static OnProgressListener mCallbacks;
    private static Handler mHandler;

    /**
     * Used to determine UI behavior during different times in the importing process.
     */
    public interface OnProgressListener {
        void onFinish();
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
     *
     * @throws IOException An IOException is thrown if there is a problem opening or traversing the
     *                     class's {@link #mUri} object.
     */
    private static void importData() throws IOException {
        InputStream is = mContentResolver.openInputStream(mUri);
        if (is == null)
            return;

        ZipInputStream zip = new ZipInputStream(is);
        ZipEntry entry;

        while ((entry = zip.getNextEntry()) != null) {
            String name = entry.getName();

            if (name.endsWith(".json"))
                importLogbook(zip);
            else
                importImage(zip, entry);
        }

        zip.close();

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
     * @throws IOException Throws an IOException if JSON cannot be read from the given input stream.
     */
    private static void importLogbook(ZipInputStream in) throws IOException {
        StringBuilder jsonStr = new StringBuilder();
        BufferedReader reader = new BufferedReader(new InputStreamReader(in));

        // read in the JSON string
        String next;
        while ((next = reader.readLine()) != null)
            jsonStr.append(next);

        // convert String to JSON
        try {
            JsonImporter.parse(new JSONObject(jsonStr.toString()));
        } catch (JSONException e) {
            e.printStackTrace();
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
        Log.d(TAG, "Importing image: " + entry.getName() + "...");

        File newFile = PhotoUtils.privatePhotoFile(entry.getName());

        if (newFile == null || newFile.exists()) {
            Log.d(TAG, "Image exists, skipping import.");
            return;
        }

        try {
            FileOutputStream out = new FileOutputStream(newFile);
            IOUtils.copy(in, out);
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * A simple {@link Runnable} subclass for importing Logbook data.
     */
    private static class UnzipRunnable implements Runnable {
        @Override
        public void run() {
            try {
                importData();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
