package com.cohenadair.anglerslog.utilities;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.widget.Toast;

/**
 * A set of utility methods used throughout the project.
 * @author Cohen Adair
 */
public class Utilities {

    public static void showToast(Context context, String msg) {
        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
    }

    public static void handleDisplayBackButton(Activity anActivity) {
        boolean canBack = anActivity.getFragmentManager().getBackStackEntryCount() > 0;
        Utilities.handleDisplayBackButton(anActivity, canBack);
    }

    public static void handleDisplayBackButton(Activity anActivity, boolean show) {
        ActionBar actionBar = anActivity.getActionBar();
        if (actionBar != null)
            actionBar.setDisplayHomeAsUpEnabled(show);
    }

}
