package com.cohenadair.anglerslog.utilities;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.FragmentManager;

import com.cohenadair.anglerslog.R;

import java.util.Date;

/**
 * A simple dialog that prompts the user to rate the app.
 * @author Cohen Adair
 */
public class RateDialog extends DialogFragment {

    private static final String PREF_RATE = "RatePreferences";
    private static final String PREF_VERSION = "RateVersion";
    private static final String PREF_TIME = "RateTime";
    private static final String PREF_NO = "RateNoVersion";
    private static final String PREF_FIRST = "FirstRun";

    private static final long MS_WEEK = (60000 * 60 * 24 * 7);

    private Context mContext;

    public RateDialog() {

    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        return new AlertDialog.Builder(getActivity())
                .setTitle(getResources().getString(R.string.rate_title))
                .setMessage(R.string.rate_msg)
                .setPositiveButton(R.string.rate_positive, getPositiveClick())
                .setNegativeButton(R.string.rate_negative, getNegativeClick())
                .setNeutralButton(R.string.rate_neutral, getNeutralClick())
                .create();
    }

    public void showIfNeeded(Context context, FragmentManager manager) {
        mContext = context;

        if (isFirstRun()) {
            setFirstRun(false);
            return;
        }

        if (didRateAndIsNewVersion() && isTimeExceeded()) {
            super.show(manager, "");
            return;
        }

        if (didRateThisVersion() || didNoThisVersion() || !isTimeExceeded())
            return;

        resetTime();
        super.show(manager, "");
    }

    @NonNull
    private DialogInterface.OnClickListener getPositiveClick() {
        return new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                resetVersion();
                Utils.openGooglePlay(mContext);
            }
        };
    }

    @NonNull
    private DialogInterface.OnClickListener getNegativeClick() {
        return new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                resetNo();
            }
        };
    }

    @NonNull
    private DialogInterface.OnClickListener getNeutralClick() {
        return new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                resetTime();
            }
        };
    }

    private SharedPreferences getPreferences() {
        return mContext.getSharedPreferences(PREF_RATE, Context.MODE_PRIVATE);
    }

    private String getVersion() {
        return getPreferences().getString(PREF_VERSION, null);
    }

    private String getNo() {
        return getPreferences().getString(PREF_NO, null);
    }

    private long getTime() {
        return getPreferences().getLong(PREF_TIME, -1);
    }

    private boolean isFirstRun() {
        return getPreferences().getBoolean(PREF_FIRST, true);
    }

    private void resetNo() {
        getPreferences().edit().putString(PREF_NO, getCurrentVersion()).apply();
    }

    private void resetVersion() {
        getPreferences().edit().putString(PREF_VERSION, getCurrentVersion()).apply();
    }

    private void resetTime() {
        getPreferences().edit().putLong(PREF_TIME, new Date().getTime()).apply();
    }

    private void setFirstRun(boolean firstRun) {
        getPreferences().edit().putBoolean(PREF_FIRST, firstRun).apply();
    }

    private boolean didRateThisVersion() {
        return getVersion() != null && getVersion().equals(getCurrentVersion());
    }

    private boolean didNoThisVersion() {
        return getNo() != null && getNo().equals(getCurrentVersion());
    }

    private boolean didRateAndIsNewVersion() {
        return getVersion() != null && !getVersion().equals(getCurrentVersion());
    }

    private boolean isTimeExceeded() {
        return getTime() == -1 || (new Date().getTime() - getTime() >= MS_WEEK);
    }

    @NonNull
    private String getCurrentVersion() {
        return mContext == null ? "" : mContext.getResources().getString(R.string.version_name);
    }
}
