package com.cohenadair.mobile.legacy.user_defines;

import com.cohenadair.mobile.legacy.database.QueryHelper;
import com.cohenadair.mobile.legacy.database.cursors.FishingSpotCursor;
import com.cohenadair.mobile.legacy.backup.Json;
import com.cohenadair.mobile.legacy.backup.JsonExporter;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

import static com.cohenadair.mobile.legacy.database.LogbookSchema.FishingSpotTable;

/**
 * The Location object stores information on a single location, including many fishing spots
 * within that location.
 *
 * @author Cohen Adair
 */
public class Location extends UserDefineObject {
    public Location(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
    }

    //region Fishing Spot Manipulation
    public ArrayList<UserDefineObject> getFishingSpots() {
        return QueryHelper.queryUserDefines(
                QueryHelper.queryUserDefines(
                        FishingSpotTable.NAME,
                        FishingSpotTable.Columns.LOCATION_ID + " = ?", new String[]{getIdAsString()}
                ),
                cursor -> new FishingSpotCursor(cursor).getFishingSpot()
        );
    }
    //endregion

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
