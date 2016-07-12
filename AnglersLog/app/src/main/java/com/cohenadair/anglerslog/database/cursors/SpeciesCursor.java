package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.user_defines.Species;

/**
 * A {@link Cursor} wrapper for the {@link Species} object.
 * @author Cohen Adair
 */
public class SpeciesCursor extends UserDefineCursor {

    public SpeciesCursor(Cursor cursor) {
        super(cursor);
    }

    public Species getSpecies() {
        return new Species(getObject(), true);
    }

}
