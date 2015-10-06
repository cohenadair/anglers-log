package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.DialogInterface;
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

    /**
     * The index of items that appear in a ManageAlert.
     */
    public static final int MANAGE_ALERT_EDIT = 0;
    public static final int MANAGE_ALERT_DELETE = 1;

    public static void showToast(Context context, int resId) {
        Toast.makeText(context, resId, Toast.LENGTH_SHORT).show();
    }

    public static void showSnackbar(View view, String msg) {
        Snackbar.make(view, msg, Snackbar.LENGTH_LONG).show();
    }

    public static void showErrorAlert(Context context, int msgId) {
        new AlertDialog.Builder(context)
                .setTitle("Error")
                .setMessage(msgId)
                .setPositiveButton(R.string.OK, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
    }

    /**
     * An alert that shows managing options such as "Edit" and "Delete".
     * @param context The context in which to show the dialog.
     * @param onItemClick The on item click listener.
     */
    public static void showManageAlert(Context context, DialogInterface.OnClickListener onItemClick) {
        new AlertDialog.Builder(context)
                .setPositiveButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setItems(R.array.manage_options, onItemClick)
                .show();
    }

    public static void showDeleteConfirm(Context context, DialogInterface.OnClickListener onConfirm) {
        new AlertDialog.Builder(context)
                .setTitle(R.string.action_confirm)
                .setMessage(R.string.msg_confirm_delete)
                .setNegativeButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setPositiveButton(R.string.action_delete, onConfirm)
                .show();
    }

    public static float getFloat(Resources resources, int resId) {
        TypedValue out = new TypedValue();
        resources.getValue(resId, out, true);
        return out.getFloat();
    }

    /**
     * Checks to see if two dates are equal, excluding seconds from the comparison.
     * @param date1 The first date to compare.
     * @param date2 The second date to compare.
     * @return True if the dates are equal, false otherwise.
     */
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