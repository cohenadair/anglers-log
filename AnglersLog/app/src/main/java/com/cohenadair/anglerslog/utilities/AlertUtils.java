package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.DialogInterface;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.AlertDialog;
import android.widget.ArrayAdapter;

import com.cohenadair.anglerslog.R;

/**
 * A collection of {@link android.support.v7.app.AlertDialog} utility methods.
 * @author Cohen Adair
 */
public class AlertUtils {

    /**
     * The index of items that appear in a
     * {@link #showManageOptions(Context, String, DialogInterface.OnClickListener)} alert.
     */
    public static final int MANAGE_ALERT_EDIT = 0;
    public static final int MANAGE_ALERT_DELETE = 1;

    /**
     * Shows an {@link AlertFragment} with the given parameters. Alerts shown using this method
     * survive device rotation.
     *
     * @param titleId The resource id for the dialog title.
     * @param msgId The resource id for the dialog message.
     */
    public static void show(Context context, FragmentManager manager, int titleId, int msgId) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context)
                .setTitle(titleId)
                .setMessage(msgId)
                .setNegativeButton(android.R.string.ok, null);

        new AlertFragment().initWithBuilder(builder).show(manager, null);
    }

    /**
     * Shows an {@link AlertDialog} with the given parameters. Alerts shown using this method do not
     * survive device rotation.
     *
     * @param titleId The resource id for the dialog title.
     * @param msg The resource id for the dialog message.
     */
    public static void show(Context context, int titleId, String msg) {
        new AlertDialog.Builder(context)
                .setTitle(titleId)
                .setMessage(msg)
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
    }

    /**
     * Shows an {@link AlertDialog} with the given message. Alerts shown using this method do not
     * have a title and do not survive device rotation.
     *
     * @param msgId The resource id for the dialog message.
     */
    public static void show(Context context, int msgId) {
        new AlertDialog.Builder(context)
                .setMessage(msgId)
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
    }

    /**
     * Shows an {@link AlertDialog} that represents some kind of error. Alerts shown using this
     * method do not survive device rotation.
     *
     * @param msg The message to be shown.
     */
    public static void showError(Context context, String msg) {
        new AlertDialog.Builder(context)
                .setTitle(context.getResources().getString(R.string.error))
                .setMessage(msg)
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
    }

    /**
     * @see #showError(Context, String)
     * @param msgId The resource id of the message to be shown.
     */
    public static void showError(Context context, int msgId) {
        showError(context, context.getResources().getString(msgId));
    }

    /**
     * Shows an {@link AlertDialog}, giving managing options such as "Edit" or "Delete". Alerts
     * shown using this method do not survive device rotation.
     *
     * @param onItemClick The on item click listener.
     */
    public static void showManageOptions(Context context, String title, DialogInterface.OnClickListener onItemClick) {
        new AlertDialog.Builder(context)
                .setTitle(title)
                .setPositiveButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setItems(R.array.manage_options, onItemClick)
                .show();
    }

    /**
     * Shows an {@link AlertDialog} meant to be used for user confirmation, such as when deleting
     * an item from a list. Alerts shown using this method do not survive device rotation.
     *
     * @param titleResId The resource id of the title.
     * @param msgResId The resource id of the message.
     * @param buttonResId The resource id of the confirmation button.
     * @param onConfirm Callback for the user confirmation event.
     */
    public static void showConfirmation(Context context, int titleResId, int msgResId, int buttonResId, DialogInterface.OnClickListener onConfirm) {
        new AlertDialog.Builder(context)
                .setTitle(titleResId)
                .setMessage(msgResId)
                .setNegativeButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setPositiveButton(buttonResId, onConfirm)
                .show();
    }

    /**
     * Shows an {@link AlertDialog} to get user delete confirmation.
     * @see #showConfirmation(Context, int, int, int, DialogInterface.OnClickListener)
     */
    public static void showDeleteConfirmation(Context context, DialogInterface.OnClickListener onConfirm) {
        showConfirmation(context, R.string.action_confirm, R.string.msg_confirm_delete, R.string.action_delete, onConfirm);
    }

    /**
     * @see #showDeleteConfirmation(Context, DialogInterface.OnClickListener)
     * @param msgId The resource id of the message to be shown.
     */
    public static void showDeleteConfirmation(Context context, int msgId, DialogInterface.OnClickListener onConfirm) {
        showConfirmation(context, R.string.action_delete, msgId, R.string.action_delete, onConfirm);
    }

    /**
     * An interface to be used with
     * {@link #showSelection(Context, FragmentManager, ArrayAdapter, OnSelectionDialogCallback)}.
     */
    public interface OnSelectionDialogCallback {
        void onSelect(int position);
    }

    /**
     * Shows an {@link AlertFragment} with a list of selectable options. Alerts shown using this
     * method survive device rotation.
     *
     * @param manager A {@link FragmentManager} from which to show the alert.
     * @param adapter The adapter of selection items to show.
     * @param callback The callback for when an option is selected.
     */
    public static void showSelection(Context context, FragmentManager manager, ArrayAdapter<String> adapter, final OnSelectionDialogCallback callback) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context)
                .setNegativeButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setAdapter(adapter, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        if (callback != null)
                            callback.onSelect(which);
                        dialog.dismiss();
                    }
                });

        new AlertFragment().initWithBuilder(builder).show(manager, null);
    }
}
