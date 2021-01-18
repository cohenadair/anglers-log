package com.cohenadair.mobile.legacy.user_defines;

import com.cohenadair.mobile.legacy.database.QueryHelper;
import com.cohenadair.mobile.legacy.backup.Json;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.UUID;

/**
 * An abstract class for a UserDefineObject subclass that includes photos added by the user.
 * @author Cohen Adair
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
     * @return An array of photos associated with the given id.
     */
    public ArrayList<String> getPhotos(UUID id) {
        return QueryHelper.queryPhotos(mPhotoTable, id);
    }

    public boolean removePhoto(String fileName) {
        return QueryHelper.deletePhoto(mPhotoTable, fileName);
    }
    //endregion

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
