package com.cohenadair.anglerslog.model.user_defines;

import java.util.Date;

/**
 * The Catch class stores relative information for a single fishing catch.
 * @author Cohen Adair
 */
public class Catch {

    private Date mDate;
    private Species mSpecies;

    public Catch(Date date) {
        mDate = date;
    }

    //region Getters & Setters
    public Date getDate() {
        return mDate;
    }

    public void setDate(Date date) {
        mDate = date;
    }

    public Species getSpecies() {
        return mSpecies;
    }

    public void setSpecies(Species species) {
        mSpecies = species;
    }
    //endregion

    @Override
    public String toString() {
        return speciesAsString() + ", " + dateAsString();
    }

    public String speciesAsString() {
        return mSpecies.getName();
    }

    public String dateAsString() {
        return mDate.toString();
    }
}
