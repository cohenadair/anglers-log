package com.cohenadair.anglerslog.model;

import com.cohenadair.anglerslog.utilities.FragmentUtils;

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

    private String mName;
    private ArrayList<Catch> mCatches = new ArrayList<Catch>();

    // used to persist user selection
    private int mCurrentCatchPos = 0;
    private int mCurrentFragmentId = FragmentUtils.FRAGMENT_CATCHES; // default starting fragment

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
        return mCurrentCatchPos;
    }

    public void setCurrentCatchPos(int currentCatchPos) {
        this.mCurrentCatchPos = currentCatchPos;
    }

    public int getCurrentFragmentId() {
        return mCurrentFragmentId;
    }

    public void setCurrentFragmentId(int currentFragmentId) {
        mCurrentFragmentId = currentFragmentId;
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

}
