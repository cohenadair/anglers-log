package com.cohenadair.anglerslog.model.user_defines;

/**
 * A UserDefineObject is the superclass for all "user defined" data such as species and locations.
 * @author Cohen Adair
 */
public class UserDefineObject {

    private String mName;

    public UserDefineObject(String name) {
        setName(name);
    }

    //region Getters & Setters
    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = name;
    }
    //endregion

}
