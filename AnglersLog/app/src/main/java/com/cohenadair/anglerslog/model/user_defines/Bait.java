package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;

/**
 * The Bait class represents a single bait used for fishing.
 *
 * Created by Cohen Adair on 2015-11-03.
 */
public class Bait extends UserDefineObject {

    private BaitCategory mCategory;

    public Bait(String name, BaitCategory category) {
        super(name);
        mCategory = category;
    }

    public Bait(Bait bait) {
        super(bait);
    }

    public Bait(UserDefineObject obj) {
        super(obj);
    }

    public Bait(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

    public void setCategory(BaitCategory category) {
        mCategory = category;
    }

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        if (mCategory != null)
            values.put(BaitTable.Columns.CATEGORY_ID, mCategory.getId().toString());

        return values;
    }
}
