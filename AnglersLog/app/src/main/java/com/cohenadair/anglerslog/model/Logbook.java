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

    public ArrayList<Catch> getEntries() {
        return catches;
    }

    public void setEntries(ArrayList<Catch> entries) {
        this.catches = entries;
    }
    //endregion

    //region Catch Manipulation
    public void addEntry(Catch aCatch) {
        this.catches.add(aCatch);
    }

    public void removeEntry(Catch aCatch) {
        this.catches.remove(aCatch);
    }

    /**
     * Looks for existing entries with aDate.
     * @param aDate the date of the resulting entry.
     * @return the entry with aDate or null if no such entry exists.
     */
    public Catch entryDated(Date aDate) {
        for (Catch aCatch : this.catches) {
            if (aCatch.getDate().equals(aDate))
                return aCatch;
        }

        return null;
    }

    /**
     * @return the number of entries in the Logbook.
     */
    public int catchCount() {
        return this.catches.size();
    }
    //endregion

}
