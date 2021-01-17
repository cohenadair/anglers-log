package com.cohenadair.mobile.legacy.user_defines;

import android.content.Context;
import android.content.Intent;

import com.cohenadair.mobile.legacy.HasCatchesInterface;
import com.cohenadair.mobile.legacy.database.QueryHelper;
import com.cohenadair.mobile.legacy.database.cursors.FishingSpotCursor;
import com.cohenadair.mobile.legacy.database.cursors.UserDefineCursor;
import com.cohenadair.mobile.legacy.Logbook;
import com.cohenadair.mobile.legacy.backup.Json;
import com.cohenadair.mobile.legacy.backup.JsonExporter;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.UUID;

import static com.cohenadair.mobile.legacy.database.LogbookSchema.FishingSpotTable;

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
     * Resets the location's fishing spots by updating existing spots, deleting spots that no
     * longer exist, and adding new spots.
     * @param newFishingSpots The new collection of {@link FishingSpot} objects.
     */
    public void setFishingSpots(ArrayList<UserDefineObject> newFishingSpots) {
        ArrayList<UserDefineObject> oldFishingSpots = getFishingSpots();

        // Iterate through the old and new spots, updating and deleting fishing spots.
        for (UserDefineObject oldSpot : oldFishingSpots) {
            boolean shouldDelete = true;

            for (UserDefineObject newSpot : newFishingSpots) {
                // If the old fishing spot is in the new fishing spots, update it, and remove it
                // from new fishing spots.
                if (oldSpot.getId().equals(newSpot.getId())) {
                    updateFishingSpot((FishingSpot) newSpot);
                    newFishingSpots.remove(newSpot);
                    shouldDelete = false;
                    break;
                }
            }

            // The old fishing spot is not present in the new fishing spots, delete it.
            if (shouldDelete) {
                removeFishingSpot(oldSpot.getId());
            }
        }

        // Add remaining new fishing spots.
        for (UserDefineObject newSpot : newFishingSpots) {
            addFishingSpot((FishingSpot) newSpot);
        }
    }

    public boolean addFishingSpot(FishingSpot fishingSpot) {
        fishingSpot.setLocationId(getId());
        return QueryHelper.insertQuery(FishingSpotTable.NAME, fishingSpot.getContentValues(getId()));
    }

    public boolean removeFishingSpot(UUID id) {
        return QueryHelper.deleteUserDefine(FishingSpotTable.NAME, id);
    }

    public boolean updateFishingSpot(FishingSpot fishingSpot) {
        return QueryHelper.updateQuery(FishingSpotTable.NAME,
                fishingSpot.getContentValues(getId()), FishingSpotTable.Columns.ID + " = ?",
                new String[] { fishingSpot.getIdAsString() });
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
    public JSONObject toJson() throws JSONException {
        JSONObject json = super.toJson();
        json.put(Json.FISHING_SPOTS, JsonExporter.getJsonArray(getFishingSpots()));
        return json;
    }
}
