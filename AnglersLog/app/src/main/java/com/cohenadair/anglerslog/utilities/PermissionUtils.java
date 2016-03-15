package com.cohenadair.anglerslog.utilities;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;

import com.cohenadair.anglerslog.R;

/**
 * A utility class for requesting user permissions. More information on this process can be found
 * <a href="http://developer.android.com/training/permissions/requesting.html">here</a>.
 *
 * @author Cohen Adair
 */
public class PermissionUtils {

    public static final int EXTERNAL_STORAGE = 1;

    public static final int GRANTED = PackageManager.PERMISSION_GRANTED;

    public static final String WRITE = Manifest.permission.WRITE_EXTERNAL_STORAGE;
    public static final String READ = Manifest.permission.READ_EXTERNAL_STORAGE;

    /**
     * Checks to see if we have permission to read and write to external storage. If not, asks
     * the user to give permission.
     *
     * @param fragment The {@link Fragment} that calls {@link Fragment#requestPermissions(String[], int)}.
     */
    public static void requestExternalStorage(Fragment fragment) {
        Context context = fragment.getContext();
        String[] permissions = new String[] { WRITE, READ };

        if (!isExternalStorageGranted(context))
            if (shouldShowExplanation(fragment, WRITE) || shouldShowExplanation(fragment, READ))
                showExplanationDialog(fragment, R.string.storage_permissions_message, permissions, EXTERNAL_STORAGE);
            else
                fragment.requestPermissions(permissions, EXTERNAL_STORAGE);
    }

    /**
     * Checks to see if the user hasn't granted external storage read and write access.
     *
     * @param context The Context.
     * @return True if allowed, false otherwise.
     */
    public static boolean isExternalStorageGranted(Context context) {
        int writePermission = ContextCompat.checkSelfPermission(context, WRITE);
        int readPermission = ContextCompat.checkSelfPermission(context, READ);
        return (writePermission == GRANTED && readPermission == GRANTED);
    }

    /**
     * Wrapper method for {@link Fragment#shouldShowRequestPermissionRationale(String)}.
     */
    private static boolean shouldShowExplanation(Fragment fragment, String permission) {
        return fragment.shouldShowRequestPermissionRationale(permission);
    }

    /**
     * Shows a dialog explaining to the user why the upcoming permissions request is needed. When
     * the dialog is dismissed, {@link Fragment#requestPermissions(String[], int)} is called.
     *
     * @param fragment The {@link Fragment} that calls {@link Fragment#requestPermissions(String[], int)}.
     * @param msgId The explanation shown to users.
     * @param permissions The permissions to be requested.
     * @param requestCode The request code send with the permission request.
     */
    private static void showExplanationDialog(final Fragment fragment, int msgId, final String[] permissions, final int requestCode) {
        new AlertDialog.Builder(fragment.getContext())
                .setTitle(R.string.storage_permissions)
                .setMessage(msgId)
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        fragment.requestPermissions(permissions, requestCode);
                        dialog.dismiss();
                    }
                })
                .show();
    }
}
