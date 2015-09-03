package com.cohenadair.anglerslog.utilities;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.widget.Toast;

/**
 * A set of utility methods used throughout the project.
 * @author Cohen Adair
 */
public class Utils {

    public static void showToast(Context context, String msg) {
        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
    }

    public static void handleDisplayBackButton(Activity anActivity, boolean show) {
        ActionBar actionBar = anActivity.getActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(show);
            actionBar.setHomeButtonEnabled(show);
        }
    }

    public static void setActionBarTitle(Activity anActivity, int resId) {
        ActionBar actionBar = anActivity.getActionBar();
        if (actionBar != null)
            actionBar.setTitle(resId);
    }

    public static void setActionBarTitle(Activity anActivity, String title) {
        ActionBar actionBar = anActivity.getActionBar();
        if (actionBar != null)
            actionBar.setTitle(title);
    }

    public static int getOrientation(Context context) {
        return context.getResources().getConfiguration().orientation;
    }

    public static boolean isOrientationLandscape(Context context) {
        return  Utils.getOrientation(context) == Configuration.ORIENTATION_LANDSCAPE;
    }

    public static boolean isOrientationPortrait(Context context) {
        return  Utils.getOrientation(context) == Configuration.ORIENTATION_PORTRAIT;
    }

}
