package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.backup.Json;
import com.google.android.gms.maps.model.LatLng;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.FishingSpotTable;

/**
 * The FishingSpot object stores information on a single fishing spot (not an entire location);
 *
 * Created by Cohen Adair on 2015-11-03.
 */
public class FishingSpot extends UserDefineObject {

    private double mLatitude = 0.0;
    private double mLongitude = 0.0;
    private UUID mLocationId;

    public FishingSpot() {
        this("");
    }

    public FishingSpot(String name) {
        super(name);
    }

    public FishingSpot(FishingSpot fishingSpot, boolean keepId) {
        super(fishingSpot, keepId);
        mLatitude = fishingSpot.getLatitude();
        mLongitude = fishingSpot.getLongitude();
        mLocationId = fishingSpot.getLocationId();
    }

    public FishingSpot(UserDefineObject obj) {
        super(obj);
    }

    public FishingSpot(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

    public FishingSpot(JSONObject jsonObject) throws JSONException {
        super(jsonObject.getString(Json.NAME));

        // read in coordinates
        JSONObject coordinatesJson = jsonObject.getJSONObject(Json.COORDINATES);
        mLatitude = Double.parseDouble(coordinatesJson.getString(Json.LATITUDE));
        mLongitude = Double.parseDouble(coordinatesJson.getString(Json.LONGITUDE));
    }

    //region Getters & Setters
    public double getLatitude() {
        return mLatitude;
    }

    public void setLatitude(double latitude) {
        mLatitude = latitude;
    }

    public double getLongitude() {
        return mLongitude;
    }

    public void setLongitude(double longitude) {
        mLongitude = longitude;
    }

    public UUID getLocationId() {
        return mLocationId;
    }

    public void setLocationId(UUID locationId) {
        mLocationId = locationId;
    }
    //endregion

    public LatLng getCoordinates() {
        return new LatLng(mLatitude, mLongitude);
    }

    public Location getLocation() {
        return Logbook.getLocation(mLocationId);
    }

    public String getLocationName() {
        return getLocation().getName();
    }

    @Override
    public String getDisplayName() {
        return getLocationName() + " - " + getName();
    }

    /**
     * Gets a string representation of the FishingSpot's coordinates.
     * @param lat "Latitude" string.
     * @param lng "Longitude" string.
     * @return A String of the FishingSpot's coordinates.
     */
    public String getCoordinatesAsString(String lat, String lng) {
        return String.format(lat + ": %.6f, " + lng + ": %.6f", mLatitude, mLongitude);
    }

    public int getNumberOfCatches() {
        return 0;
    }

    public ContentValues getContentValues(UUID locationId) {
        ContentValues values = super.getContentValues();

        values.put(FishingSpotTable.Columns.LOCATION_ID, locationId.toString());
        values.put(FishingSpotTable.Columns.LATITUDE, mLatitude);
        values.put(FishingSpotTable.Columns.LONGITUDE, mLongitude);

        return values;
    }
}
