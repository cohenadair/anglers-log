package com.cohenadair.anglerslog.utilities;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.util.TypedValue;
import android.view.View;
import android.widget.Toast;

import com.cohenadair.anglerslog.R;

import java.util.Calendar;
import java.util.Date;

/**
 * A set of utility methods used throughout the project.
 * @author Cohen Adair
 */
public class Utils {

    public static void showToast(Context context, String msg) {
        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
    }

    public static void showSnackbar(View view, String msg) {
        Snackbar.make(view, msg, Snackbar.LENGTH_LONG).show();
    }

    public static void showErrorAlert(Context context, int msgId) {
        new AlertDialog.Builder(context)
                .setTitle("Error")
                .setMessage(msgId)
                .setNeutralButton(R.string.OK, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
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

    public static float getFloat(Resources resources, int resId) {
        TypedValue out = new TypedValue();
        resources.getValue(resId, out, true);
        return out.getFloat();
    }

    public static boolean datesEqualNoSeconds(Date date1, Date date2) {
        Calendar c = Calendar.getInstance();
        c.setTime(date1);
        int year1 = c.get(Calendar.YEAR);
        int month1 = c.get(Calendar.MONTH);
        int day1 = c.get(Calendar.DAY_OF_MONTH);
        int hours1 = c.get(Calendar.HOUR_OF_DAY);
        int minutes1 = c.get(Calendar.MINUTE);

        c.setTime(date2);
        int year2 = c.get(Calendar.YEAR);
        int month2 = c.get(Calendar.MONTH);
        int day2 = c.get(Calendar.DAY_OF_MONTH);
        int hours2 = c.get(Calendar.HOUR_OF_DAY);
        int minutes2 = c.get(Calendar.MINUTE);

        return (year1 == year2) && (month1 == month2) && (day1 == day2) && (hours1 == hours2) && (minutes1 == minutes2);
    }

}
