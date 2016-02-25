package com.cohenadair.anglerslog.model.utilities;

import android.content.Context;
import android.support.annotation.NonNull;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.Comparator;

/**
 * SortingUtils is a utility class that defines different {@link SortingMethod} instances that are
 * used throughout the application.
 *
 * @author Cohen Adair
 */
public class SortingUtils {

    private static Context mContext;

    public static void init(Context context) {
        mContext = context;
    }

    @NonNull
    public static SortingMethod bySpecies() {
        return new SortingMethod(getString(R.string.species), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                String lhSpecies = ((Catch)lhs).getSpeciesAsString();
                String rhSpecies = ((Catch)rhs).getSpeciesAsString();

                return lhSpecies.compareTo(rhSpecies);
            }
        });
    }

    /**
     * Gets an array of {@link SortingMethod} display names from a given {@link SortingMethod}
     * array.
     */
    public static CharSequence[] getDialogOptions(SortingMethod[] methods) {
        CharSequence[] result = new CharSequence[methods.length];

        for (int i = 0; i < methods.length; i++)
            result[i] = methods[i].getDisplayText();

        return result;
    }

    @NonNull
    private static String getString(int resId) {
        return mContext.getResources().getString(resId);
    }
}
