package com.cohenadair.mobile.legacy.user_defines;

import android.content.ContentValues;

import com.cohenadair.mobile.legacy.backup.Json;
import com.cohenadair.mobile.legacy.Utils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.UUID;

import static com.cohenadair.mobile.legacy.database.LogbookSchema.BaitPhotoTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.BaitTable;

/**
 * The Bait class represents a single bait used for fishing.
 * @author Cohen Adair
 */
public class Bait extends PhotoUserDefineObject {
    private BaitCategory mCategory;
    private String mColor;
    private String mSize;
    private String mDescription;
    private int mType = 0;

    //region Constructors
    public Bait(Bait bait, boolean keepId) {
        super(bait, keepId);
        mCategory = new BaitCategory(bait.getCategory(), true);
        mColor = bait.getColor();
        mSize = bait.getSize();
        mDescription = bait.getDescription();
        mType = bait.getType();
    }

    public Bait(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
        setPhotoTable(BaitPhotoTable.NAME);
    }
    //endregion

    //region Getters & Setters
    public BaitCategory getCategory() {
        return mCategory;
    }

    public void setCategory(BaitCategory category) {
        mCategory = category;
    }

    public String getColor() {
        return mColor;
    }

    public void setColor(String color) {
        mColor = Utils.stringOrNull(color);
    }

    public String getSize() {
        return mSize;
    }

    public void setSize(String size) {
        mSize = Utils.stringOrNull(size);
    }

    public String getDescription() {
        return mDescription;
    }

    public void setDescription(String description) {
        mDescription = Utils.stringOrNull(description);
    }

    public int getType() {
        return mType;
    }

    public void setType(int type) {
        mType = type;
    }
    //endregion

    public UUID getCategoryId() {
        if (mCategory != null)
            return mCategory.getId();
        return null;
    }

    public String getColorAsString() {
        return Utils.emptyStringOrString(mColor);
    }

    public String getSizeAsString() {
        return Utils.emptyStringOrString(mSize);
    }

    public String getDescriptionAsString() {
        return Utils.emptyStringOrString(mDescription);
    }

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(BaitTable.Columns.COLOR, mColor);
        values.put(BaitTable.Columns.DESCRIPTION, mDescription);
        values.put(BaitTable.Columns.SIZE, mSize);
        values.put(BaitTable.Columns.TYPE, mType);
        values.put(BaitTable.Columns.CATEGORY_ID, mCategory.getIdAsString());

        return values;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = super.toJson();

        json.put(Json.BAIT_CATEGORY, mCategory.getIdAsString());
        json.put(Json.COLOR, getColorAsString());
        json.put(Json.SIZE, getSizeAsString());
        json.put(Json.BAIT_DESCRIPTION, getDescriptionAsString());
        json.put(Json.BAIT_TYPE, getType());

        return json;
    }
}
