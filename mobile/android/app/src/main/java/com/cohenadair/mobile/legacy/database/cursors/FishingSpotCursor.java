package com.cohenadair.mobile.legacy.database.cursors;

import android.database.Cursor;

import com.cohenadair.mobile.legacy.database.LogbookSchema.FishingSpotTable;
import com.cohenadair.mobile.legacy.user_defines.FishingSpot;

import java.util.UUID;

/**
 * A {@link Cursor} wrapper for the {@link FishingSpot} object.
 * @author Cohen Adair
 */
public class FishingSpotCursor extends UserDefineCursor {

    public FishingSpotCursor(Cursor cursor) {
        super(cursor);
    }

    public FishingSpot getFishingSpot() {
        FishingSpot fishingSpot = new FishingSpot(getObject(), true);

        fishingSpot.setLatitude(getDouble(getColumnIndex(FishingSpotTable.Columns.LATITUDE)));
        fishingSpot.setLongitude(getDouble(getColumnIndex(FishingSpotTable.Columns.LONGITUDE)));
        fishingSpot.setLocationId(UUID.fromString(getString(getColumnIndex(FishingSpotTable.Columns.LOCATION_ID))));

        return fishingSpot;
    }

}
