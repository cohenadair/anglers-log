package com.cohenadair.mobile.legacy.database.cursors;

import android.database.Cursor;
import android.database.CursorWrapper;

import com.cohenadair.mobile.legacy.database.LogbookSchema.UserDefineTable;
import com.cohenadair.mobile.legacy.user_defines.UserDefineObject;

import java.util.UUID;

/**
 * A {@link Cursor} wrapper for the {@link UserDefineObject} object.
 *
 * @author Cohen Adair
 */
public class UserDefineCursor extends CursorWrapper {

    public UserDefineCursor(Cursor cursor) {
        super(cursor);
    }

    public UserDefineObject getObject() {
        String id = getString(getColumnIndex(UserDefineTable.Columns.ID));
        String name = getString(getColumnIndex(UserDefineTable.Columns.NAME));
        int selected = getInt(getColumnIndex(UserDefineTable.Columns.SELECTED));

        UserDefineObject obj = new UserDefineObject(name);
        obj.setId(UUID.fromString(id));
        obj.setIsSelected(selected == 1);

        return obj;
    }

}
