package com.cohenadair.anglerslog.model.backup;

import android.content.ContentResolver;
import android.net.Uri;

/**
 * The Exporter class exports the user's entire {@link com.cohenadair.anglerslog.model.Logbook} to
 * a zip file at the user-chosen location.
 *
 * @author Cohen Adair
 */
public class Exporter {

    /**
     * Used to determine UI behavior during different times in the exporting process.
     */
    public interface OnProgressListener {
        void onFinish();
    }

    public static void exportToUri(ContentResolver contentResolver, Uri uri, OnProgressListener onProgress) {

    }
}
