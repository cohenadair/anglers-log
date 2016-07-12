package com.cohenadair.anglerslog.model.user_defines;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Represents a single Angler (fisher-person), added by the user.
 * @author Cohen Adair
 */
public class Angler extends UserDefineObject {

    public Angler(String name) {
        super(name);
    }

    public Angler(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

    public Angler(JSONObject jsonObject) throws JSONException {
        super(jsonObject);
    }
}
