package com.cohenadair.anglerslog.model.user_defines;

/**
 * Represents a single water clarity property, added by the user.
 * @author Cohen Adair
 */
public class WaterClarity extends UserDefineObject {

    public WaterClarity(String name) {
        super(name);
    }

    public WaterClarity(WaterClarity clarity) {
        super(clarity);
    }

    public WaterClarity(UserDefineObject obj) {
        super(obj);
    }

    public WaterClarity(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }
}
