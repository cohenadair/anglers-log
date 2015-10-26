package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.database.Cursor;
import android.text.format.DateFormat;

import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.model.Logbook;

import java.util.ArrayList;
import java.util.Date;
import java.util.Random;

import static com.cohenadair.anglerslog.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;

/**
 * The Catch class stores relative information for a single fishing catch.
 * @author Cohen Adair
 */
public class Catch extends UserDefineObject {

    private Date mDate;
    private Species mSpecies;
    private boolean mIsFavorite;

    public Catch(Date date) {
        super(date.toString());
        mDate = date;
    }

    public Catch(Catch aCatch) {
        super(aCatch);
        mDate = new Date(aCatch.getDate().getTime());
        mSpecies = new Species(aCatch.getSpecies(), true); // keep the EXACT same species
        mIsFavorite = aCatch.isFavorite();
    }

    public Catch(UserDefineObject obj) {
        super(obj);
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

    public boolean isFavorite() {
        Cursor cursor = QueryHelper.queryCatches(new String[] { CatchTable.Columns.IS_FAVORITE }, CatchTable.Columns.ID + " = ?", new String[] { getId().toString() });

        if (cursor.moveToFirst())
            mIsFavorite = cursor.getInt(cursor.getColumnIndex(CatchTable.Columns.IS_FAVORITE)) == 1;

        cursor.close();
        return mIsFavorite;
    }

    public void setIsFavorite(boolean isFavorite) {
        mIsFavorite = isFavorite;
        Logbook.editCatch(getId(), this);
    }
    //endregion

    @Override
    public String getName() {
        return dateTimeAsString();
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

    //region Photo Manipulation
    public ArrayList<String> getPhotos() {
        return QueryHelper.queryPhotos(CatchPhotoTable.NAME, CatchPhotoTable.Columns.NAME + " LIKE ?", new String[] { "%" + getId().toString() + "%" });
    }

    public boolean addPhoto(String fileName) {
        return Logbook.getDatabase().insert(CatchPhotoTable.NAME, null, getPhotoContentValues(fileName)) != -1;
    }

    public boolean removePhoto(String fileName) {
        return Logbook.getDatabase().delete(CatchPhotoTable.NAME, CatchPhotoTable.Columns.NAME + " = ?", new String[] { fileName }) == 1;
    }

    public int getPhotoCount() {
        return QueryHelper.queryCount(CatchPhotoTable.NAME, CatchPhotoTable.Columns.USER_DEFINE_ID + " = ?", new String[] { getId().toString() });
    }

    /**
     * Gets a random photo name that represents the entire Catch.
     * @return The name of a random photo.
     */
    public String randomPhoto() {
        ArrayList<String> photos = getPhotos();

        if (photos.size() <= 0)
            return null;

        return photos.get(new Random().nextInt(photos.size()));
    }

    /**
     * Generates a file name for the next photo to be added to the Catch's photos.
     * @return The file name as String. Example "IMG_<mId>_0.png".
     */
    public String getNextPhotoName() {
        ArrayList<String> photos = getPhotos();
        int postfix = 0;

        while (true) {
            String name = "CATCH_" + getId().toString() + "_" + postfix + ".jpg";

            if (photos.size() <= 0 || photos.indexOf(name) == -1)
                return name;

            postfix++;
        }
    }
    //endregion

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(CatchTable.Columns.DATE, mDate.getTime());
        values.put(CatchTable.Columns.IS_FAVORITE, mIsFavorite ? 1 : 0);

        if ((mSpecies != null))
            values.put(CatchTable.Columns.SPECIES_ID, mSpecies.getId().toString());

        return values;
    }

    public ContentValues getPhotoContentValues(String fileName) {
        ContentValues values = new ContentValues();

        values.put(CatchPhotoTable.Columns.USER_DEFINE_ID, getId().toString());
        values.put(CatchPhotoTable.Columns.NAME, fileName);

        return values;
    }

}
