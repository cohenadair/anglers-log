package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.user_defines.Location;

/**
 * A {@link Cursor} wrapper for the {@link Location}
 * object.
 *
 * Created by Cohen Adair on 2015-10-24.
 */
public class LocationCursor extends UserDefineCursor {

    public LocationCursor(Cursor cursor) {
        super(cursor);
    }

    public Location getLocation() {
        return new Location(getObject(), true);
    }

}
