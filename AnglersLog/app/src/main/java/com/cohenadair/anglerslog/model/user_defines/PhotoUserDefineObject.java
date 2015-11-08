package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import com.cohenadair.anglerslog.database.QueryHelper;

import java.util.ArrayList;
import java.util.Random;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.PhotoTable;

/**
 * An abstract class for a UserDefineObject subclass that includes photos added by the user.
 * Created by Cohen Adair on 2015-11-08.
 */
public abstract class PhotoUserDefineObject extends UserDefineObject {

    private String mPhotoTable;

    //region Constructors
    public PhotoUserDefineObject(String name, String photoTable) {
        super(name);
        mPhotoTable = photoTable;
    }

    public PhotoUserDefineObject(PhotoUserDefineObject obj, boolean keepId) {
        super(obj, keepId);
        mPhotoTable = obj.getPhotoTable();
    }

    public PhotoUserDefineObject(UserDefineObject obj) {
        super(obj);
    }
    //endregion

    //region Getters & Setters
    public String getPhotoTable() {
        return mPhotoTable;
    }

    public void setPhotoTable(String photoTable) {
        mPhotoTable = photoTable;
    }
    //endregion

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
        return QueryHelper.queryPhotos(mPhotoTable, id);
    }

    public boolean addPhoto(String fileName) {
        return QueryHelper.insertQuery(mPhotoTable, getPhotoContentValues(fileName));
    }

    public boolean removePhoto(String fileName) {
        return QueryHelper.deletePhoto(mPhotoTable, fileName);
    }

    public int getPhotoCount() {
        return QueryHelper.photoCount(mPhotoTable, getId());
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
            String name = mPhotoTable + "_" + id.toString() + "_" + postfix + ".jpg";

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

    public ContentValues getPhotoContentValues(String fileName) {
        ContentValues values = new ContentValues();

        values.put(PhotoTable.Columns.USER_DEFINE_ID, getId().toString());
        values.put(PhotoTable.Columns.NAME, fileName);

        return values;
    }
}
