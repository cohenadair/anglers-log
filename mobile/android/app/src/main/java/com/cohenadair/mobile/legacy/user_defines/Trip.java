package com.cohenadair.mobile.legacy.user_defines;

import android.content.ContentValues;

import com.cohenadair.mobile.legacy.Logbook;
import com.cohenadair.mobile.legacy.backup.Json;
import com.cohenadair.mobile.legacy.backup.JsonExporter;
import com.cohenadair.mobile.legacy.HasDateInterface;
import com.cohenadair.mobile.legacy.UsedUserDefineObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;

import static com.cohenadair.mobile.legacy.database.LogbookSchema.TripTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.UsedAnglerTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.UsedCatchTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.UsedLocationTable;

/**
 * The Trip class manages all data associated with a single trip. A trip is added (optionally) by
 * the user.
 *
 * @author Cohen Adair
 */
public class Trip extends UserDefineObject implements HasDateInterface {
    private Date mStartDate;
    private Date mEndDate;
    private String mNotes;

    // utility objects for database interaction
    private UsedUserDefineObject mUsedAnglers;
    private UsedUserDefineObject mUsedLocations;
    private UsedUserDefineObject mUsedCatches;

    //region Constructors
    public Trip(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
        init();
    }

    private void init() {
        mStartDate = new Date();
        mEndDate = new Date();

        mUsedAnglers = new UsedUserDefineObject(getId(), UsedAnglerTable.NAME, UsedAnglerTable.Columns.TRIP_ID, UsedAnglerTable.Columns.ANGLER_ID);
        mUsedLocations = new UsedUserDefineObject(getId(), UsedLocationTable.NAME, UsedLocationTable.Columns.TRIP_ID, UsedLocationTable.Columns.LOCATION_ID);
        mUsedCatches = new UsedUserDefineObject(getId(), UsedCatchTable.NAME, UsedCatchTable.Columns.TRIP_ID, UsedCatchTable.Columns.CATCH_ID);
    }
    //endregion

    @Override
    public Date getDate() {
        return getStartDate();
    }

    //region Getters & Setters
    public Date getStartDate() {
        return mStartDate;
    }

    public void setStartDate(Date startDate) {
        mStartDate = startDate;
    }

    public void setEndDate(Date endDate) {
        mEndDate = endDate;
    }

    public void setNotes(String notes) {
        mNotes = notes;
    }
    //endregion

    //region Angler Manipulation
    public ArrayList<UserDefineObject> getAnglers() {
        return mUsedAnglers.getObjects(Logbook::getAngler);
    }
    //endregion

    //region Location Manipulation
    public ArrayList<UserDefineObject> getLocations() {
        return mUsedLocations.getObjects(Logbook::getLocation);
    }
    //endregion

    //region Catch Manipulation
    public ArrayList<UserDefineObject> getCatches() {
        return mUsedCatches.getObjects(Logbook::getCatch);
    }
    //endregion

    public String getNotesAsString() {
        return (mNotes != null) ? mNotes : "";
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(TripTable.Columns.START_DATE, mStartDate.getTime());
        values.put(TripTable.Columns.END_DATE, mEndDate.getTime());

        if (mNotes != null)
            values.put(TripTable.Columns.NOTES, mNotes);

        return values;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = super.toJson();

        json.put(Json.START_DATE, mStartDate.getTime());
        json.put(Json.END_DATE, mEndDate.getTime());
        json.put(Json.NOTES, getNotesAsString());
        json.put(Json.CATCHES, JsonExporter.getIdJsonArray(getCatches()));
        json.put(Json.LOCATIONS, JsonExporter.getIdJsonArray(getLocations()));
        json.put(Json.ANGLERS, JsonExporter.getIdJsonArray(getAnglers()));

        return json;
    }
}
