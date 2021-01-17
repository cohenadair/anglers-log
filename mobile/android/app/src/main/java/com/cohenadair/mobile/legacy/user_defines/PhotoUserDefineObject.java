package com.cohenadair.mobile.legacy.user_defines;

import android.content.ContentValues;

import com.cohenadair.mobile.legacy.database.QueryHelper;
import com.cohenadair.mobile.legacy.backup.Json;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Random;
import java.util.UUID;

import static com.cohenadair.mobile.legacy.database.LogbookSchema.PhotoTable;

/**
 * An abstract class for a UserDefineObject subclass that includes photos added by the user.
 * @author Cohen Adair
 */
public abstract class PhotoUserDefineObject extends UserDefineObject {

    private static final String TAG = "PhotoUserDefineObject";

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

    /**
     * Resets photos by first removing all old ones, the adding the new ones.
     * @param newPhotos The collection new photos.
     */
    public void setPhotos(ArrayList<String> newPhotos) {
        ArrayList<String> oldPhotos = getPhotos();

        for (String oldPhoto : oldPhotos)
            removePhoto(oldPhoto);

        for (String newPhoto : newPhotos)
            addPhoto(newPhoto);
    }

    /**
     * @return An array of photos associated with the given id.
     * @see #getNextPhotoName(UUID)
     */
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
        return QueryHelper.getPhotoCount(mPhotoTable, getId());
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
     * Generates a file name for the next photo to be added to the object's photos.
     *
     * @param id The id to use for the name, or null to use this object's id. Useful for instances
     *           such as {@link Catch} editing.
     * @return The file name as String. Example "IMG_<mId>_<aRandomNumber>.png".
     */
    public String getNextPhotoName(UUID id) {
        id = (id == null) ? getId() : id;
        ArrayList<String> photos = getPhotos(id);
        Random random = new Random();
        int postfix = random.nextInt();

        // loop prevents unlikely duplicates
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
     * {@inheritDoc}
     *
     * To keep iOS and Core Data compatibility, a simple JSON String array is not used here.
     */
    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = super.toJson();
        ArrayList<String> photos = getPhotos();

        // the "instanceof" checks are required here for iOS compatibility
        // in the iOS version, a JSON array is used for Catch photos, but a single JSON object
        // is used for the Bait photo

        if (this instanceof Catch) {
            JSONArray jsonPhotos = new JSONArray();

            for (String photo : photos)
                jsonPhotos.put(getPhotoJson(photo, true));

            json.put(Json.IMAGES, jsonPhotos);
        }

        if (this instanceof Bait)
            json.put(Json.IMAGE, getPhotoJson(photos.size() > 0 ? photos.get(0) : "", false));

        return json;
    }

    private JSONObject getPhotoJson(String photo, boolean isCatch) throws JSONException {
        JSONObject jsonPhoto = new JSONObject();

        if (!photo.isEmpty()) {
            // the "Images/" prepend is to keep iOS compatibility
            jsonPhoto.put(Json.IMAGE_PATH, "Images/" + photo);

            // these are for iOS Core Data compatibility
            jsonPhoto.put(Json.ENTRY_DATE, isCatch ? ((Catch) this).getDateJsonString() : "");
            jsonPhoto.put(Json.BAIT_NAME, isCatch ? "" : getNameAsString());
        }

        return jsonPhoto;
    }
}
