package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.model.backup.Json;

import org.apache.commons.io.FilenameUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

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
        init(photoTable);
    }

    public PhotoUserDefineObject(PhotoUserDefineObject obj, boolean keepId) {
        super(obj, keepId);
        init(obj.getPhotoTable());
    }

    public PhotoUserDefineObject(UserDefineObject obj) {
        super(obj);
    }

    public PhotoUserDefineObject(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

    public PhotoUserDefineObject(JSONObject jsonObject, String photoTable) throws JSONException {
        super(jsonObject);
        init(photoTable);

        JSONArray images = jsonObject.getJSONArray(Json.IMAGES);
        for (int i = 0; i < images.length(); i++) {
            JSONObject image = images.getJSONObject(i);
            addPhoto(FilenameUtils.getName(image.getString(Json.IMAGE_PATH)));
        }
    }

    private void init(String photoTable) {
        mPhotoTable = photoTable;
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

    /**
     * To keep iOS and Core Data compatibility, a simple JSON String array is not used here.
     */
    public JSONObject toJson() throws JSONException {
        JSONObject json = super.toJson();

        ArrayList<String> photos = getPhotos();
        JSONArray jsonPhotos = new JSONArray();

        for (String photo : photos) {
            JSONObject jsonPhoto = new JSONObject();

            jsonPhoto.put(Json.IMAGE_PATH, photo);

            // these are for iOS Core Data compatibility
            jsonPhoto.put(Json.ENTRY_DATE, (this instanceof Catch) ? ((Catch)this).getDateJsonString() : "");
            jsonPhoto.put(Json.BAIT_NAME, (this instanceof Bait) ? this.getNameAsString() : "");

            jsonPhotos.put(jsonPhoto);
        }

        json.put(Json.IMAGES, jsonPhotos);
        return json;
    }
}
