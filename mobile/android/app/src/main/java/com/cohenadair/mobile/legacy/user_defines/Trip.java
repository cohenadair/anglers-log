package com.cohenadair.mobile.legacy.user_defines;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;

import com.cohenadair.mobile.legacy.Utils;
import com.cohenadair.mobile.legacy.database.QueryHelper;
import com.cohenadair.mobile.legacy.Logbook;
import com.cohenadair.mobile.legacy.backup.Json;
import com.cohenadair.mobile.legacy.backup.JsonExporter;
import com.cohenadair.mobile.legacy.HasCatchesInterface;
import com.cohenadair.mobile.legacy.HasDateInterface;
import com.cohenadair.mobile.legacy.UsedUserDefineObject;
import com.cohenadair.mobile.legacy.UserDefineArrays;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

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
public class Trip extends UserDefineObject implements HasCatchesInterface, HasDateInterface {

    private Date mStartDate;
    private Date mEndDate;
    private String mNotes;

    // utility objects for database interaction
    private UsedUserDefineObject mUsedAnglers;
    private UsedUserDefineObject mUsedLocations;
    private UsedUserDefineObject mUsedCatches;

    //region Constructors
    public Trip() {
        this("");
    }

    public Trip(String name) {
        super(name);
        init();
    }

    public Trip(Trip trip, boolean keepId) {
        super(trip, keepId);
        init();

        mStartDate = trip.getStartDate();
        mEndDate = trip.getEndDate();
        mNotes = trip.getNotes();
    }

    public Trip(UserDefineObject obj) {
        super(obj);
        init();
    }

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

    public Date getEndDate() {
        return mEndDate;
    }

    public void setEndDate(Date endDate) {
        mEndDate = endDate;
    }

    public String getNotes() {
        return mNotes;
    }

    public void setNotes(String notes) {
        mNotes = notes;
    }

    @Override
    public void setIsSelected(boolean isSelected) {
        super.setIsSelected(isSelected);
        Logbook.editTrip(getId(), this);
    }
    //endregion

    //region Angler Manipulation
    public ArrayList<UserDefineObject> getAnglers() {
        return mUsedAnglers.getObjects(new QueryHelper.UsedQueryCallbacks() {
            @Override
            public UserDefineObject getFromLogbook(UUID id) {
                return Logbook.getAngler(id);
            }
        });
    }

    public void setAnglers(ArrayList<UserDefineObject> anglers) {
        mUsedAnglers.setObjects(anglers);
    }

    public int getAnglersCount() {
        return getAnglers().size();
    }

    public boolean hasAnglers() {
        return getAnglersCount() > 0;
    }
    //endregion

    //region Location Manipulation
    public ArrayList<UserDefineObject> getLocations() {
        return mUsedLocations.getObjects(new QueryHelper.UsedQueryCallbacks() {
            @Override
            public UserDefineObject getFromLogbook(UUID id) {
                return Logbook.getLocation(id);
            }
        });
    }

    public void setLocations(ArrayList<UserDefineObject> locations) {
        mUsedLocations.setObjects(locations);
    }
    //endregion

    //region Catch Manipulation
    public ArrayList<UserDefineObject> getCatches() {
        return mUsedCatches.getObjects(new QueryHelper.UsedQueryCallbacks() {
            @Override
            public UserDefineObject getFromLogbook(UUID id) {
                return Logbook.getCatch(id);
            }
        });
    }

    public void setCatches(ArrayList<UserDefineObject> catches) {
        mUsedCatches.setObjects(catches);
    }

    /**
     * @return Sum of the quantity properties for each of this Trip's catches.
     */
    @Override
    public int getFishCaughtCount() {
        return QueryHelper.queryTripsCatchCount(this);
    }
    //endregion

    /**
     * Loops through all the Trip's catches and creates an array of {@link Bait} objects that were
     * used. The resulting array has unique values.
     *
     * @return An array of {@link Bait} objects used during this trip.
     */
    public ArrayList<UserDefineObject> getBaits() {
        ArrayList<UserDefineObject> result = new ArrayList<>();
        ArrayList<UserDefineObject> catches = getCatches();

        for (UserDefineObject obj : catches) {
            Bait bait = ((Catch) obj).getBait();
            if (bait == null)
                continue;

            boolean add = true;

            // check to see if the current bait already exists in the result
            for (UserDefineObject o : result)
                if (o.getIdAsString().equals(bait.getIdAsString())) {
                    add = false;
                    break;
                }

            if (add)
                result.add(bait);
        }

        return result;
    }

    public String getNotesAsString() {
        return (mNotes != null) ? mNotes : "";
    }

    public String getStartDateAsString(Context context) {
        return Utils.getMediumDisplayDate(mStartDate, context);
    }

    public String getEndDateAsString(Context context) {
        return Utils.getMediumDisplayDate(mEndDate, context);
    }

    public String getAnglersAsString() {
        return UserDefineArrays.namesAsString(getAnglers());
    }

    public boolean hasNotes() {
        return mNotes != null && !mNotes.isEmpty();
    }

    public boolean overlapsTrip(Trip trip) {
        return trip.getStartDate().before(mEndDate) && trip.getEndDate().after(mStartDate);
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

    /**
     * {@inheritDoc}
     */
    @Override
    public String toKeywordsString(Context context) {
        StringBuilder builder = new StringBuilder(super.toKeywordsString(context));

        appendToBuilder(builder, Utils.getLongDisplayDate(mStartDate, context));
        appendToBuilder(builder, Utils.getLongDisplayDate(mEndDate, context));
        appendToBuilder(builder, mNotes);

        builder.append(UserDefineArrays.keywordsAsString(context, getAnglers()));
        builder.append(UserDefineArrays.keywordsAsString(context, getCatches()));
        builder.append(UserDefineArrays.keywordsAsString(context, getLocations()));

        return builder.toString();
    }

    /**
     * {@inheritDoc}
     *
     * Used for deleting trips. This method will remove any external ties to the database. For
     * example, removing used locations and catches. It removes the trip-to-object pairs in the
     * "Used *" tables.
     */
    @Override
    public void removeDatabaseProperties() {
        super.removeDatabaseProperties();

        mUsedCatches.deleteObjects();
        mUsedLocations.deleteObjects();
        mUsedAnglers.deleteObjects();
    }
}
