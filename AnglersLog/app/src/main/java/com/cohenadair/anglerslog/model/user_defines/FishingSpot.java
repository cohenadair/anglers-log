package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.content.Context;

import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.backup.Json;
import com.google.android.gms.maps.model.LatLng;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.FishingSpotTable;

/**
 * The FishingSpot object stores information on a single fishing spot (not an entire location);
 * @author Cohen Adair
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
        super(jsonObject);

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
     * Gets a string representation of the FishingSpot's coordinates. The result of this method
     * includes "Latitude" and "Longitude" labels.
     *
     * @param lat "Latitude" string.
     * @param lng "Longitude" string.
     * @return A String of the FishingSpot's coordinates.
     */
    public String getCoordinatesAsString(String lat, String lng) {
        return String.format(lat + ": %.6f, " + lng + ": %.6f", mLatitude, mLongitude);
    }

    /**
     * Gets a string representation of the FishingSpot's coordinates. The result of this method
     * <b>does not</b> include "Latitude" and "Longitude" labels.
     * @see #getCoordinatesAsString(String, String)
     */
    public String getCoordinatesAsString() {
        return String.format("%.6f, %.6f", mLatitude, mLongitude);
    }

    /**
     * @return An {@link ArrayList} of {@link Catch} objects associated with this
     * {@link FishingSpot}.
     */
    public ArrayList<UserDefineObject> getCatches() {
        return QueryHelper.queryUserDefines(QueryHelper.queryCatches(CatchTable.Columns.FISHING_SPOT_ID + " = ?", new String[] { getIdAsString() }), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new CatchCursor(cursor).getCatch();
            }
        });
    }

    public int getNumberOfCatches() {
        return QueryHelper.queryFishingSpotCatchCount(this);
    }

    public ContentValues getContentValues(UUID locationId) {
        ContentValues values = super.getContentValues();

        values.put(FishingSpotTable.Columns.LOCATION_ID, locationId.toString());
        values.put(FishingSpotTable.Columns.LATITUDE, mLatitude);
        values.put(FishingSpotTable.Columns.LONGITUDE, mLongitude);

        return values;
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

    /**
     * {@inheritDoc}
     */
    @Override
    public String toKeywordsString(Context context) {
        StringBuilder builder = new StringBuilder(super.toKeywordsString(context));

        appendToBuilder(builder, (float)mLatitude);
        appendToBuilder(builder, (float)mLongitude);
        appendToBuilder(builder, getLocationName());

        return builder.toString();
    }
}
