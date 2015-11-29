package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.user_defines.Species;

/**
 * A {@link Cursor} wrapper for the {@link Species}
 * object.
 *
 * Created by Cohen Adair on 2015-10-24.
 */
public class SpeciesCursor extends UserDefineCursor {

    public SpeciesCursor(Cursor cursor) {
        super(cursor);
    }

    public Species getSpecies() {
        return new Species(getObject(), true);
    }

}
