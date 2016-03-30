package com.cohenadair.anglerslog.model.backup;

import android.content.Context;
import android.os.Environment;
import android.os.Handler;

import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * The Exporter class exports the user's entire {@link com.cohenadair.anglerslog.model.Logbook} to
 * a zip file at the user-chosen location.
 *
 * @author Cohen Adair
 */
public class Exporter {

    public static final int ERROR_FILE_NOT_FOUND = 0;
    public static final int ERROR_JSON_WRITE = 1;
    public static final int ERROR_ZIP_WRITE_JSON = 2;
    public static final int ERROR_ZIP_CLOSE = 3;
    public static final int ERROR_IMAGES_DIRECTORY_NULL = 4;
    public static final int ERROR_IMAGES_WRITE = 5;

    private static final String FILE_NAME_ZIP = "AnglersLogBackup.zip";
    private static final String FILE_NAME_JSON = "AnglersLogData.json";

    private static Context mContext;
    private static OnProgressListener mCallbacks;
    private static File mFile;
    private static Handler mHandler;

    /**
     * Used to determine UI behavior during different times in the exporting process.
     */
    public interface OnProgressListener {
        void onFinish(File zipFile);
        void onError(int errorNo);
    }

    /**
     * Exports {@link com.cohenadair.anglerslog.model.Logbook} data to a zip file and saves the
     * zip file to the given path.
     *
     * @param zipFilePath The path to save the zip file to.
     * @param onProgress Exporting progress callbacks.
     */
    public static void exportToPath(Context context, File zipFilePath, OnProgressListener onProgress) {
        mContext = context;
        mCallbacks = onProgress;
        mFile = new File(zipFilePath, FILE_NAME_ZIP);
        mHandler = new Handler();

        new Thread(new ZipRunnable()).start();
    }

    /**
     * Exports all Logbook data to a zip archive.
     */
    private static void exportData() {
        // get output stream from file location
        FileOutputStream out;

        try {
            out = new FileOutputStream(mFile);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            error(ERROR_FILE_NOT_FOUND);
            return;
        }

        // open zip stream
        ZipOutputStream zip = new ZipOutputStream(out);

        // export data
        exportLogbookJson(zip);
        exportLogbookImages(zip);

        // close zip file
        try {
            zip.close();
        } catch (IOException e) {
            e.printStackTrace();
            error(ERROR_ZIP_CLOSE);
            return;
        }

        /**
         * Handler.post() is used to run the callbacks on the original thread, not the new one
         * created by {@link #exportToPath(Context, File, OnProgressListener)}.
         */
        if (mCallbacks != null)
            mHandler.post(new Runnable() {
                @Override
                public void run() {
                    mCallbacks.onFinish(mFile);
                }
            });
    }

    /**
     * Writes the JSON representation of the Logbook to the provided {@link ZipOutputStream}.
     * @param out The output stream.
     */
    private static void exportLogbookJson(ZipOutputStream out) {
        // get JSON object from Logbook
        JSONObject json;

        try {
            json = JsonExporter.getJson();
        } catch (JSONException e) {
            e.printStackTrace();
            error(ERROR_JSON_WRITE);
            return;
        }

        // write JSON object to a zip file entry
        try {
            out.putNextEntry(new ZipEntry(FILE_NAME_JSON));
            out.write(json.toString().getBytes());
            out.closeEntry();
        } catch (IOException e) {
            e.printStackTrace();
            error(ERROR_ZIP_WRITE_JSON);
        }
    }

    /**
     * Exports all Logbook images to the provided {@link ZipOutputStream}.
     * @param out The output stream.
     */
    private static void exportLogbookImages(ZipOutputStream out) {
        File picturesDir = mContext.getExternalFilesDir(Environment.DIRECTORY_PICTURES);

        if (picturesDir == null) {
            error(ERROR_IMAGES_DIRECTORY_NULL);
            return;
        }

        // add a zip entry for each image
        File[] pictures = picturesDir.listFiles();

        for (File pic : pictures)
            try {
                out.putNextEntry(new ZipEntry(pic.getName()));

                FileInputStream in = new FileInputStream(pic);
                IOUtils.copy(in, out);

                out.closeEntry();
            } catch (IOException e) {
                e.printStackTrace();
                error(ERROR_IMAGES_WRITE);
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
     * A simple {@link Runnable} subclass for exporting Logbook data.
     */
    private static class ZipRunnable implements Runnable {
        @Override
        public void run() {
            exportData();
        }
    }
}
