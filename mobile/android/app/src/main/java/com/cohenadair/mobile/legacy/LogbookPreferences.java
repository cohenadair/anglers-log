package com.cohenadair.anglerslog.utilities;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

/**
 * Used to store and retrieve values from {@link android.content.SharedPreferences}.
 * @author Cohen Adair
 */
public class LogbookPreferences {
    private static final String PREF_SELECTIONS = "com.cohenadair.anglerslog.PreviousSelections";

    private static final String WEATHER_UNITS = "weatherUnits";
    private static final String UNITS = "pref_units";

    private static SharedPreferences getPreviousSelections(Context context) {
        return context.getSharedPreferences(PREF_SELECTIONS, Context.MODE_PRIVATE);
    }

    private static SharedPreferences getDefaultPreferences(Context context) {
        return PreferenceManager.getDefaultSharedPreferences(context);
    }

    public static int getWeatherUnits(Context context) {
        return getPreviousSelections(context).getInt(WEATHER_UNITS, 0);
    }

    public static int getUnits(Context context) {
        return Integer.parseInt(getDefaultPreferences(context).getString(UNITS, Integer.toString(0)));
    }
}
