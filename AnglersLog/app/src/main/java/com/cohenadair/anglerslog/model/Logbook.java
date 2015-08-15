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
    private ArrayList<Catch> entries = new ArrayList<Catch>();

    //region Getters & Setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public ArrayList<Catch> getEntries() {
        return entries;
    }

    public void setEntries(ArrayList<Catch> entries) {
        this.entries = entries;
    }
    //endregion

    //region Catch Manipulation
    public void addEntry(Catch aCatch) {
        this.entries.add(aCatch);
    }

    public void removeEntry(Catch aCatch) {
        this.entries.remove(aCatch);
    }

    /**
     * Looks for existing entries with aDate.
     * @param aDate the date of the resulting entry.
     * @return the entry with aDate or null if no such entry exists.
     */
    public Catch entryDated(Date aDate) {
        for (Catch aCatch : this.entries) {
            if (aCatch.getDate().equals(aDate))
                return aCatch;
        }

        return null;
    }

    /**
     * @return the number of entries in the Logbook.
     */
    public int entryCount() {
        return this.entries.size();
    }
    //endregion

}
