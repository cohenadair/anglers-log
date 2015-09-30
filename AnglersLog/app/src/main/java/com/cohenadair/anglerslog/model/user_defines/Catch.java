package com.cohenadair.anglerslog.model.user_defines;

import android.text.format.DateFormat;

import java.util.Date;

/**
 * The Catch class stores relative information for a single fishing catch.
 * @author Cohen Adair
 */
public class Catch extends UserDefineObject {

    private Date mDate;
    private Species mSpecies;

    public Catch(Date date) {
        super(date.toString());
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
        return speciesAsString() + " - " + dateTimeAsString();
    }

    public String speciesAsString() {
        return mSpecies.getName();
    }

    public String dateAsString() {
        return DateFormat.format("MMMM dd, yyyy", mDate).toString();
    }

    public String timeAsString() {
        return DateFormat.format("h:mm a", mDate).toString();
    }

    public String dateTimeAsString() {
        return DateFormat.format("MMM dd, yyyy 'at' h:mm a", mDate).toString();
    }
}
