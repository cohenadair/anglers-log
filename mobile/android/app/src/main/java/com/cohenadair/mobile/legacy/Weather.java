package com.cohenadair.mobile.legacy;

import com.cohenadair.mobile.legacy.backup.Json;
import com.cohenadair.mobile.legacy.backup.JsonExporter;
import com.cohenadair.mobile.legacy.user_defines.Catch;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * The Weather class stores weather information. It has the ability to update based on given
 * coordinates. This class uses the <a href="http://openweathermap.org/">Open Weather Map API</a>,
 * and is done in a background thread.
 *
 * @author Cohen Adair
 */
public class Weather {
    private final int mTemperature;
    private final int mWindSpeed;
    private final String mSkyConditions;

    public Weather(int temperature, int windSpeed, String skyConditions) {
        mTemperature = temperature;
        mWindSpeed = windSpeed;
        mSkyConditions = skyConditions;
    }

    public JSONObject toJson(Catch aCatch) throws JSONException {
        JSONObject json = new JSONObject();

        // for iOS compatibility (used for Core Data)
        json.put(Json.ENTRY, JsonExporter.dateToString(aCatch.getDate()));

        json.put(Json.TEMPERATURE, mTemperature);
        json.put(Json.WIND_SPEED, mWindSpeed);
        json.put(Json.SKY_CONDITIONS, mSkyConditions);

        return json;
    }
}
