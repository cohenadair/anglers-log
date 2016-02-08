package com.cohenadair.anglerslog.utilities;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Point;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.text.format.DateFormat;
import android.view.MenuItem;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import android.widget.Toast;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.activities.DetailFragmentActivity;

import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

/**
 * A set of utility methods used throughout the project.
 * @author Cohen Adair
 */
public class Utils {

    private static final String TAG = "Utils";

    /**
     * The index of items that appear in a ManageAlert.
     */
    public static final int MANAGE_ALERT_EDIT = 0;
    public static final int MANAGE_ALERT_DELETE = 1;

    /**
     * Checks to see if the current Android version is KitKat (4.4) or newer.
     * @return True if KitKat or newer; false otherwise.
     */
    public static boolean isKitKatOrNewer() {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT;
    }

    public static void showToast(Context context, int resId) {
        showToast(context, context.getResources().getString(resId));
    }

    public static void showToast(Context context, String msg) {
        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
    }

    public static void showSnackbar(View view, String msg) {
        Snackbar.make(view, msg, Snackbar.LENGTH_LONG).show();
    }

    public static void showAlert(Context context, int titleId, int msgId) {
        new AlertDialog.Builder(context)
                .setTitle(titleId)
                .setMessage(msgId)
                .setPositiveButton(R.string.OK, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
    }

    public static void showAlert(Context context, int titleId, String msg) {
        new AlertDialog.Builder(context)
                .setTitle(titleId)
                .setMessage(msg)
                .setPositiveButton(R.string.OK, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
    }

    public static void showErrorAlert(Context context, int msgId) {
        showErrorAlert(context, context.getResources().getString(msgId));
    }

    public static void showErrorAlert(Context context, String msg) {
        new AlertDialog.Builder(context)
                .setTitle(context.getResources().getString(R.string.error))
                .setMessage(msg)
                .setPositiveButton(R.string.OK, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .show();
    }

    // TODO wrap AlertDialog instances in a DialogFragment to properly handle rotation
    // see http://stackoverflow.com/questions/7557265/prevent-dialog-dismissal-on-screen-rotation-in-android

    /**
     * An alert that shows managing options such as "Edit" and "Delete".
     * @param context The context in which to show the dialog.
     * @param onItemClick The on item click listener.
     */
    public static void showManageAlert(Context context, String title, DialogInterface.OnClickListener onItemClick) {
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

    public static void showConfirmationDialog(Context context, int titleResId, int msgResId, int buttonResId, DialogInterface.OnClickListener onConfirm) {
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

    public static void showDeleteConfirm(Context context, DialogInterface.OnClickListener onConfirm) {
        showConfirmationDialog(context, R.string.action_confirm, R.string.msg_confirm_delete, R.string.action_delete, onConfirm);
    }

    public static void showResetConfirm(Context context, DialogInterface.OnClickListener onReset) {
        showConfirmationDialog(context, R.string.confirm, R.string.reset_confirm, R.string.reset, onReset);
    }

    public static void showDeleteOption(Context context, int msgId, DialogInterface.OnClickListener onConfirm) {
        new AlertDialog.Builder(context)
                .setTitle(R.string.action_delete)
                .setMessage(msgId)
                .setNegativeButton(R.string.button_cancel, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.cancel();
                    }
                })
                .setPositiveButton(R.string.action_delete, onConfirm)
                .show();
    }

    public interface OnSelectionDialogCallback {
        void onSelect(int position);
    }

    /**
     * Shows a Dialog with a list of options to select.
     *
     * @param context The Context.
     * @param adapter The adapter of selection items to show.
     * @param callback The callback for when an option is selected.
     */
    public static void showSelectionDialog(Context context, ArrayAdapter<String> adapter, final OnSelectionDialogCallback callback) {
        new AlertDialog.Builder(context)
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
                })
                .show();
    }

    /**
     * Checks to see if the user's location services are enabled. If not, it prompts them to enable
     * them.  Method derived from <a href="http://stackoverflow.com/a/10311891/3304388">here</a>.
     */
    public static boolean requestLocationServices(final Context context) {
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
     * This method converts device specific pixels to density independent pixels.
     * @param px A value in px (pixels) unit. Which we need to convert into db.
     * @return A float value to represent dp equivalent to px value.
     */
    public static float pxToDp(float px){
        return px / Resources.getSystem().getDisplayMetrics().density;
    }

    /**
     * This method converts density independent pixels to device specific pixels.
     * @param dp A value in px (pixels) unit. Which we need to convert into db.
     * @return A float value to represent dp equivalent to px value.
     */
    public static float dpToPx(float dp){
        return dp * Resources.getSystem().getDisplayMetrics().density;
    }

    /**
     * Gets the screen size in pixels.
     * @param activity The activity used to get the screen size.
     * @return A Point object representing the screen size, in pixels.
     */
    public static Point getScreenSize(Activity activity) {
        Point size = new Point();
        activity.getWindowManager().getDefaultDisplay().getSize(size);
        return size;
    }

    /**
     * Gets the screen size in pixels.
     * @param context The context used to get the screen size.
     * @return A Point object representing the screen size, in pixels.
     */
    @NonNull
    public static Point getScreenSize(Context context) {
        return new Point(
                context.getResources().getDisplayMetrics().widthPixels,
                context.getResources().getDisplayMetrics().heightPixels
        );
    }

    /**
     * Checks to see if the current context is two-pane.
     * @param context The Context to check.
     * @return True if two-pane; false otherwise.
     */
    public static boolean isTwoPane(Context context) {
        return context.getResources().getBoolean(R.bool.has_two_panes);
    }

    /**
     * Gets the extension from a given file name.
     * @param fileName The file name.
     * @return A String representing the file's extension.
     */
    @NonNull
    public static String extractExtension(String fileName) {
        return fileName.substring(fileName.lastIndexOf('.') + 1);
    }

    /**
     * Checks to see if the specified String contains a substring of one of the Strings in the
     * specified array.
     *
     * @param str The String on which to look for substrings.
     * @param arr The Array of substrings.
     * @return True if `str` contains an element of `arr`, false otherwise.
     */
    public static boolean stringContainsArray(String str, ArrayList<String> arr) {
        for (String s : arr)
            if (str.contains(s))
                return true;
        return false;
    }

    @NonNull
    public static String getDisplayDate(Date date) {
        return DateFormat.format("MMMM dd, yyyy", date).toString();
    }

    @NonNull
    public static String getDisplayTime(Date date) {
        return DateFormat.format("h:mm a", date).toString();
    }

    public static boolean isMinMarshemellow() {
        return (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M);
    }

    @TargetApi(Build.VERSION_CODES.M)
    @SuppressWarnings("deprecation")
    public static void setTextAppearance(Context context, TextView view, int resId) {
        if (isMinMarshemellow())
            view.setTextAppearance(resId);
        else
            view.setTextAppearance(context, resId);

    }

    public static void toggleViewSelected(View view, boolean selected) {
        view.setBackgroundResource(selected ? R.color.light_grey : android.R.color.transparent);
    }

    public static void toggleVisibility(View view, boolean visible) {
        if (view == null)
            return;

        view.setVisibility(visible ? View.VISIBLE : View.GONE);
    }

    public static void addDoneButton(@NonNull Toolbar toolbar, MenuItem.OnMenuItemClickListener onClick) {
        MenuItem done = toolbar.getMenu().add(R.string.action_done);
        done.setIcon(R.drawable.ic_check);
        done.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
        done.setOnMenuItemClickListener(onClick);
    }

    public interface OnTextChangedListener {
        void onTextChanged(String newText);
    }

    public static TextWatcher onTextChangedListener(final OnTextChangedListener listener) {
        return new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                listener.onTextChanged(s.toString());
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        };
    }

    /**
     * Gets an Intent used to show a {@link DetailFragmentActivity}.
     * @param context The context.
     * @param layoutSpecId See {@link LayoutSpecManager}.
     * @param userDefineObjectId The UUID of the object to display.
     * @return An Intent with required extras.
     */
    public static Intent getDetailActivityIntent(Context context, int layoutSpecId, UUID userDefineObjectId) {
        Intent intent = new Intent(context, DetailFragmentActivity.class);
        intent.putExtra(DetailFragmentActivity.EXTRA_TWO_PANE, isTwoPane(context));
        intent.putExtra(DetailFragmentActivity.EXTRA_LAYOUT_ID, layoutSpecId);
        intent.putExtra(DetailFragmentActivity.EXTRA_USER_DEFINE_ID, userDefineObjectId.toString());
        return intent;
    }

    /**
     * Gets a ACTION_VIEW Intent for a given URL.
     * @param url The URL String to open.
     * @return An Intent.
     */
    public static Intent getActionViewIntent(String url) {
        return new Intent(Intent.ACTION_VIEW, Uri.parse(url));
    }

    private static Intent getApplicationIntent(Context context, String packageName, String appUrl, String browserUrl) {
        try {
            PackageInfo info = context.getPackageManager().getPackageInfo(packageName, 0);
            if (info.applicationInfo.enabled)
                return getActionViewIntent(appUrl);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        return getActionViewIntent(browserUrl);
    }

    /**
     * Gets an Intent for a Twitter link with a given hashtag.
     * @param context The Context.
     * @param hashTagResId The hashtag to load.
     * @return An Intent that will open the Twitter app or the browser if Twitter isn't installed.
     */
    public static Intent getTwitterIntent(Context context, int hashTagResId) {
        return getApplicationIntent(
                context,
                "com.twitter.android",
                "twitter://search?query=%23" + context.getResources().getString(hashTagResId),
                "https://twitter.com/search?f=realtime&amp;q=%23" + context.getResources().getString(hashTagResId)
        );
    }

    /**
     * Gets an Intent for an Instagram link with a given hashtag.
     * @param context The Context.
     * @param hashTagResId The hashtag to load.
     * @return An Intent that will open the Instagram app or the browser if Instagram isn't
     *         installed.
     */
    @Nullable
    public static Intent getInstagramIntent(Context context, int hashTagResId) {
        return getApplicationIntent(
                context,
                "com.instagram.android",
                "https://www.instagram.com/explore/tags/" + context.getResources().getString(hashTagResId),
                "https://www.instagram.com/explore/tags/" + context.getResources().getString(hashTagResId)
        );
    }

}
