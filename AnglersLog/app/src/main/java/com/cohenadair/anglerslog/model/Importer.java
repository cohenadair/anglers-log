package com.cohenadair.anglerslog.model;

import android.content.ContentResolver;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
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

    private static void iterateZip() throws IOException {
        InputStream is = mContentResolver.openInputStream(mUri);
        if (is == null)
            return;

        ZipInputStream zip = new ZipInputStream(is);
        ZipEntry entry;

        while ((entry = zip.getNextEntry()) != null) {
            Log.i(TAG, entry.getName());
        }

        if (mCallbacks != null)
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mCallbacks.onFinish();
                }
            });
    }

    private static class UnzipRunnable implements Runnable {
        @Override
        public void run() {
            try {
                iterateZip();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
