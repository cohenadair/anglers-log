package com.cohenadair.anglerslog.model.user_defines;

import android.text.format.DateFormat;
import android.util.Log;

import java.util.ArrayList;
import java.util.Date;
import java.util.Random;

/**
 * The Catch class stores relative information for a single fishing catch.
 * @author Cohen Adair
 */
public class Catch extends UserDefineObject {

    private final String TAG = "Catch";

    private Date mDate;
    private Species mSpecies;
    private boolean mIsFavorite;
    private ArrayList<String> mPhotoFileNames = new ArrayList<>();

    public Catch(Date date) {
        super(date.toString());
        mDate = date;
    }

    public Catch(Catch aCatch) {
        super(aCatch);
        mDate = new Date(aCatch.getDate().getTime());
        mSpecies = new Species(aCatch.getSpecies());
        mIsFavorite = aCatch.isFavorite();
        mPhotoFileNames = new ArrayList<>(aCatch.getPhotoFileNames());
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

    public ArrayList<String> getPhotoFileNames() {
        return mPhotoFileNames;
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

    //region Photo Manipulation
    public void addPhoto() {
        String next = nextPhotoFileName();

        if (mPhotoFileNames.indexOf(next) > -1) {
            Log.e(TAG, "Photo path already exists in Catch.");
            return;
        }

        mPhotoFileNames.add(nextPhotoFileName());
    }

    public void removePhoto(String fileName) {
        mPhotoFileNames.remove(fileName);
    }

    public void removePhoto(int position) {
        mPhotoFileNames.remove(position);
    }

    public int photoCount() {
        return mPhotoFileNames.size();
    }

    public String photoAtPos(int position) {
        return mPhotoFileNames.get(position);
    }

    /**
     * Gets a random photo name that represents the entire Catch.
     * @return The name of a random photo.
     */
    public String randomPhoto() {
        if (photoCount() <= 0)
            return null;

        return photoAtPos(new Random().nextInt(photoCount()));
    }

    /**
     * Generates a file name for the next photo to be added to the Catch's photos.
     * @return The file name as String. Example "IMG_<mId>_0.png".
     */
    public String nextPhotoFileName() {
        for (int i = 0; i < mPhotoFileNames.size(); i++) {
            String name = "IMG_" + getId().toString() + "_" + i + ".jpg";
            if (mPhotoFileNames.indexOf(name) == -1)
                return name;
        }

        return "IMG_" + getId().toString() + "_" + mPhotoFileNames.size() + ".jpg";
    }
    //endregion
}
