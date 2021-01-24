package com.cohenadair.mobile.legacy.database.cursors;

import android.database.Cursor;

import com.cohenadair.mobile.legacy.user_defines.Location;

/**
 * A {@link Cursor} wrapper for the {@link Location} object.
 * @author Cohen Adair
 */
public class LocationCursor extends UserDefineCursor {

    public LocationCursor(Cursor cursor) {
        super(cursor);
    }

    public Location getLocation() {
        return new Location(getObject(), true);
    }

}
