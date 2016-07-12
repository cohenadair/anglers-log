package com.cohenadair.anglerslog.database.cursors;

import android.database.Cursor;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.user_defines.Bait;

import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;

/**
 * A {@link Cursor} wrapper for the {@link com.cohenadair.anglerslog.model.user_defines.Bait}
 * object.
 *
 * @author Cohen Adair
 */
public class BaitCursor extends UserDefineCursor {

    public BaitCursor(Cursor cursor) {
        super(cursor);
    }

    public Bait getBait() {
        String categoryId = getString(getColumnIndex(BaitTable.Columns.CATEGORY_ID));

        Bait bait = new Bait(getObject(), true);
        bait.setCategory(Logbook.getBaitCategory(UUID.fromString(categoryId)));
        bait.setColor(getString(getColumnIndex(BaitTable.Columns.COLOR)));
        bait.setSize(getString(getColumnIndex(BaitTable.Columns.SIZE)));
        bait.setDescription(getString(getColumnIndex(BaitTable.Columns.DESCRIPTION)));
        bait.setType(getInt(getColumnIndex(BaitTable.Columns.TYPE)));

        return bait;
    }

}
