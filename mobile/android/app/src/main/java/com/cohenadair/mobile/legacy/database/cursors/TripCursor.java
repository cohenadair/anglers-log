package com.cohenadair.mobile.legacy.database.cursors;

import android.database.Cursor;

import com.cohenadair.mobile.legacy.database.LogbookSchema.CatchTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.TripTable;
import com.cohenadair.mobile.legacy.user_defines.Trip;

import java.util.Date;

/**
 * A {@link Cursor} wrapper for the {@link Trip} object.
 *
 * @author Cohen Adair
 */
public class TripCursor extends UserDefineCursor {

    public TripCursor(Cursor cursor) {
        super(cursor);
    }

    public Trip getTrip() {
        Trip trip = new Trip(getObject(), true);

        trip.setStartDate(new Date(getLong(getColumnIndex(TripTable.Columns.START_DATE))));
        trip.setEndDate(new Date(getLong(getColumnIndex(TripTable.Columns.END_DATE))));
        trip.setNotes(getString(getColumnIndex(CatchTable.Columns.NOTES)));

        return trip;
    }

}
