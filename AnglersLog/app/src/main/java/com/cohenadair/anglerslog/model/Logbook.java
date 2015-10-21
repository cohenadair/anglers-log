package com.cohenadair.anglerslog.model;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.Log;

import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineArray;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.cohenadair.anglerslog.utilities.Utils;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;

/**
 * The Logbook class is a monostate class storing all of the user's log data.
 * @author Cohen Adair
 */
public class Logbook {

    /**
     * For Log calls.
     */
    private static final String TAG = "Logbook";

    private static Context mContext;
    private static String mName;
    private static UserDefineArray mCatches = new UserDefineArray();
    private static UserDefineArray mTrips = new UserDefineArray();
    private static UserDefineArray mSpecies = new UserDefineArray();

    private Logbook() {

    }

    //region Getters & Setters

    public static void setContext(Context mContext) {
        Logbook.mContext = mContext;
    }

    public static String getName() {
        return mName;
    }

    public static void setName(String name) {
        mName = name;
    }

    public static ArrayList<UserDefineObject> getCatches() {
        return mCatches.getItems();
    }

    public static ArrayList<UserDefineObject> getTrips() {
        return mTrips.getItems();
    }

    public static ArrayList<UserDefineObject> getSpecies() {
        return mSpecies.getItems();
    }

    public static void setSpecies(ArrayList<UserDefineObject> species) {
        mSpecies.setItems(species);
    }
    //endregion

    //region General Manipulation

    //endregion

    //region Catch Manipulation
    public static boolean addCatch(Catch aCatch) {
        if (catchDated(aCatch.getDate()) != null) {
            Log.e(TAG, "A catch with date already exists!");
            return false;
        }

        return mCatches.add(aCatch);
    }

    public static boolean removeCatch(Catch aCatch) {
        return mCatches.remove(aCatch);
    }

    public static boolean removeCatchAtPos(int position) {
        return removeCatch(catchAtPos(position));
    }

    public static void editCatchAtPos(int position, Catch newCatch) {
        mCatches.set(position, newCatch);
    }

    /**
     * Looks for existing catches with aDate.
     * @param aDate the date of the resulting catch.
     * @return the catch with aDate or null if no such catch exists.
     */
    @Nullable
    public static Catch catchDated(Date aDate) {
        for (UserDefineObject obj : mCatches.getItems()) {
            Catch aCatch = (Catch)obj;
            if (Utils.datesEqualNoSeconds(aCatch.getDate(), aDate))
                return aCatch;
        }

        return null;
    }

    public static Catch catchAtPos(int position) {
        return (Catch)mCatches.get(position);
    }

    /**
     * @return the number of catches in the Logbook.
     */
    public static int catchCount() {
        return mCatches.size();
    }

    public static File catchPhotoFile(Catch aCatch) {
        return PhotoUtils.privatePhotoFile(mContext, aCatch.nextPhotoFileName());
    }
    //endregion

    //region Trip Manipulation
    public static boolean addTrip(Trip aTrip) {
        return mTrips.add(aTrip);
    }

    public static boolean removeTrip(Trip aTrip) {
        return mTrips.remove(aTrip);
    }

    public static int tripCount() {
        return mTrips.size();
    }

    public static Trip tripAtPos(int position) {
        return (Trip)mTrips.get(position);
    }
    //endregion

    //region Species Manipulation
    public static boolean addSpecies(Species species) {
        if (speciesNamed(species.getName()) != null) {
            Log.e(TAG, "A species with name already exists!");
            return false;
        }

        return mSpecies.add(species);
    }

    public static void removeSpecies(int position) {
        mSpecies.remove(position);
    }

    public static void editSpecies(int position, String newName) {
        speciesAtPos(position).edit(new Species(newName));
    }

    /**
     * Looks for existing species with aName.
     * @param name the name of the species to add.
     * @return the catch with aDate or null if no such catch exists.
     */
    public static Species speciesNamed(String name) {
        return (Species)userDefineNamed(mSpecies, name);
    }

    /**
     * Iterates through all the species and removes ones where getShouldDelete() returns true.
     */
    public static void cleanSpecies() {
        for (int i = speciesCount() - 1; i >= 0; i--) {
            if (speciesAtPos(i).getShouldDelete())
                removeSpecies(i);
        }
    }

    public static int speciesCount() {
        return mSpecies.size();
    }

    public static Species speciesAtPos(int position) {
        return (Species)mSpecies.get(position);
    }
    //endregion

    /**
     * Looks for a UserDefineObject with a specified name.
     * @param arr The UserDefineArray to look for the name.
     * @param name The name to look for.
     * @return The UserDefineObject with the given name or null if no such object exists.
     */
    @Nullable
    private static UserDefineObject userDefineNamed(UserDefineArray arr, String name) {
        for (UserDefineObject obj : arr.getItems()) {
            if (name.equalsIgnoreCase(obj.getName()))
                return obj;
        }

        return null;
    }
}
