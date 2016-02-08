package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.content.Context;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.backup.Json;

import org.apache.commons.io.FilenameUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;

/**
 * The Bait class represents a single bait used for fishing.
 *
 * Created by Cohen Adair on 2015-11-03.
 */
public class Bait extends PhotoUserDefineObject {

    /**
     * Correspond to resources array in arrays.xml.
     */
    // TODO convert to enum (see Catch.java)
    public static final int TYPE_ARTIFICIAL = 0;
    public static final int TYPE_LIVE = 1;
    public static final int TYPE_REAL = 2;

    private BaitCategory mCategory;
    private String mColor;
    private String mSize;
    private String mDescription;
    private int mType = 0;

    //region Constructors
    public Bait() {
        this(null, null);
    }

    public Bait(String name, BaitCategory category) {
        super(name, BaitPhotoTable.NAME);
        mCategory = category;
    }

    public Bait(Bait bait, boolean keepId) {
        super(bait, keepId);
        mCategory = new BaitCategory(bait.getCategory(), true);
        mColor = bait.getColor();
        mSize = bait.getSize();
        mDescription = bait.getDescription();
        mType = bait.getType();
    }

    public Bait(UserDefineObject obj) {
        super(obj);
        setPhotoTable(BaitPhotoTable.NAME);
    }

    public Bait(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
        setPhotoTable(BaitPhotoTable.NAME);
    }

    public Bait(JSONObject jsonObject) throws JSONException {
        this(jsonObject.getString(Json.NAME), null);

        // importing from iOS will have no associated BaitCategory
        BaitCategory baitCategory = null;
        try {
            String baitCategoryName = jsonObject.getString(Json.BAIT_CATEGORY);
            baitCategory = Logbook.getBaitCategory(baitCategoryName);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        // if there is no import category use "Other"
        // create "Other" if it doesn't already exist
        if (baitCategory == null) {
            baitCategory = Logbook.getBaitCategory("Other");
            if (baitCategory == null) {
                baitCategory = new BaitCategory("Other");
                Logbook.addBaitCategory(baitCategory);
            }
        }

        mCategory = baitCategory;
        mDescription = Json.stringOrNull(jsonObject.getString(Json.BAIT_DESCRIPTION));
        mSize = Json.stringOrNull(jsonObject.getString(Json.SIZE));
        mColor = Json.stringOrNull(jsonObject.getString(Json.COLOR));
        mType = jsonObject.getInt(Json.BAIT_TYPE);

        JSONObject jsonImage = jsonObject.getJSONObject(Json.IMAGE);
        try {
            String name = FilenameUtils.getName(jsonImage.getString(Json.IMAGE_PATH));
            addPhoto(name);
        } catch (JSONException e) {
            e.printStackTrace();
        }
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
        mColor = color;
    }

    public String getSize() {
        return mSize;
    }

    public void setSize(String size) {
        mSize = size;
    }

    public String getDescription() {
        return mDescription;
    }

    public void setDescription(String description) {
        mDescription = description;
    }

    public int getType() {
        return mType;
    }

    public void setType(int type) {
        mType = type;
    }

    @Override
    public void setIsSelected(boolean isSelected) {
        super.setIsSelected(isSelected);
        Logbook.editBait(getId(), this);
    }
    //endregion

    //region Catch Manipulation
    public ArrayList<UserDefineObject> getCatches() {
        UserDefineCursor cursor = QueryHelper.queryUserDefines(CatchTable.NAME, CatchTable.Columns.BAIT_ID + " = ?", new String[] { idAsString() });

        return QueryHelper.queryUserDefines(cursor, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new CatchCursor(cursor).getCatch();
            }
        });
    }

    public int getCatchCount() {
        return getCatches().size();
    }

    public String getCatchCountAsString(Context context) {
        int count = getCatchCount();
        String catchesStr = count == 1 ? context.getResources().getString(R.string.catch_string) : context.getResources().getString(R.string.drawer_catches);
        return count + " " + catchesStr;
    }
    //endregion

    public String getCategoryName() {
        if (mCategory != null)
            return mCategory.getName();
        return null;
    }

    public UUID getCategoryId() {
        if (mCategory != null)
            return mCategory.getId();
        return null;
    }

    @Override
    public String getDisplayName() {
        return mCategory.getName() + " - " + getName();
    }

    public int getTypeName() {
        if (mType == TYPE_ARTIFICIAL)
            return R.string.artificial;
        else if (mType == TYPE_LIVE)
            return R.string.live;
        else if (mType == TYPE_REAL)
            return R.string.real;

        return -1;
    }

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(BaitTable.Columns.COLOR, mColor);
        values.put(BaitTable.Columns.DESCRIPTION, mDescription);
        values.put(BaitTable.Columns.SIZE, mSize);
        values.put(BaitTable.Columns.TYPE, mType);
        values.put(BaitTable.Columns.CATEGORY_ID, mCategory.idAsString());

        return values;
    }
}
