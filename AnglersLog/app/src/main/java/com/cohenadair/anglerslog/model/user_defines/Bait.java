package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.backup.Json;
import com.cohenadair.anglerslog.model.backup.JsonImporter;
import com.cohenadair.anglerslog.model.utilities.HasCatchesInterface;
import com.cohenadair.anglerslog.utilities.Utils;

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
 * @author Cohen Adair
 */
public class Bait extends PhotoUserDefineObject implements HasCatchesInterface {

    private static final String TAG = "Bait";

    /**
     * Correspond to resources array in arrays.xml.
     */
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
        super(jsonObject, BaitPhotoTable.NAME);

        mCategory = JsonImporter.baitCategoryOrOther(jsonObject);
        mDescription = Utils.stringOrNull(jsonObject.getString(Json.BAIT_DESCRIPTION));
        mSize = Utils.stringOrNull(jsonObject.getString(Json.SIZE));
        mColor = Utils.stringOrNull(jsonObject.getString(Json.COLOR));
        mType = jsonObject.getInt(Json.BAIT_TYPE);

        // only check for a single image if there wasn't a Json.IMAGES array
        // the check for Json.IMAGES is done in the call to the super's method
        if (getPhotoCount() <= 0) {
            JSONObject jsonImage = jsonObject.getJSONObject(Json.IMAGE);
            try {
                String name = FilenameUtils.getName(jsonImage.getString(Json.IMAGE_PATH));
                addPhoto(name);
            } catch (JSONException e) {
                Log.e(TAG, "No JSON value for " + Json.IMAGE);
            }
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

    @Override
    public void setIsSelected(boolean isSelected) {
        super.setIsSelected(isSelected);
        Logbook.editBait(getId(), this);
    }
    //endregion

    //region Catch Manipulation
    public ArrayList<UserDefineObject> getCatches() {
        UserDefineCursor cursor = QueryHelper.queryUserDefines(CatchTable.NAME, CatchTable.Columns.BAIT_ID + " = ?", new String[] { getIdAsString() });

        return QueryHelper.queryUserDefines(cursor, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new CatchCursor(cursor).getCatch();
            }
        });
    }

    @Override
    public int getFishCaughtCount() {
        return QueryHelper.queryBaitsCatchCount(this);
    }

    public String getCatchCountAsString(Context context) {
        int count = getFishCaughtCount();
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

    public String getBaitCategoryAsString() {
        return Utils.emptyStringOrString(getCategoryName());
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
    public Intent getShareIntent(Context context) {
        Intent intent = super.getShareIntent(context);

        String text = "I've made " + getCatchCountAsString(context).toLowerCase() + " so far using " + getDisplayName() + ". " + getDescriptionAsString();
        intent.putExtra(Intent.EXTRA_TEXT, text + intent.getStringExtra(Intent.EXTRA_TEXT));

        return intent;
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

    /**
     * {@inheritDoc}
     */
    @Override
    public String toKeywordsString(Context context) {
        StringBuilder builder = new StringBuilder(super.toKeywordsString(context));

        builder.append(mCategory.toKeywordsString(context));
        appendToBuilder(builder, getColorAsString());
        appendToBuilder(builder, getSizeAsString());
        appendToBuilder(builder, getDescriptionAsString());
        appendToBuilder(builder, context.getResources().getString(getTypeName()));

        return builder.toString();
    }
}
