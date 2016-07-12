package com.cohenadair.anglerslog.model.utilities;

import android.content.Context;
import android.support.annotation.NonNull;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.Comparator;
import java.util.Date;

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
    public static SortingMethod byName() {
        return new SortingMethod(getString(R.string.name), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                return lhs.getName().compareTo(rhs.getName());
            }
        });
    }

    @NonNull
    public static SortingMethod byDisplayName() {
        return new SortingMethod(getString(R.string.name), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                return lhs.getDisplayName().compareTo(rhs.getDisplayName());
            }
        });
    }

    @NonNull
    public static SortingMethod bySpecies() {
        return new SortingMethod(getString(R.string.species), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                String lhValue = ((Catch)lhs).getSpeciesAsString();
                String rhValue = ((Catch)rhs).getSpeciesAsString();

                return lhValue.compareTo(rhValue);
            }
        });
    }

    @NonNull
    public static SortingMethod byLocation() {
        return new SortingMethod(getString(R.string.location), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                String lhValue = ((Catch)lhs).getFishingSpotAsString();
                String rhValue = ((Catch)rhs).getFishingSpotAsString();

                return lhValue.compareTo(rhValue);
            }
        });
    }

    @NonNull
    public static SortingMethod byFavorite() {
        return new SortingMethod(getString(R.string.favorite), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                Boolean lhValue = ((Catch)lhs).isFavorite();
                Boolean rhValue = ((Catch)rhs).isFavorite();

                return lhValue.compareTo(rhValue) * -1;
            }
        });
    }

    @NonNull
    public static SortingMethod byNumberOfCatches() {
        return new SortingMethod(getString(R.string.number_of_catches), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                Integer lhValue = ((HasCatchesInterface)lhs).getFishCaughtCount();
                Integer rhValue = ((HasCatchesInterface)rhs).getFishCaughtCount();

                return lhValue.compareTo(rhValue) * -1;
            }
        });
    }

    @NonNull
    public static SortingMethod byNumberOfFishingSpots() {
        return new SortingMethod(getString(R.string.number_of_fishing_spots), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                Integer lhValue = ((Location)lhs).getFishingSpotCount();
                Integer rhValue = ((Location)rhs).getFishingSpotCount();

                return lhValue.compareTo(rhValue) * -1;
            }
        });
    }

    @NonNull
    public static SortingMethod byNewestToOldest() {
        return new SortingMethod(getString(R.string.newest_to_oldest), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                Date lhValue = ((HasDateInterface)lhs).getDate();
                Date rhValue = ((HasDateInterface)rhs).getDate();

                return lhValue.compareTo(rhValue) * -1;
            }
        });
    }

    @NonNull
    public static SortingMethod byOldestToNewest() {
        return new SortingMethod(getString(R.string.oldest_to_newest), new Comparator<UserDefineObject>() {
            @Override
            public int compare(UserDefineObject lhs, UserDefineObject rhs) {
                Date lhValue = ((HasDateInterface)lhs).getDate();
                Date rhValue = ((HasDateInterface)rhs).getDate();

                return lhValue.compareTo(rhValue);
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
