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
 * Created by Cohen Adair on 2015-10-24.
 */
public class CatchCursor extends UserDefineCursor {

    public CatchCursor(Cursor cursor) {
        super(cursor);
    }

    public Catch getCatch() {
        long date = getLong(getColumnIndex(CatchTable.Columns.DATE));
        String speciesId = getString(getColumnIndex(CatchTable.Columns.SPECIES_ID));
        int isFavorite = getInt(getColumnIndex(CatchTable.Columns.IS_FAVORITE));

        Catch aCatch = new Catch(getObject());
        aCatch.setDate(new Date(date));
        aCatch.setIsFavorite(isFavorite == 1);
        aCatch.setSpecies(Logbook.getSpecies(UUID.fromString(speciesId)));

        return aCatch;
    }

}
