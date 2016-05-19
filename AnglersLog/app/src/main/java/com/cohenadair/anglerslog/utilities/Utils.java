package com.cohenadair.anglerslog.utilities;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Point;
import android.net.Uri;
import android.os.Build;
import android.support.annotation.NonNull;
import android.text.format.DateFormat;
import android.util.TypedValue;
import android.view.View;
import android.widget.Toast;

import com.cohenadair.anglerslog.R;

import java.util.ArrayList;
import java.util.Date;

/**
 * A set of utility methods used throughout the project.
 * @author Cohen Adair
 */
public class Utils {

    public static final String MIME_TYPE_IMAGE = "image/*";
    public static final String MIME_TYPE_ZIP = "application/zip";

    /**
     * @return True if the current Android version if equal to or newer than Marshmallow.
     */
    public static boolean isMinMarshmallow() {
        return (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M);
    }

    /**
     * Shows a toast with the given resource.
     */
    public static void showToast(Context context, int resId) {
        showToast(context, context.getResources().getString(resId));
    }

    /**
     * Converts a String to a float.
     *
     * @param str The String to be converted.
     * @param defaultValue The value to be returned if the given String is empty.
     * @return A float representation of the given String, or the given default value if the given
     *         String is empty.
     * @throws NumberFormatException if the input String cannot be parsed.
     */
    public static float asFloat(String str, float defaultValue) throws NumberFormatException {
        if (str.isEmpty() || (str.length() == 1 && str.equals(".")))
            return defaultValue;

        return Float.parseFloat(str);
    }

    /**
     * Shows a toast with the given String.
     */
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
     * @return A String representation of the date of the given {@link Date}.
     */
    @NonNull
    public static String getDisplayDate(Date date) {
        return DateFormat.format("MMMM dd, yyyy", date).toString();
    }

    /**
     * @return A String representation of the time of the given {@link Date}.
     */
    @NonNull
    public static String getDisplayTime(Date date) {
        return DateFormat.format("h:mm a", date).toString();
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

    /**
     * @return The input String if it is not empty, null otherwise.
     */
    public static String stringOrNull(String str) {
        return (str == null || str.isEmpty()) ? null : str;
    }

    /**
     * @return An empty String if the given String is null, the given String otherwise.
     */
    public static String emptyStringOrString(String str) {
        return (str == null) ? "" : str;
    }

    /**
     * Gets the resource id of a given attribute.
     * @param attr The attribute to look for.
     * @return The resource id.
     */
    public static int resIdFromAttr(Context context, int attr) {
        TypedValue value = new TypedValue();
        context.getTheme().resolveAttribute(attr, value, true);
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

    /**
     * Toggles the navigation and status bar's visibility.
     * @see #hideSystemUI(Activity)
     * @see #showSystemUI(Activity)
     */
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

    public static void openGooglePlay(Context context) {
        try {
            context.startActivity(IntentUtils.getStore(context));
        } catch (ActivityNotFoundException e) {
            Uri uri = Uri.parse(
                    "http://play.google.com/store/apps/details?id=" + context.getPackageName()
            );
            context.startActivity(new Intent(Intent.ACTION_VIEW, uri));
        }
    }

}
