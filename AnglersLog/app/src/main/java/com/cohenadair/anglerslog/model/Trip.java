package com.cohenadair.anglerslog.model;

/**
 * The Trip class manages all data associated with a single trip. A trip is added (optionally) by
 * the user.
 *
 * Created by Cohen Adair on 2015-09-05.
 */
public class Trip {

    private String mName;

    public Trip(String aName) {
        setName(aName);
    }

    //region Getters & Setters
    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = name;
    }
    //endregion

    @Override
    public String toString() {
        return mName;
    }
}
