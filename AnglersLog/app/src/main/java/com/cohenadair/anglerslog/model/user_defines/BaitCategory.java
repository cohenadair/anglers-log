package com.cohenadair.anglerslog.model.user_defines;

/**
 * The BaitCategory object stores information on a single Bait category.
 *
 * Created by Cohen Adair on 2015-11-03.
 */
public class BaitCategory extends UserDefineObject {

    public BaitCategory(String name) {
        super(name);
    }

    public BaitCategory(BaitCategory baitCategory, boolean keepId) {
        super(baitCategory, keepId);
    }

    public BaitCategory(UserDefineObject obj) {
        super(obj);
    }

    public BaitCategory(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

}
