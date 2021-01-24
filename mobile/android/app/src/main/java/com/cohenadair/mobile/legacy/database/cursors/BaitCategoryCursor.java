package com.cohenadair.mobile.legacy.database.cursors;

import android.database.Cursor;

import com.cohenadair.mobile.legacy.user_defines.BaitCategory;

/**
 * A {@link Cursor} wrapper for the {@link BaitCategory} object.
 * @author Cohen Adair
 */
public class BaitCategoryCursor extends UserDefineCursor {

    public BaitCategoryCursor(Cursor cursor) {
        super(cursor);
    }

    public BaitCategory getBaitCategory() {
        return new BaitCategory(getObject(), true);
    }

}
