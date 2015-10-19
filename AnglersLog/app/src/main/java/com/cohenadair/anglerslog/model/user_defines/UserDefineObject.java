package com.cohenadair.anglerslog.model.user_defines;

import java.util.UUID;

/**
 * A UserDefineObject is the superclass for all "user defined" data such as species and locations.
 * @author Cohen Adair
 */
public class UserDefineObject implements Cloneable {

    private UUID mId;
    private String mName;
    private boolean mShouldDelete; // toggled on UI selection for deleting multiple items

    public UserDefineObject(String name) {
        setId(UUID.randomUUID());
        setName(name);
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

    @Override
    public UserDefineObject clone() throws CloneNotSupportedException {
        return (UserDefineObject)super.clone();
    }
}
