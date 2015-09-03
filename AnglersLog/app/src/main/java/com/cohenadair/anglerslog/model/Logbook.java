package com.cohenadair.anglerslog.model;

import android.app.Activity;
import android.util.Log;
import android.widget.ArrayAdapter;

import java.util.ArrayList;
import java.util.Date;

/**
 * The Logbook class is a singleton class storing all of the user's log data.
 * @author Cohen Adair
 */
public class Logbook {

    //region Singleton Methods
    private static Logbook _sharedLogbook = new Logbook();

    public static Logbook getInstance() {
        return _sharedLogbook;
    }

    private Logbook() {

    }
    //endregion
    
    public static final int DATA_CATCHES = 0;

    private String mName;
    private ArrayList<Catch> mCatches = new ArrayList<Catch>();

    // used to persist user catch selection over orientation and activity changes
    private int currentCatchPos;

    //region Getters & Setters
    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = name;
    }

    public ArrayList<Catch> getCatches() {
        return mCatches;
    }

    public void setCatches(ArrayList<Catch> catches) {
        mCatches = catches;
    }

    public int getCurrentCatchPos() {
        return currentCatchPos;
    }

    public void setCurrentCatchPos(int currentCatchPos) {
        this.currentCatchPos = currentCatchPos;
    }

    //endregion

    //region Catch Manipulation
    public void addCatch(Catch aCatch) {
        mCatches.add(aCatch);
    }

    public void removeCatch(Catch aCatch) {
        mCatches.remove(aCatch);
    }

    /**
     * Looks for existing catches with aDate.
     * @param aDate the date of the resulting catch.
     * @return the catch with aDate or null if no such catch exists.
     */
    public Catch catchDated(Date aDate) {
        for (Catch aCatch : mCatches) {
            if (aCatch.getDate().equals(aDate))
                return aCatch;
        }

        return null;
    }

    public Catch catchAtPos(int pos) {
        return mCatches.get(pos);
    }

    /**
     * @return the number of catches in the Logbook.
     */
    public int catchCount() {
        return mCatches.size();
    }
    //endregion

    /**
     * Used for communication between activities and fragments. An id is passed in a Bundle between
     * the activity and fragment.
     * @param anActivity the activity the adapter is applied to.
     * @param aDataId the id of the data to create an adapter from. See {@link #DATA_CATCHES}
     * @return an ArrayAdapter based off the data id provided.
     */
    public ArrayAdapter adapterForData(Activity anActivity, int aDataId) {
        switch (aDataId) {
            case DATA_CATCHES:
                return new ArrayAdapter<Catch>(anActivity, android.R.layout.simple_list_item_1, mCatches);
            default:
                Log.e("Logbook.arrayForData", "Invalid dataId");
                break;
        }

        return null;
    }

}
