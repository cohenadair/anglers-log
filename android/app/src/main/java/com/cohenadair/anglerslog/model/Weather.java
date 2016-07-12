package com.cohenadair.anglerslog.model;

import android.content.ContentValues;
import android.support.annotation.NonNull;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.cohenadair.anglerslog.model.backup.Json;
import com.cohenadair.anglerslog.model.backup.JsonExporter;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.google.android.gms.maps.model.LatLng;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.WeatherTable;

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

    private LatLng mCoordinates;

    private int mTemperature;
    private int mWindSpeed;
    private String mSkyConditions;

    public interface OnFetchInterface {
        void onSuccess();
        void onError();
    }

    public Weather(LatLng coordinates) {
        mCoordinates = coordinates;
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

    public JsonObjectRequest getRequest(String units, @NonNull final OnFetchInterface onFetch) {
        if (mCoordinates == null)
            return null;

        return new JsonObjectRequest(Request.Method.GET, getUrl(units), null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject jsonObject) {
                parseJson(jsonObject);
                onFetch.onSuccess();
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                onFetch.onError();
            }
        });
    }

    private String getUrl(String units) {
        return String.format(API_URL + "units=%s&lat=%f&lon=%f&APPID=%s", units, mCoordinates.latitude, mCoordinates.longitude, API_KEY);
    }

    private void parseJson(JSONObject json) {
        try {
            JSONArray weather = json.getJSONArray("weather");
            if (weather.length() > 0) {
                JSONObject obj = weather.getJSONObject(0);
                mSkyConditions = obj.getString("main");
            }

            JSONObject wind = json.getJSONObject("wind");
            mWindSpeed = (int)Math.round(wind.getDouble("speed"));

            JSONObject temp = json.getJSONObject("main");
            mTemperature = (int)Math.round(temp.getDouble("temp"));
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
