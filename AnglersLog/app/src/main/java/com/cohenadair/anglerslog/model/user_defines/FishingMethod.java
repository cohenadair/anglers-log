package com.cohenadair.anglerslog.model.user_defines;

import com.cohenadair.anglerslog.model.backup.Json;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Represents a single fishing method property, added by the user.
 * Created by Cohen Adair on 2015-11-03.
 */
public class FishingMethod extends UserDefineObject {

    public FishingMethod(String name) {
        super(name);
    }

    public FishingMethod(FishingMethod method) {
        super(method);
    }

    public FishingMethod(UserDefineObject obj) {
        super(obj);
    }

    public FishingMethod(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

    public FishingMethod(JSONObject jsonObject) throws JSONException {
        super(jsonObject.getString(Json.NAME));
    }
}
