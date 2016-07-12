package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.user_defines.WaterClarity;

/**
 * A {@link Cursor} wrapper for the {@link WaterClarityCursor} object.
 * @author Cohen Adair
 */
public class WaterClarityCursor extends UserDefineCursor {

    public WaterClarityCursor(Cursor cursor) {
        super(cursor);
    }

    public WaterClarity getWaterClarity() {
        return new WaterClarity(getObject(), true);
    }

}
