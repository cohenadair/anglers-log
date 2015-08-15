package com.cohenadair.anglerslog.model.user_defines;

/**
 * A UserDefineObject is the superclass for all "user defined" data such as species and locations.
 * @author Cohen Adair
 */
public class UserDefineObject {

    private String name;

    public UserDefineObject(String name) {
        this.setName(name);
    }

    //region Getters & Setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
    //endregion

}
