package com.cohenadair.anglerslog.model;

import android.support.annotation.Nullable;
import android.util.Log;

import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineArray;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;
import java.util.Date;

/**
 * The Logbook class is a singleton class storing all of the user's log data.
 * @author Cohen Adair
 */
public class Logbook {

    private static final String TAG = "Logbook";

    //region Singleton Methods
    private static Logbook _sharedLogbook = new Logbook();

    public static Logbook getInstance() {
        return _sharedLogbook;
    }

    private Logbook() {

    }
    //endregion

    private String mName;
    private UserDefineArray mCatches = new UserDefineArray();
    private UserDefineArray mTrips = new UserDefineArray();
    private UserDefineArray mSpecies = new UserDefineArray();

    //region Getters & Setters
    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = name;
    }

    public ArrayList<UserDefineObject> getCatches() {
        return mCatches.getItems();
    }

    public void setCatches(ArrayList<UserDefineObject> catches) {
        mCatches.setItems(catches);
    }

    public ArrayList<UserDefineObject> getTrips() {
        return mTrips.getItems();
    }

    public void setTrips(ArrayList<UserDefineObject> trips) {
        mTrips.setItems(trips);
    }

    public ArrayList<UserDefineObject> getSpecies() {
        return mSpecies.getItems();
    }

    public void setSpecies(ArrayList<UserDefineObject> species) {
        mSpecies.setItems(species);
    }
    //endregion

    //region General Manipulation

    //endregion

    //region Catch Manipulation
    public boolean addCatch(Catch aCatch) {
        if (catchDated(aCatch.getDate()) != null) {
            Log.e(TAG, "A catch with date already exists!");
            return false;
        }

        return mCatches.add(aCatch);
    }

    public boolean removeCatch(Catch aCatch) {
        return mCatches.remove(aCatch);
    }

    /**
     * Looks for existing catches with aDate.
     * @param aDate the date of the resulting catch.
     * @return the catch with aDate or null if no such catch exists.
     */
    public Catch catchDated(Date aDate) {
        for (UserDefineObject obj : mCatches.getItems()) {
            Catch aCatch = (Catch)obj;
            if (Utils.datesEqualNoSeconds(aCatch.getDate(), aDate))
                return aCatch;
        }

        return null;
    }

    public Catch catchAtPos(int position) {
        return (Catch)mCatches.get(position);
    }

    /**
     * @return the number of catches in the Logbook.
     */
    public int catchCount() {
        return mCatches.size();
    }
    //endregion

    //region Trip Manipulation
    public boolean addTrip(Trip aTrip) {
        return mTrips.add(aTrip);
    }

    public boolean removeTrip(Trip aTrip) {
        return mTrips.remove(aTrip);
    }

    public int tripCount() {
        return mTrips.size();
    }

    public Trip tripAtPos(int position) {
        return (Trip)mTrips.get(position);
    }
    //endregion

    //region Species Manipulation
    public boolean addSpecies(Species species) {
        if (speciesNamed(species.getName()) != null) {
            Log.e(TAG, "A species with name already exists!");
            return false;
        }

        return mSpecies.add(species);
    }

    public void removeSpecies(int position) {
        mSpecies.remove(position);
    }

    public void editSpecies(int position, String newName) {
        speciesAtPos(position).edit(new Species(newName));
    }

    /**
     * Looks for existing species with aName.
     * @param name the name of the species to add.
     * @return the catch with aDate or null if no such catch exists.
     */
    public Species speciesNamed(String name) {
        return (Species)userDefineNamed(mSpecies, name);
    }

    /**
     * Iterates through all the species and removes ones where getShouldDelete() returns true.
     */
    public void cleanSpecies() {
        for (int i = speciesCount() - 1; i >= 0; i--) {
            if (speciesAtPos(i).getShouldDelete())
                removeSpecies(i);
        }
    }

    public int speciesCount() {
        return mSpecies.size();
    }

    public Species speciesAtPos(int position) {
        return (Species)mSpecies.get(position);
    }

    public ArrayList<CharSequence> speciesNames() {
        return mSpecies.nameList();
    }
    //endregion

    /**
     * Looks for a UserDefineObject with a specified name.
     * @param arr The UserDefineArray to look for the name.
     * @param name The name to look for.
     * @return The UserDefineObject with the given name or null if no such object exists.
     */
    @Nullable
    private UserDefineObject userDefineNamed(UserDefineArray arr, String name) {
        for (UserDefineObject obj : arr.getItems()) {
            if (name.equalsIgnoreCase(obj.getName()))
                return obj;
        }

        return null;
    }
}
