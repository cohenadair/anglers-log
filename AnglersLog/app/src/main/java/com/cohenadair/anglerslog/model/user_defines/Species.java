package com.cohenadair.anglerslog.model.user_defines;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Represents a single fish species, added by the user.
 * @author Cohen Adair
 */
public class Species extends UserDefineObject {

    public Species(String name) {
        super(name);
    }

    public Species(Species species) {
        super(species);
    }

    public Species(UserDefineObject obj) {
        super(obj);
    }

    public Species(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

    public Species(JSONObject jsonObject) throws JSONException {
        super(jsonObject);
    }
}
