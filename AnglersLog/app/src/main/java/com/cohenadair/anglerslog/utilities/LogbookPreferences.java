package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.SharedPreferences;

import com.cohenadair.anglerslog.R;

/**
 * Used to store and retrieve values from {@link android.content.SharedPreferences}.
 *
 * Created by Cohen Adair on 2016-01-23.
 */
public class LogbookPreferences {

    public static final String PREF_SELECTIONS = "com.cohenadair.anglerslog.PreviousSelections";
    public static final String PREF_LAYOUT = "com.cohenadair.anglerslog.LayoutPreferences";

    public static final String NAVIGATION_ID = "navigationId";
    public static final String NAVIGATION_TITLE = "navigationTitle";

    public static final String ROOT_TWO_PANE = "isRootTwoPane";

    private static Context mContext;

    public static void init(Context context) {
        mContext = context;
    }

    private static SharedPreferences getPreviousSelections() {
        return mContext.getSharedPreferences(PREF_SELECTIONS, Context.MODE_PRIVATE);
    }

    private static SharedPreferences getLayoutPreferences() {
        return mContext.getSharedPreferences(PREF_LAYOUT, Context.MODE_PRIVATE);
    }

    public static void setNavigationId(int id) {
        getPreviousSelections().edit().putInt(NAVIGATION_ID, id).apply();
    }

    public static int getNavigationId() {
        return getPreviousSelections().getInt(NAVIGATION_ID, LayoutSpecManager.LAYOUT_CATCHES);
    }

    public static void setNavigationTitle(String title) {
        getPreviousSelections().edit().putString(NAVIGATION_TITLE, title).apply();
    }

    public static String getNavigationTitle() {
        return getPreviousSelections().getString(NAVIGATION_TITLE, mContext.getResources().getString(R.string.drawer_catches));
    }

    public static void setIsRootTwoPane(boolean isTwoPane) {
        getLayoutPreferences().edit().putBoolean(ROOT_TWO_PANE, isTwoPane).apply();
    }

    public static boolean getIsRootTwoPane() {
        boolean b = getLayoutPreferences().getBoolean(ROOT_TWO_PANE, false);
        return getLayoutPreferences().getBoolean(ROOT_TWO_PANE, false);
    }
}
