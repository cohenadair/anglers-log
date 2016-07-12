package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.support.annotation.NonNull;

/**
 * A collection of methods that return different kinds of {@link android.content.Intent} objects.
 * @author Cohen Adair
 */
public class IntentUtils {

    /**
     * Gets a ACTION_VIEW Intent for a given URL.
     * @param url The URL String to open.
     * @return An Intent.
     */
    @NonNull
    public static Intent getActionView(String url) {
        return new Intent(Intent.ACTION_VIEW, Uri.parse(url));
    }

    /**
     * Gets an {@link Intent} object for a specific external application, such as Twitter or
     * Instagram.
     *
     * @param packageName The package name of the application to be opened.
     * @param appUrl The url of parameters for the given application.
     * @param browserUrl The url to be opened in a browser if the application isn't installed.
     * @return An {@link Intent} object with the given parameters.
     */
    @NonNull
    private static Intent getApplication(Context context, String packageName, String appUrl, String browserUrl) {
        try {
            PackageInfo info = context.getPackageManager().getPackageInfo(packageName, 0);
            if (info.applicationInfo.enabled)
                return getActionView(appUrl);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        return getActionView(browserUrl);
    }

    /**
     * Gets an Intent for a Twitter link with a given hashtag.
     *
     * @param context The Context.
     * @param hashTagResId The hashtag to load.
     * @return An Intent that will open the Twitter app or the browser if Twitter isn't installed.
     *
     * @see #getApplication(Context, String, String, String)
     */
    @NonNull
    public static Intent getTwitter(Context context, int hashTagResId) {
        return getApplication(
                context,
                "com.twitter.android",
                "twitter://search?query=%23" + context.getResources().getString(hashTagResId),
                "https://twitter.com/search?f=realtime&amp;q=%23" + context.getResources().getString(hashTagResId)
        );
    }

    /**
     * Gets an Intent for an Instagram link with a given hashtag.
     *
     * @param context The Context.
     * @param hashTagResId The hashtag to load.
     * @return An Intent that will open the Instagram app or the browser if Instagram isn't
     *         installed.
     *
     * @see #getApplication(Context, String, String, String)
     */
    @NonNull
    public static Intent getInstagram(Context context, int hashTagResId) {
        return getApplication(
                context,
                "com.instagram.android",
                "https://www.instagram.com/explore/tags/" + context.getResources().getString(hashTagResId),
                "https://www.instagram.com/explore/tags/" + context.getResources().getString(hashTagResId)
        );
    }

    /**
     * Gets an Intent that opens the app in Google Play.
     */
    @NonNull
    public static Intent getStore(Context context) {
        return new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + context.getPackageName()));
    }
}
