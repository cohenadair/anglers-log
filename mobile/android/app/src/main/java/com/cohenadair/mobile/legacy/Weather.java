package com.cohenadair.mobile.legacy;

import android.content.ContentValues;

import com.cohenadair.mobile.legacy.backup.Json;
import com.cohenadair.mobile.legacy.backup.JsonExporter;
import com.cohenadair.mobile.legacy.database.LogbookSchema.WeatherTable;
import com.cohenadair.mobile.legacy.user_defines.Catch;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.UUID;

/**
 * The Weather class stores weather information. It has the ability to update based on given
 * coordinates. This class uses the <a href="http://openweathermap.org/">Open Weather Map API</a>,
 * and is done in a background thread.
 *
 * @author Cohen Adair
 */
public class Weather {

    private static final String API_KEY = "35f69a23678dead2c75e0599eadbb4e1";
    private static final String API_URL = "http://api.openweathermap.org/data/2.5/weather?";

    private int mTemperature;
    private int mWindSpeed;
    private String mSkyConditions;

    public interface OnFetchInterface {
        void onSuccess();
        void onError();
    }

    public Weather(int temperature, int windSpeed, String skyConditions) {
        mTemperature = temperature;
        mWindSpeed = windSpeed;
        mSkyConditions = skyConditions;
    }

    public Weather(JSONObject jsonObject) throws JSONException {
        mTemperature = jsonObject.getInt(Json.TEMPERATURE);
        mWindSpeed = jsonObject.getInt(Json.WIND_SPEED);
        mSkyConditions = jsonObject.getString(Json.SKY_CONDITIONS);
    }

    //region Getters & Setters
    public int getTemperature() {
        return mTemperature;
    }

    public int getWindSpeed() {
        return mWindSpeed;
    }

    public String getSkyConditions() {
        return mSkyConditions;
    }
    //endregion

    public String getTemperatureAsString() {
        return Integer.toString(mTemperature);
    }

    public String getWindSpeedAsString() {
        return Integer.toString(mWindSpeed);
    }

    private void parseJson(JSONObject json) {
        try {
            JSONArray weather = json.getJSONArray("weather");
            if (weather.length() > 0) {
                JSONObject obj = weather.getJSONObject(0);
                mSkyConditions = obj.getString("main");
            }

            JSONObject wind = json.getJSONObject("wind");
            mWindSpeed = (int) Math.round(wind.getDouble("speed"));

            JSONObject temp = json.getJSONObject("main");
            mTemperature = (int) Math.round(temp.getDouble("temp"));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public ContentValues getContentValues(UUID catchId) {
        ContentValues values = new ContentValues();

        values.put(WeatherTable.Columns.CATCH_ID, catchId.toString());
        values.put(WeatherTable.Columns.TEMPERATURE, mTemperature);
        values.put(WeatherTable.Columns.WIND_SPEED, mWindSpeed);
        values.put(WeatherTable.Columns.SKY_CONDITIONS, mSkyConditions);

        return values;
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

    public String toKeywordsString() {
        return mSkyConditions;
    }
}
