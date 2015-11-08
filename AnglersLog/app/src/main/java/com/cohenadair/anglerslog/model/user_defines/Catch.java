package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.text.format.DateFormat;

import com.cohenadair.anglerslog.database.QueryHelper;

import java.util.ArrayList;
import java.util.Date;
import java.util.Random;
import java.util.UUID;

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

    public Catch(Catch aCatch, boolean keepId) {
        super(aCatch, keepId);
        mDate = new Date(aCatch.getDate().getTime());
        mIsFavorite = aCatch.isFavorite();
        mSpecies = new Species(aCatch.getSpecies(), true); // keep the EXACT same species
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
        return mIsFavorite;
    }

    public void setIsFavorite(boolean isFavorite) {
        mIsFavorite = isFavorite;
    }
    //endregion

    @Override
    public String getName() {
        return getDateTimeAsString();
    }

    public String getSpeciesAsString() {
        return mSpecies.getName();
    }

    public String getDateAsString() {
        return DateFormat.format("MMMM dd, yyyy", mDate).toString();
    }

    public String getTimeAsString() {
        return DateFormat.format("h:mm a", mDate).toString();
    }

    public String getDateTimeAsString() {
        return DateFormat.format("MMM dd, yyyy 'at' h:mm a", mDate).toString();
    }

    //region Photo Manipulation
    public ArrayList<String> getPhotos() {
        return getPhotos(getId());
    }

    public void setPhotos(ArrayList<String> newPhotos) {
        ArrayList<String> oldPhotos = getPhotos();

        for (String oldPhoto : oldPhotos)
            removePhoto(oldPhoto);

        for (String newPhoto : newPhotos)
            addPhoto(newPhoto);
    }

    public ArrayList<String> getPhotos(UUID id) {
        return QueryHelper.queryPhotos(CatchPhotoTable.NAME, id);
    }

    public boolean addPhoto(String fileName) {
        return QueryHelper.insertQuery(CatchPhotoTable.NAME, getPhotoContentValues(fileName));
    }

    public boolean removePhoto(String fileName) {
        return QueryHelper.deletePhoto(CatchPhotoTable.NAME, fileName);
    }

    public int getPhotoCount() {
        return QueryHelper.photoCount(CatchPhotoTable.NAME, getId());
    }

    /**
     * Gets a random photo name that represents the entire Catch.
     * @return The name of a random photo.
     */
    public String getRandomPhoto() {
        ArrayList<String> photos = getPhotos();

        if (photos.size() <= 0)
            return null;

        return photos.get(new Random().nextInt(photos.size()));
    }

    /**
     * Generates a file name for the next photo to be added to the Catch's photos.
     * @param id The id to use for the name, or null to use this Catch's id. Useful for Catch
     *           editing.
     * @return The file name as String. Example "IMG_<mId>_<aRandomNumber>.png".
     */
    public String getNextPhotoName(UUID id) {
        id = (id == null) ? getId() : id;
        ArrayList<String> photos = getPhotos(id);
        Random random = new Random();
        int postfix = random.nextInt();

        while (true) {
            String name = "CATCH_" + id.toString() + "_" + postfix + ".jpg";

            if (photos.size() <= 0 || photos.indexOf(name) == -1)
                return name;

            postfix = random.nextInt();
        }
    }

    /**
     * See {@link #getNextPhotoName(UUID)}
     * @return A String representing a new photo file name for the Catch instance.
     */
    public String getNextPhotoName() {
        return getNextPhotoName(getId());
    }
    //endregion

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(CatchTable.Columns.DATE, mDate.getTime());
        values.put(CatchTable.Columns.IS_FAVORITE, mIsFavorite ? 1 : 0);
        values.put(CatchTable.Columns.SPECIES_ID, mSpecies.idAsString());

        return values;
    }

    public ContentValues getPhotoContentValues(String fileName) {
        ContentValues values = new ContentValues();

        values.put(CatchPhotoTable.Columns.USER_DEFINE_ID, getId().toString());
        values.put(CatchPhotoTable.Columns.NAME, fileName);

        return values;
    }
}
