package com.cohenadair.anglerslog.model.user_defines;

import android.content.Context;
import android.content.Intent;

import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.database.cursors.FishingSpotCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.backup.Json;
import com.cohenadair.anglerslog.model.backup.JsonExporter;
import com.cohenadair.anglerslog.model.utilities.HasCatchesInterface;
import com.cohenadair.anglerslog.model.utilities.UserDefineArrays;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.FishingSpotTable;

/**
 * The Location object stores information on a single location, including many fishing spots
 * within that location.
 *
 * @author Cohen Adair
 */
public class Location extends UserDefineObject implements HasCatchesInterface {

    public Location() {
        this("");
    }

    public Location(String name) {
        super(name);
    }

    public Location(Location location, boolean keepId) {
        super(location, keepId);
    }

    public Location(UserDefineObject obj) {
        super(obj);
    }

    public Location(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

    public Location(JSONObject jsonObject) throws JSONException {
        super(jsonObject);

        JSONArray fishingSpotsJson = jsonObject.getJSONArray(Json.FISHING_SPOTS);
        ArrayList<UserDefineObject> fishingSpots = new ArrayList<>();

        for (int i = 0; i < fishingSpotsJson.length(); i++)
            fishingSpots.add(new FishingSpot(fishingSpotsJson.getJSONObject(i)));

        setFishingSpots(fishingSpots);
    }

    //region Getters & Setters
    @Override
    public void setIsSelected(boolean isSelected) {
        super.setIsSelected(isSelected);
        Logbook.editLocation(getId(), this);
    }
    //endregion

    //region Fishing Spot Manipulation
    public ArrayList<UserDefineObject> getFishingSpots() {
        return QueryHelper.queryUserDefines(
                QueryHelper.queryUserDefines(
                        FishingSpotTable.NAME,
                        FishingSpotTable.Columns.LOCATION_ID + " = ?", new String[]{getIdAsString()}
                ),
                new QueryHelper.UserDefineQueryInterface() {
                    @Override
                    public UserDefineObject getObject(UserDefineCursor cursor) {
                        return new FishingSpotCursor(cursor).getFishingSpot();
                    }
                }
        );
    }

    /**
     * Resets the location's fishing spots by first removing the old ones, then adding the new ones.
     * @param newFishingSpots The new collection of {@link FishingSpot} objects.
     */
    public void setFishingSpots(ArrayList<UserDefineObject> newFishingSpots) {
        ArrayList<UserDefineObject> oldFishingSpots = getFishingSpots();

        for (UserDefineObject oldSpot : oldFishingSpots)
            removeFishingSpot(oldSpot.getId());

        for (UserDefineObject newSpot : newFishingSpots)
            addFishingSpot((FishingSpot)newSpot);
    }

    public boolean addFishingSpot(FishingSpot fishingSpot) {
        fishingSpot.setLocationId(getId());
        return QueryHelper.insertQuery(FishingSpotTable.NAME, fishingSpot.getContentValues(getId()));
    }

    public boolean removeFishingSpot(UUID id) {
        return QueryHelper.deleteUserDefine(FishingSpotTable.NAME, id);
    }

    public boolean removeAllFishingSpots() {
        ArrayList<UserDefineObject> fishingSpots = getFishingSpots();
        for (UserDefineObject spot : fishingSpots)
            if (!removeFishingSpot(spot.getId()))
                return false;

        return true;
    }

    public int getFishingSpotCount() {
        return QueryHelper.queryCount(FishingSpotTable.NAME, FishingSpotTable.Columns.LOCATION_ID + " = ?", new String[]{ getIdAsString() });
    }
    //endregion

    public ArrayList<UserDefineObject> getCatches() {
        ArrayList<UserDefineObject> catches = new ArrayList<>();
        ArrayList<UserDefineObject> spots = getFishingSpots();

        for (UserDefineObject obj : spots) {
            FishingSpot spot = (FishingSpot)obj;
            catches.addAll(spot.getCatches());
        }

        return catches;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int getFishCaughtCount() {
        return QueryHelper.queryLocationCatchCount(this);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Intent getShareIntent(Context context) {
        Intent intent =  super.getShareIntent(context);

        String text = getDisplayName() + " has " + getFishingSpotCount() + " fishing spots and " + getFishCaughtCount() + " fish caught. ";
        intent.putExtra(Intent.EXTRA_TEXT, text + intent.getStringExtra(Intent.EXTRA_TEXT));

        return intent;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = super.toJson();
        json.put(Json.FISHING_SPOTS, JsonExporter.getJsonArray(getFishingSpots()));
        return json;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toKeywordsString(Context context) {
        return super.toKeywordsString(context) + UserDefineArrays.keywordsAsString(context, getFishingSpots());
    }
}
