package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.util.Log;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.backup.Json;
import com.cohenadair.anglerslog.utilities.Utils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.UserDefineTable;

/**
 * A UserDefineObject is the superclass for all "user defined" data such as species and locations.
 * @author Cohen Adair
 */
public class UserDefineObject {

    private static final String TAG = "UserDefineObject";

    private UUID mId;
    private String mName;
    private boolean mShouldDelete; // toggled on UI selection for deleting multiple items
    private boolean mIsSelected; // used to show selection in RecyclerView layouts

    public UserDefineObject(String name) {
        mId = UUID.randomUUID();
        mName = name;
    }

    public UserDefineObject(String name, UUID id) {
        mId = id;
        mName = name;
    }

    public UserDefineObject(UserDefineObject obj) {
        initFromObj(obj, false);
    }

    public UserDefineObject(UserDefineObject obj, boolean keepId) {
        initFromObj(obj, keepId);
    }

    public UserDefineObject(JSONObject jsonObject) {
        // importing from iOS will not have an id property
        try {
            mId = UUID.fromString(jsonObject.getString(Json.ID));
        } catch (JSONException e) {
            Log.e(TAG, "No JSON value for " + Json.ID);
            mId = UUID.randomUUID();
        }

        // importing from iOS will not have a name property for some subclasses
        try {
            mName = jsonObject.getString(Json.NAME);
        } catch (JSONException e) {
            Log.e(TAG, "No JSON value for " + Json.NAME);
            mName = getIdAsString();
        }
    }

    private void initFromObj(UserDefineObject obj, boolean keepId) {
        if (obj != null) {
            mId = keepId ? obj.getId() : UUID.randomUUID();
            mName = obj.getName();
            mShouldDelete = obj.getShouldDelete();
            mIsSelected = obj.getIsSelected();
        }
    }

    //region Getters & Setters
    public UUID getId() {
        return mId;
    }

    public void setId(UUID id) {
        mId = id;
    }

    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = (name == null || name.equals("")) ? null : name;
    }

    public boolean getShouldDelete() {
        return mShouldDelete;
    }

    public void setShouldDelete(boolean shouldDelete) {
        mShouldDelete = shouldDelete;
    }

    public boolean getIsSelected() {
        return mIsSelected;
    }

    public void setIsSelected(boolean isSelected) {
        mIsSelected = isSelected;
    }
    //endregion

    public void removeDatabaseProperties() {
        // if needed, should be overridden by subclasses
    }

    public final String getNameAsString() {
        return (mName == null) ? "" : mName;
    }

    public String getDisplayName() {
        return mName;
    }

    @NonNull
    public final String getIdAsString() {
        return mId.toString();
    }

    public String toString() {
        return (mName == null) ? super.toString() : getDisplayName();
    }

    public boolean isNameNull() {
        return mName == null || mName.equals("");
    }

    /**
     * @return An intent filled with extras of information that can be shared. This method should be
     *         overridden by subclasses that can be shared.
     */
    public Intent getShareIntent(Context context) {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.putExtra(Intent.EXTRA_TEXT, Logbook.getShareText(context));
        intent.setType(Utils.MIME_TYPE_IMAGE);
        return intent;
    }

    /**
     * Gets a {@link ContentValues} object for this UserDefineObject. This is used to save and
     * retrieve data from the backed SQLite database. Subclasses should override this method.
     *
     * @return A {@link ContentValues} object of this UserDefineObject.
     */
    public ContentValues getContentValues() {
        ContentValues values = new ContentValues();

        values.put(UserDefineTable.Columns.ID, getIdAsString());
        values.put(UserDefineTable.Columns.NAME, mName);
        values.put(UserDefineTable.Columns.SELECTED, mIsSelected);

        return values;
    }

    /**
     * Gets a {@link JSONObject} representation of this UserDefineObject. This is used for
     * {@link com.cohenadair.anglerslog.model.Logbook} exporting and importing. Subclasses should
     * override and call this method.
     *
     * @return A {@link JSONObject} of this UserDefineObject.
     * @throws JSONException Throws JSONException if the {@link JSONObject} cannot be created.
     */
    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();

        json.put(Json.NAME, getNameAsString());
        json.put(Json.ID, getIdAsString());

        return json;
    }

    /**
     * Converts the current object into a String of keywords that can be used for searching.
     * Subclasses should override this class.
     *
     * @return A String representing different keywords for the current object.
     */
    public String toKeywordsString(Context context) {
        return appendToBuilder(new StringBuilder(), mName).toString();
    }

    /**
     * Adds a String value to the given {@link StringBuilder}.
     */
    protected StringBuilder appendToBuilder(StringBuilder builder, String value) {
        if (Utils.stringOrNull(value) == null)
            return builder;

        builder.append(value);
        builder.append(" ");

        return builder;
    }

    /**
     * Adds a float value to the given {@link StringBuilder}.
     */
    protected StringBuilder appendToBuilder(StringBuilder builder, float value) {
        if (value < 0)
            return builder;

        return appendToBuilder(builder, Float.toString(value));
    }

    /**
     * Adds a int value to the given {@link StringBuilder}.
     */
    protected StringBuilder appendToBuilder(StringBuilder builder, int value) {
        return appendToBuilder(builder, (float)value);
    }
}
