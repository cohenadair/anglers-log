package com.cohenadair.mobile.legacy.database.cursors;

import android.database.Cursor;

import com.cohenadair.mobile.legacy.user_defines.FishingMethod;

/**
 * A {@link Cursor} wrapper for the {@link FishingMethod} object.
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
