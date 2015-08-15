package com.cohenadair.anglerslog.model;

import java.util.ArrayList;
import java.util.Date;

/**
 * The Logbook class is a singleton class storing all of the user's log data.
 * @author Cohen Adair
 */
public class Logbook {

    //region Singleton Methods
    private static Logbook _sharedLogbook = new Logbook();

    public static Logbook getSharedLogbook() {
        return _sharedLogbook;
    }

    private Logbook() {

    }
    //endregion

    private String name;
    private ArrayList<Catch> catches = new ArrayList<Catch>();

    //region Getters & Setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public ArrayList<Catch> getCatches() {
        return catches;
    }

    public void setCatches(ArrayList<Catch> catches) {
        this.catches = catches;
    }

    //endregion

    //region Catch Manipulation
    public void addCatch(Catch aCatch) {
        this.catches.add(aCatch);
    }

    public void removeCatch(Catch aCatch) {
        this.catches.remove(aCatch);
    }

    /**
     * Looks for existing catches with aDate.
     * @param aDate the date of the resulting catch.
     * @return the catch with aDate or null if no such catch exists.
     */
    public Catch catchDated(Date aDate) {
        for (Catch aCatch : this.catches) {
            if (aCatch.getDate().equals(aDate))
                return aCatch;
        }

        return null;
    }

    /**
     * @return the number of catches in the Logbook.
     */
    public int catchCount() {
        return this.catches.size();
    }
    //endregion

}
