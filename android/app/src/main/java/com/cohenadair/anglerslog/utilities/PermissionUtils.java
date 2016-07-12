package com.cohenadair.anglerslog.utilities;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.provider.Settings;
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

    public static final int REQUEST_EXTERNAL_STORAGE = 1;
    public static final int REQUEST_LOCATION = 2;

    public static final int GRANTED = PackageManager.PERMISSION_GRANTED;

    public static final String WRITE = Manifest.permission.WRITE_EXTERNAL_STORAGE;
    public static final String READ = Manifest.permission.READ_EXTERNAL_STORAGE;
    public static final String LOCATION = Manifest.permission.ACCESS_FINE_LOCATION;

    /**
     * Checks to see if we have permission to read and write to external storage. If not, asks
     * the user to give permission.
     *
     * @param fragment The {@link Fragment} that calls {@link Fragment#requestPermissions(String[], int)}.
     */
    public static void requestExternalStorage(Fragment fragment) {
        request(
                fragment,
                new String[] {WRITE, READ},
                isExternalStorageGranted(fragment.getContext()),
                shouldShowExplanation(fragment, WRITE) || shouldShowExplanation(fragment, READ),
                REQUEST_EXTERNAL_STORAGE,
                R.string.storage_permissions,
                R.string.storage_permissions_message
        );
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
     * Checks to see if we have permission to use the device's location services. If not, asks
     * the user for permission.
     *
     * @param fragment The {@link Fragment} that calls {@link Fragment#requestPermissions(String[], int)}.
     */
    public static void requestLocation(Fragment fragment) {
        request(
                fragment,
                new String[] {LOCATION},
                isLocationGranted(fragment.getContext()),
                shouldShowExplanation(fragment, LOCATION),
                REQUEST_LOCATION,
                R.string.location_permissions,
                R.string.location_permissions_message
        );
    }

    /**
     * @return True if permission is grated, false otherwise.
     */
    public static boolean isLocationGranted(Context context) {
        return ContextCompat.checkSelfPermission(context, LOCATION) == GRANTED;
    }

    /**
     * Checks to see if the user's location services are enabled. If not, it prompts them to enable
     * them.  Method derived from <a href="http://stackoverflow.com/a/10311891/3304388">here</a>.
     */
    public static boolean checkLocationServices(final Context context) {
        LocationManager locationManager = (LocationManager)context.getSystemService(Context.LOCATION_SERVICE);

        try {
            if (!locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER))
                new AlertDialog.Builder(context)
                        .setMessage(context.getResources().getString(R.string.error_location_disabled))
                        .setPositiveButton(context.getResources().getString(R.string.open_location_settings), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface paramDialogInterface, int paramInt) {
                                Intent myIntent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                                context.startActivity(myIntent);
                            }
                        })
                        .setNegativeButton(context.getString(R.string.button_cancel), null)
                        .show();
            else
                return true;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
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
     * @param titleId The title of the dialog.
     * @param msgId The explanation shown to users.
     * @param permissions The permissions to be requested.
     * @param requestCode The request code send with the permission request.
     */
    private static void showExplanationDialog(final Fragment fragment, int titleId, int msgId, final String[] permissions, final int requestCode) {
        new AlertDialog.Builder(fragment.getContext())
                .setTitle(titleId)
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

    /**
     * Handles a permission request, prompting the user if needed.
     *
     * @param fragment The {@link Fragment} that calls {@link Fragment#requestPermissions(String[], int)}.
     * @param permissions The permissions to request.
     * @param isGranted True if access is granted, false otherwise.
     * @param shouldShowExplanation True if an explanation should be shown to the user, false otherwise.
     * @param request The request code.
     * @param titleId The title of the explanation dialog.
     * @param msgId The message in the explanation dialog.
     */
    private static void request(Fragment fragment, String[] permissions, boolean isGranted, boolean shouldShowExplanation, int request, int titleId, int msgId) {
        if (isGranted)
            return;

        if (shouldShowExplanation)
            showExplanationDialog(fragment, titleId, msgId, permissions, request);
        else
            fragment.requestPermissions(permissions, request);
    }
}
