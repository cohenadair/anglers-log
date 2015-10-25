package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import com.cohenadair.anglerslog.database.LogbookSchema;

import java.util.UUID;

/**
 * A UserDefineObject is the superclass for all "user defined" data such as species and locations.
 * @author Cohen Adair
 */
public class UserDefineObject {

    private UUID mId;
    private String mName;
    private boolean mShouldDelete; // toggled on UI selection for deleting multiple items

    public UserDefineObject(String name) {
        setId(UUID.randomUUID());
        setName(name);
    }

    public UserDefineObject(UserDefineObject obj) {
        if (obj != null) {
            mId = UUID.randomUUID(); // a clong needs a new id for database management
            mName = obj.getName();
            mShouldDelete = obj.getShouldDelete();
        }
    }

    //region Getters & Setters
    public UUID getId() {
        return mId;
    }

    public void setId(UUID id) {
        mId = id;
    }

    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = name;
    }

    public boolean getShouldDelete() {
        return mShouldDelete;
    }

    public void setShouldDelete(boolean shouldDelete) {
        mShouldDelete = shouldDelete;
    }
    //endregion

    public String toString() {
        return mName;
    }

    public void edit(UserDefineObject newObj) {
        mName = newObj.getName();
    }

    public ContentValues getContentValues() {
        ContentValues values = new ContentValues();

        values.put(LogbookSchema.UserDefineTable.Columns.ID, mId.toString());
        values.put(LogbookSchema.UserDefineTable.Columns.NAME, mName);

        return values;
    }
}
