package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.text.format.DateFormat;

import com.cohenadair.anglerslog.utilities.Utils;

import java.util.Date;

import static com.cohenadair.anglerslog.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;

/**
 * The Catch class stores relative information for a single fishing catch.
 * @author Cohen Adair
 */
public class Catch extends PhotoUserDefineObject {

    private Date mDate;
    private Species mSpecies;
    private boolean mIsFavorite;
    private Bait mBait;

    //region Constructors
    public Catch(Date date) {
        super(Utils.getDisplayDate(date), CatchPhotoTable.NAME);
        mDate = date;
    }

    public Catch(Catch aCatch, boolean keepId) {
        super(aCatch, keepId);
        mDate = new Date(aCatch.getDate().getTime());
        mIsFavorite = aCatch.isFavorite();
        mSpecies = new Species(aCatch.getSpecies(), true);

        if (aCatch.getBait() != null)
            mBait = new Bait(aCatch.getBait(), true);
    }

    public Catch(UserDefineObject obj) {
        super(obj);
        setPhotoTable(CatchPhotoTable.NAME);
    }

    public Catch(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
        setPhotoTable(CatchPhotoTable.NAME);
    }
    //endregion

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

    public boolean isFavorite() {
        return mIsFavorite;
    }

    public void setIsFavorite(boolean isFavorite) {
        mIsFavorite = isFavorite;
    }

    public Bait getBait() {
        return mBait;
    }

    public void setBait(Bait bait) {
        mBait = bait;
    }
    //endregion

    @Override
    public String getName() {
        return getDateTimeAsString();
    }

    public String getSpeciesAsString() {
        return (mSpecies != null) ? mSpecies.getName() : "";
    }

    public String getBaitAsString() {
        return (mBait != null) ? mBait.getDisplayName() : "";
    }

    public String getDateAsString() {
        return Utils.getDisplayDate(mDate);
    }

    public String getTimeAsString() {
        return Utils.getDisplayTime(mDate);
    }

    public String getDateTimeAsString() {
        return DateFormat.format("MMM dd, yyyy 'at' h:mm a", mDate).toString();
    }

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(CatchTable.Columns.DATE, mDate.getTime());
        values.put(CatchTable.Columns.IS_FAVORITE, mIsFavorite ? 1 : 0);
        values.put(CatchTable.Columns.SPECIES_ID, mSpecies.idAsString());

        if (mBait != null)
            values.put(CatchTable.Columns.BAIT_ID, mBait.idAsString());

        return values;
    }
}
