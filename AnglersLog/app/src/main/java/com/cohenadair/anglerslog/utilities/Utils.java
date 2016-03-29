package com.cohenadair.anglerslog.utilities;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Point;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.text.format.DateFormat;
import android.util.TypedValue;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.cohenadair.anglerslog.R;
import com.google.android.gms.maps.model.LatLng;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;

/**
 * A set of utility methods used throughout the project.
 * @author Cohen Adair
 */
public class Utils {

    public static final String MIME_TYPE_IMAGE = "image/jpeg";
    public static final String MIME_TYPE_ZIP = "application/zip";
    public static final String MIME_TYPE_ALL = "*/*";

    public static boolean isMinMarshmallow() {
        return (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M);
    }

    public static void showToast(Context context, int resId) {
        showToast(context, context.getResources().getString(resId));
    }

    public static void showToast(Context context, String msg) {
        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
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
     * Checks to see if a file exists at a given path.
     * @param path The path to the file.
     * @return True if the file exists, false otherwise.
     */
    public static boolean fileExists(String path) {
        return new File(path).exists();
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

    @TargetApi(Build.VERSION_CODES.M)
    @SuppressWarnings("deprecation")
    public static void setTextAppearance(Context context, TextView view, int resId) {
        if (isMinMarshmallow())
            view.setTextAppearance(resId);
        else
            view.setTextAppearance(context, resId);

    }

    public static void toggleViewSelected(View view, boolean selected) {
        view.setBackgroundResource(selected ? R.color.anglers_log_light_transparent : android.R.color.transparent);
    }

    public static void toggleVisibility(View view, boolean visible) {
        if (view != null)
            view.setVisibility(visible ? View.VISIBLE : View.GONE);
    }

    public static void toggleHidden(View view, boolean hidden) {
        if (view != null)
            view.setVisibility(hidden ? View.INVISIBLE : View.VISIBLE);
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
     * @param str The String.
     * @return The input String if it is not empty, null otherwise.
     */
    public static String stringOrNull(String str) {
        return (str == null || str.isEmpty()) ? null : str;
    }

    public static String emptyStringOrString(String str) {
        return (str == null) ? "" : str;
    }

    public static int resIdFromAttr(Context context, int attr) {
        TypedValue value = new TypedValue();
        context.getTheme().resolveAttribute(android.R.attr.selectableItemBackground, value, true);
        return value.resourceId;
    }

    /**
     * Ensures content appears behind the navigation and status bars.
     */
    public static void allowSystemOverlay(Activity activity) {
        activity.getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
                        View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
                        View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        );
    }

    /**
     * This snippet shows the system bars. It does this by removing all the flags except for the
     * ones that make the content appear under the system bars.
     *
     * @see <a href="http://developer.android.com/training/system-ui/immersive.html">Using Immersive Full-Screen Mode</a>
     */
    public static void showSystemUI(Activity activity) {
        activity.getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        );
    }

    /**
     * @see #showSystemUI(Activity)
     */
    public static void hideSystemUI(Activity activity) {
        // set the content to appear under the system bars so that the content
        // doesn't resize when the system bars hide and show.
        activity.getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | // hide nav bar
                View.SYSTEM_UI_FLAG_FULLSCREEN // hide status bar
        );
    }

    public static void toggleSystemUI(Activity activity, boolean show) {
        if (show)
            showSystemUI(activity);
        else
            hideSystemUI(activity);
    }

    /**
     * @return The height of the system's status bar.
     * See <a href="http://mrtn.me/blog/2012/03/17/get-the-height-of-the-status-bar-in-android/">Get the height of the status bar in Android.</a>
     */
    public static int getStatusBarHeight(Context context) {
        int result = 0;
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");

        if (resourceId > 0)
            result = context.getResources().getDimensionPixelSize(resourceId);

        return result;
    }

    public static boolean isValid(LatLng latLng) {
        return (latLng.latitude >= -90 && latLng.latitude <= 90) && (latLng.longitude >= -180 && latLng.longitude <= 180);
    }

}
