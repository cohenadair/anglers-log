package com.cohenadair.anglerslog.model.user_defines;

import com.cohenadair.anglerslog.model.backup.Json;

import org.json.JSONException;
import org.json.JSONObject;

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

    public WaterClarity(JSONObject jsonObject) throws JSONException {
        super(jsonObject.getString(Json.NAME));
    }

}
