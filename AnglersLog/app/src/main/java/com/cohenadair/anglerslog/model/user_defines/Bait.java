package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;

/**
 * The Bait class represents a single bait used for fishing.
 *
 * Created by Cohen Adair on 2015-11-03.
 */
public class Bait extends PhotoUserDefineObject {

    private BaitCategory mCategory;

    public Bait(String name, BaitCategory category) {
        super(name, BaitPhotoTable.NAME);
        mCategory = category;
    }

    public Bait(Bait bait) {
        super(bait);
    }

    public Bait(Bait bait, boolean keepId) {
        super(bait, keepId);
        mCategory = new BaitCategory(bait.getCategory(), true);
    }

    public Bait(UserDefineObject obj) {
        super(obj);
        setPhotoTable(BaitPhotoTable.NAME);
    }

    public BaitCategory getCategory() {
        return mCategory;
    }

    public void setCategory(BaitCategory category) {
        mCategory = category;
    }

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        if (mCategory != null)
            values.put(BaitTable.Columns.CATEGORY_ID, mCategory.idAsString());

        return values;
    }
}
