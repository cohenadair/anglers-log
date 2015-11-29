package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.user_defines.BaitCategory;

/**
 * A {@link Cursor} wrapper for the {@link BaitCategory}
 * object.
 *
 * Created by Cohen Adair on 2015-10-24.
 */
public class BaitCategoryCursor extends UserDefineCursor {

    public BaitCategoryCursor(Cursor cursor) {
        super(cursor);
    }

    public BaitCategory getBaitCategory() {
        return new BaitCategory(getObject(), true);
    }

}
