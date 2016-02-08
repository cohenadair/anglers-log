package com.cohenadair.anglerslog.model.user_defines;

import com.cohenadair.anglerslog.model.backup.Json;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Represents a single Angler (fisher-person), added by the user.
 * Created by Cohen Adair on 2016-01-20.
 */
public class Angler extends UserDefineObject {

    public Angler(String name) {
        super(name);
    }

    public Angler(Angler angler) {
        super(angler);
    }

    public Angler(UserDefineObject obj) {
        super(obj);
    }

    public Angler(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

    public Angler(JSONObject jsonObject) throws JSONException {
        super(jsonObject.getString(Json.NAME));
    }
}
