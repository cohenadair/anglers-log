package com.cohenadair.mobile.legacy.user_defines;

/**
 * The BaitCategory object stores information on a single Bait category.
 * @author Cohen Adair
 */
public class BaitCategory extends UserDefineObject {
    public BaitCategory(BaitCategory baitCategory, boolean keepId) {
        super(baitCategory, keepId);
    }

    public BaitCategory(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }
}
