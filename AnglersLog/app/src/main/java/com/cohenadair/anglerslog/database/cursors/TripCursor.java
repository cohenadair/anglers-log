package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.user_defines.Trip;

import java.util.Date;

import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.TripTable;

/**
 * A {@link Cursor} wrapper for the {@link com.cohenadair.anglerslog.model.user_defines.Trip}
 * object.
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
