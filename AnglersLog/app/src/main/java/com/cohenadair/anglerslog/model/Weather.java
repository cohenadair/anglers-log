package com.cohenadair.anglerslog.model;

import android.support.annotation.NonNull;
import android.util.Log;

import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.google.android.gms.maps.model.LatLng;

import org.json.JSONObject;

/**
 * The Weather class stores weather information. It has the ability to update based on given
 * coordinates. This class uses the <a href="http://openweathermap.org/">Open Weather Map API</a>,
 * and is done in a background thread.
 *
 * Created by Cohen Adair on 2016-01-13.
 */
public class Weather {

    private static final String TAG = "Weather";
    private static final String API_KEY = "35f69a23678dead2c75e0599eadbb4e1";
    private static final String API_URL = "api.openweathermap.org/data/2.5/weather";

    private LatLng mCoordinates;

    private int mTemperature;
    private int mWindSpeed;
    private String mSkyConditions;
    private String mImageUrl;

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

    //region Getters & Setters
    public int getTemperature() {
        return mTemperature;
    }

    public int getWindSpeed() {
        return mWindSpeed;
    }

    public String getImageUrl() {
        return mImageUrl;
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

    public JsonObjectRequest getRequest(@NonNull final OnFetchInterface onFetch) {
        if (mCoordinates == null) {
            Log.e(TAG, "Coordinates must not equal null to fetch weather data.");
            return null;
        }

        return new JsonObjectRequest(Request.Method.GET, getUrl(), null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject jsonObject) {
                Log.d("fetch", jsonObject.toString());
                onFetch.onSuccess();
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                onFetch.onError();
            }
        });
    }

    private String getUrl() {
        return String.format(API_URL + "?lat=%f&lon=%f&APPID=%s", mCoordinates.latitude, mCoordinates.longitude, API_KEY);
    }
}
