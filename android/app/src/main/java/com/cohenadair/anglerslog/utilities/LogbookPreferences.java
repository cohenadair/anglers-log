package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.Logbook;

import java.util.Date;

/**
 * Used to store and retrieve values from {@link android.content.SharedPreferences}.
 * @author Cohen Adair
 */
public class LogbookPreferences {

    private static final String PREF_CLEANUP = "com.cohenadair.anglerslog.Cleanup";
    private static final String PREF_SELECTIONS = "com.cohenadair.anglerslog.PreviousSelections";
    private static final String PREF_LAYOUT = "com.cohenadair.anglerslog.LayoutPreferences";

    private static final String NAVIGATION_ID = "navigationId";
    private static final String ROOT_TWO_PANE = "isRootTwoPane";
    private static final String WEATHER_UNITS = "weatherUnits";
    private static final String BACKUP_FILE = "backupFilePath";
    private static final String MAP_TYPE = "mapType";
    private static final String SHOW_INSTABUG_SHEET = "showInstabugSheet";
    private static final String LAST_BACKUP = "lastBackup";

    private static SharedPreferences getCleanup(Context context) {
        return context.getSharedPreferences(PREF_CLEANUP, Context.MODE_PRIVATE);
    }

    private static SharedPreferences getPreviousSelections(Context context) {
        return context.getSharedPreferences(PREF_SELECTIONS, Context.MODE_PRIVATE);
    }

    private static SharedPreferences getLayoutPreferences(Context context) {
        return context.getSharedPreferences(PREF_LAYOUT, Context.MODE_PRIVATE);
    }

    private static SharedPreferences getDefaultPreferences(Context context) {
        return PreferenceManager.getDefaultSharedPreferences(context);
    }

    public static void setBackupFile(Context context, String filePath) {
        getCleanup(context).edit().putString(BACKUP_FILE, filePath).apply();
    }

    public static String getBackupFile(Context context) {
        return getCleanup(context).getString(BACKUP_FILE, null);
    }

    public static void setNavigationId(Context context, int id) {
        getPreviousSelections(context).edit().putInt(NAVIGATION_ID, id).apply();
    }

    public static int getNavigationId(Context context) {
        return getPreviousSelections(context).getInt(NAVIGATION_ID, LayoutSpecManager.LAYOUT_CATCHES);
    }

    public static void setMapType(Context context, int type) {
        getPreviousSelections(context).edit().putInt(MAP_TYPE, type).apply();
    }

    public static int getMapType(Context context) {
        return getPreviousSelections(context).getInt(MAP_TYPE, 1);
    }

    public static void setIsRootTwoPane(Context context, boolean isTwoPane) {
        getLayoutPreferences(context).edit().putBoolean(ROOT_TWO_PANE, isTwoPane).apply();
    }

    public static boolean getIsRootTwoPane(Context context) {
        return getLayoutPreferences(context).getBoolean(ROOT_TWO_PANE, false);
    }

    public static void setWeatherUnits(Context context, int units) {
        getPreviousSelections(context).edit().putInt(WEATHER_UNITS, units).apply();
    }

    public static int getWeatherUnits(Context context) {
        return getPreviousSelections(context).getInt(WEATHER_UNITS, -1);
    }

    //region Settings Preferences
    public static int getUnits(Context context) {
        return Integer.parseInt(getDefaultPreferences(context).getString(context.getResources().getString(R.string.pref_units), Integer.toString(Logbook.UNIT_IMPERIAL)));
    }

    public static void setUnits(Context context, int units) {
        getDefaultPreferences(context)
                .edit()
                .putString(context.getResources().getString(R.string.pref_units), Integer.toString(units))
                .apply();
    }

    public static boolean isInstabugEnabled(Context context) {
        return getDefaultPreferences(context).getBoolean(context.getResources().getString(R.string.pref_instabug), true);
    }

    public static void setInstabugEnabled(Context context, boolean enabled) {
        getDefaultPreferences(context)
                .edit()
                .putBoolean(context.getResources().getString(R.string.pref_instabug), enabled)
                .apply();
    }
    //endregion

    public static boolean shouldShowInstabugSheet(Context context) {
        return getDefaultPreferences(context).getBoolean(SHOW_INSTABUG_SHEET, true);
    }

    public static void setShouldShowInstabugSheet(Context context, boolean shouldShow) {
        getDefaultPreferences(context).edit().putBoolean(SHOW_INSTABUG_SHEET, shouldShow).apply();
    }

    public static boolean shouldShowBackupSheet(Context context) {
        long ms = getDefaultPreferences(context).getLong(LAST_BACKUP, -1);

        // do not prompt users to backup if it's the first run
        if (ms == -1) {
            updateLastBackup(context); // comparison baseline
            return false;
        }

        // prompt the user every 7 days
        return ((new Date().getTime() - ms) > (60000 * 60 * 24 * 7));
    }

    public static void updateLastBackup(Context context) {
        getDefaultPreferences(context).edit().putLong(LAST_BACKUP, new Date().getTime()).apply();
    }
}
