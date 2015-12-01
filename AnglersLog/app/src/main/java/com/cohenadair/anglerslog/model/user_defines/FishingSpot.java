package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

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

    public FishingSpot(String name) {
        super(name);
    }

    public FishingSpot(FishingSpot fishingSpot, boolean keepId) {
        super(fishingSpot, keepId);
        mLatitude = fishingSpot.getLatitude();
        mLongitude = fishingSpot.getLongitude();
    }

    public FishingSpot(UserDefineObject obj) {
        super(obj);
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
    //endregion

    public ContentValues getContentValues(UUID locationId) {
        ContentValues values = super.getContentValues();

        values.put(FishingSpotTable.Columns.LOCATION_ID, locationId.toString());
        values.put(FishingSpotTable.Columns.LATITUDE, mLatitude);
        values.put(FishingSpotTable.Columns.LONGITUDE, mLongitude);

        return values;
    }
}
