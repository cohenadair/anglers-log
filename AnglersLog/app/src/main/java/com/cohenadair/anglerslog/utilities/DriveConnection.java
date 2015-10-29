package com.cohenadair.anglerslog.utilities;

import android.app.Activity;
import android.content.IntentSender;
import android.util.Log;

import com.cohenadair.anglerslog.R;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.drive.Drive;

import java.util.InputMismatchException;

/**
 * A {@link GoogleApiClient} wrapper class for creating a connection to Google Drive.
 *
 * Created by Cohen Adair on 2015-10-26.
 */
public class DriveConnection {

    public static final int RESOLVE_CONNECTION_REQUEST = 0;

    private static final String TAG = "DriveConnection";

    private GoogleApiClient mDriveClient;
    private Activity mActivity;
    private boolean mIsConnected = false;

    public DriveConnection(Activity activity, DriveUtils.OnSyncListener onSyncListener) {
        if (!(activity instanceof GoogleApiClient.ConnectionCallbacks) || !(activity instanceof GoogleApiClient.OnConnectionFailedListener)) {
            Log.e(TAG, "Activity must implement GoogleApiClient.ConnectionCallbacks and GoogleApiClient.OnConnectionFailedListener.");
            throw new InputMismatchException();
        }
        mActivity = activity;
        DriveUtils.init(mActivity, onSyncListener);
    }

    public void setUp() {
        DriveUtils.requestBackupEnabled(new DriveUtils.OnConfirmBackup() {
            @Override
            public void confirm() {
                mDriveClient = new GoogleApiClient.Builder(mActivity)
                        .addApi(Drive.API)
                        .addScope(Drive.SCOPE_APPFOLDER)
                        .addConnectionCallbacks((GoogleApiClient.ConnectionCallbacks) mActivity)
                        .addOnConnectionFailedListener((GoogleApiClient.OnConnectionFailedListener) mActivity)
                        .build();
                connect();
                DriveUtils.setClient(mDriveClient);
            }
        });
    }

    public void connect() {
        if (mDriveClient != null)
            mDriveClient.connect();
    }

    public void resolveConnection(ConnectionResult result) {
        if (result.hasResolution()) {
            try {
                result.startResolutionForResult(mActivity, RESOLVE_CONNECTION_REQUEST);
            } catch (IntentSender.SendIntentException e) {
                Utils.showToast(mActivity, R.string.error_resolve_google_connection);
                e.printStackTrace();
            }
        } else
            GooglePlayServicesUtil.getErrorDialog(result.getErrorCode(), mActivity, 0).show();
    }

    public void sync() {
        if (mIsConnected)
            DriveUtils.sync();
    }

    public void setIsConnected(boolean isConnected) {
        mIsConnected = isConnected;
    }
}
