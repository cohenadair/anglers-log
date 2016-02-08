package com.cohenadair.anglerslog.model;

import android.content.ContentResolver;
import android.net.Uri;
import android.os.Handler;

import com.cohenadair.anglerslog.model.backup.JsonParser;
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
 * The Importer class is used to import data from a .zip archive.
 *
 * Created by Cohen Adair on 2016-02-07.
 */
public class Importer {

    private static final String TAG = "Importer";

    private static ContentResolver mContentResolver;
    private static Uri mUri;
    private static OnProgressListener mCallbacks;
    private static Handler mHandler;

    public interface OnProgressListener {
        void onFinish();
    }

    public static void importFromUri(ContentResolver contentResolver, Uri uri, OnProgressListener onProgress) {
        mContentResolver = contentResolver;
        mUri = uri;
        mCallbacks = onProgress;
        mHandler = new Handler();

        new Thread(new UnzipRunnable()).start();
    }

    private static void importData() throws IOException {
        InputStream is = mContentResolver.openInputStream(mUri);
        if (is == null)
            return;

        ZipInputStream zip = new ZipInputStream(is);
        ZipEntry entry;

        while ((entry = zip.getNextEntry()) != null) {
            String name = entry.getName();

            if (name.endsWith(".json"))
                importLogbook(zip, entry);
            //else
                //importImage(zip, entry);
        }

        zip.close();

        if (mCallbacks != null)
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mCallbacks.onFinish();
                }
            });
    }

    private static void importLogbook(ZipInputStream in, ZipEntry entry) throws IOException {
        StringBuilder jsonStr = new StringBuilder();
        BufferedReader reader = new BufferedReader(new InputStreamReader(in));

        // read in the JSON string
        String next;
        while ((next = reader.readLine()) != null)
            jsonStr.append(next);

        // convert String to JSON
        try {
            JsonParser.parse(new JSONObject(jsonStr.toString()));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * Copies the image represented by the given ZipEntry to the applications pictures folder.
     *
     * @param in The InputStream being read from.
     * @param entry The ZipEntry containing the image to copy.
     */
    private static void importImage(ZipInputStream in, ZipEntry entry) {
        File newFile = PhotoUtils.privatePhotoFile(entry.getName());

        if (newFile == null || newFile.exists())
            return;

        try {
            FileOutputStream out = new FileOutputStream(newFile);
            IOUtils.copy(in, out);
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

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
