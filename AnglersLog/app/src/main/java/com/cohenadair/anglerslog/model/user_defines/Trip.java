package com.cohenadair.anglerslog.model.user_defines;

/**
 * The Trip class manages all data associated with a single trip. A trip is added (optionally) by
 * the user.
 *
 * Created by Cohen Adair on 2015-09-05.
 */
public class Trip extends UserDefineObject {

    public Trip(String name) {
        super(name);
    }

    @Override
    public String toString() {
        return getName();
    }

    @Override
    public String displayName() {
        return getName();
    }
}
