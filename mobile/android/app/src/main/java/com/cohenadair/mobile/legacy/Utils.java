package com.cohenadair.mobile.legacy;

import android.content.Context;
import android.text.format.DateFormat;

import androidx.annotation.NonNull;

import java.util.Date;

/**
 * A set of utility methods used throughout the project.
 * @author Cohen Adair
 */
public class Utils {
    @NonNull
    public static String getLongDisplayDate(Date date, Context context) {
        return DateFormat.getLongDateFormat(context).format(date);
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
}
