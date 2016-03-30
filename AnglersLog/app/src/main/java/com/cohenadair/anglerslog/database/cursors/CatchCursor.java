package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Catch;

import java.util.Date;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;

/**
 * A {@link Cursor} wrapper for the {@link com.cohenadair.anglerslog.model.user_defines.Catch}
 * object.
 *
 * @author Cohen Adair
 */
public class CatchCursor extends UserDefineCursor {

    public CatchCursor(Cursor cursor) {
        super(cursor);
    }

    public Catch getCatch() {
        long date = getLong(getColumnIndex(CatchTable.Columns.DATE));
        String speciesId = getString(getColumnIndex(CatchTable.Columns.SPECIES_ID));
        String baitId = getString(getColumnIndex(CatchTable.Columns.BAIT_ID));
        String fishingSpotId = getString(getColumnIndex(CatchTable.Columns.FISHING_SPOT_ID));
        String waterClarityId = getString(getColumnIndex(CatchTable.Columns.CLARITY_ID));
        String notes = getString(getColumnIndex(CatchTable.Columns.NOTES));
        int catchResult = getInt(getColumnIndex(CatchTable.Columns.CATCH_RESULT));
        int isFavorite = getInt(getColumnIndex(CatchTable.Columns.IS_FAVORITE));
        int quantity = getInt(getColumnIndex(CatchTable.Columns.QUANTITY));
        int waterTemperature = getInt(getColumnIndex(CatchTable.Columns.WATER_TEMPERATURE));
        float waterDepth = getFloat(getColumnIndex(CatchTable.Columns.WATER_DEPTH));
        float length = getFloat(getColumnIndex(CatchTable.Columns.LENGTH));
        float weight = getFloat(getColumnIndex(CatchTable.Columns.WEIGHT));

        Catch aCatch = new Catch(getObject(), true);
        aCatch.setDate(new Date(date));
        aCatch.setIsFavorite(isFavorite == 1);
        aCatch.setSpecies(Logbook.getSpecies(UUID.fromString(speciesId)));
        aCatch.setCatchResult(Catch.CatchResult.fromInt(catchResult));
        aCatch.setQuantity(quantity);
        aCatch.setLength(length);
        aCatch.setWeight(weight);
        aCatch.setWaterDepth(waterDepth);
        aCatch.setWaterTemperature(waterTemperature);

        if (baitId != null)
            aCatch.setBait(Logbook.getBait(UUID.fromString(baitId)));

        if (fishingSpotId != null)
            aCatch.setFishingSpot(Logbook.getFishingSpot(UUID.fromString(fishingSpotId)));

        if (waterClarityId != null)
            aCatch.setWaterClarity(Logbook.getWaterClarity(UUID.fromString(waterClarityId)));

        if (notes != null)
            aCatch.setNotes(notes);

        return aCatch;
    }

}
