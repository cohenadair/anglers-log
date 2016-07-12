package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.user_defines.Angler;

/**
 * A {@link Cursor} wrapper for the {@link com.cohenadair.anglerslog.model.user_defines.Angler}
 * object.
 *
 * @author Cohen Adair
 */
public class AnglerCursor extends UserDefineCursor {

    public AnglerCursor(Cursor cursor) {
        super(cursor);
    }

    public Angler getAngler() {
        return new Angler(getObject(), true);
    }

}
