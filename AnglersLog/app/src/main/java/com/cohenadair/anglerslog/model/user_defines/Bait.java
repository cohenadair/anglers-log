package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import com.cohenadair.anglerslog.R;

import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;

/**
 * The Bait class represents a single bait used for fishing.
 *
 * Created by Cohen Adair on 2015-11-03.
 */
public class Bait extends PhotoUserDefineObject {

    /**
     * Correspond to resources array in bait_types.xml.
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
