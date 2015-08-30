package com.cohenadair.anglerslog.model;

import com.cohenadair.anglerslog.model.user_defines.Species;

import java.util.Date;

/**
 * The Catch class stores relative information for a single fishing catch.
 * @author Cohen Adair
 */
public class Catch {

    private Date date;
    private Species species;

    public Catch(Date date) {
        this.date = date;
    }

    //region Getters & Setters
    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public Species getSpecies() {
        return species;
    }

    public void setSpecies(Species species) {
        this.species = species;
    }
    //endregion

    @Override
    public String toString() {
        return this.speciesAsString() + ", " + this.dateAsString();
    }

    public String speciesAsString() {
        return this.species.getName();
    }

    public String dateAsString() {
        return this.date.toString();
    }
}
