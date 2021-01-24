package com.cohenadair.mobile.legacy.user_defines;

import com.cohenadair.mobile.legacy.Logbook;
import com.cohenadair.mobile.legacy.backup.Json;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.UUID;

/**
 * The FishingSpot object stores information on a single fishing spot (not an entire location);
 * @author Cohen Adair
 */
public class FishingSpot extends UserDefineObject {
    private double mLatitude = 0.0;
    private double mLongitude = 0.0;
    private UUID mLocationId;

    public FishingSpot(FishingSpot fishingSpot, boolean keepId) {
        super(fishingSpot, keepId);
        mLatitude = fishingSpot.getLatitude();
        mLongitude = fishingSpot.getLongitude();
        mLocationId = fishingSpot.getLocationId();
    }

    public FishingSpot(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
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

    public Location getLocation() {
        return Logbook.getLocation(mLocationId.toString());
    }

    public String getLocationName() {
        return getLocation().getName();
    }

    @Override
    public String getDisplayName() {
        return getLocationName() + " - " + getName();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = super.toJson();

        JSONObject coordinates = new JSONObject();
        coordinates.put(Json.LATITUDE, mLatitude);
        coordinates.put(Json.LONGITUDE, mLongitude);
        json.put(Json.COORDINATES, coordinates);

        // for iOS Core Data compatibility
        json.put(Json.LOCATION, getLocationName());

        return json;
    }
}
