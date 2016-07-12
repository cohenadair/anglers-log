package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.user_defines.FishingMethod;

/**
 * A {@link Cursor} wrapper for the {@link com.cohenadair.anglerslog.model.user_defines.FishingMethod}
 * object.
 *
 * @author Cohen Adair
 */
public class FishingMethodCursor extends UserDefineCursor {

    public FishingMethodCursor(Cursor cursor) {
        super(cursor);
    }

    public FishingMethod getFishingMethod() {
        return new FishingMethod(getObject(), true);
    }

}
