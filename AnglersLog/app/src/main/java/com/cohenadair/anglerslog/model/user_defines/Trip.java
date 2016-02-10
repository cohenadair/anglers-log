package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.content.Context;
import android.text.format.DateFormat;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.backup.Json;
import com.cohenadair.anglerslog.model.backup.JsonImporter;
import com.cohenadair.anglerslog.model.utilities.UsedUserDefineObject;
import com.cohenadair.anglerslog.utilities.UserDefineArrays;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.TripTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.UsedAnglerTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.UsedCatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.UsedLocationTable;

/**
 * The Trip class manages all data associated with a single trip. A trip is added (optionally) by
 * the user.
 *
 * Created by Cohen Adair on 2015-09-05.
 */
public class Trip extends UserDefineObject {

    private static final String DATE_FORMAT = "MMM dd, yyyy";

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

    public Trip(JSONObject jsonTrip) throws JSONException {
        this(jsonTrip.getString(Json.NAME));

        mStartDate = new Date(jsonTrip.getLong(Json.START_DATE));
        mEndDate = new Date(jsonTrip.getLong(Json.END_DATE));
        mNotes = jsonTrip.getString(Json.NOTES);

        // anglers
        JSONArray jsonAnglers = jsonTrip.getJSONArray(Json.ANGLERS);
        mUsedAnglers.setObjects(JsonImporter.parseUserDefineArray(jsonAnglers, new JsonImporter.OnGetObject() {
            @Override
            public UserDefineObject onGetObject(String name) {
                return Logbook.getAngler(name);
            }
        }));

        // locations
        JSONArray jsonLocations = jsonTrip.getJSONArray(Json.LOCATIONS);
        mUsedLocations.setObjects(JsonImporter.parseUserDefineArray(jsonLocations, new JsonImporter.OnGetObject() {
            @Override
            public UserDefineObject onGetObject(String name) {
                return Logbook.getLocation(name);
            }
        }));

        // catches
        JSONArray jsonCatches = jsonTrip.getJSONArray(Json.CATCHES);
        ArrayList<UserDefineObject> catches = new ArrayList<>();

        for (int i = 0; i < jsonCatches.length(); i++)
            catches.add(Logbook.getCatch(new Date(jsonCatches.getLong(i))));

        mUsedCatches.setObjects(catches);
    }

    private void init() {
        mStartDate = new Date();
        mEndDate = new Date();

        mUsedAnglers = new UsedUserDefineObject(getId(), UsedAnglerTable.NAME, UsedAnglerTable.Columns.TRIP_ID, UsedAnglerTable.Columns.ANGLER_ID);
        mUsedLocations = new UsedUserDefineObject(getId(), UsedLocationTable.NAME, UsedLocationTable.Columns.TRIP_ID, UsedLocationTable.Columns.LOCATION_ID);
        mUsedCatches = new UsedUserDefineObject(getId(), UsedCatchTable.NAME, UsedCatchTable.Columns.TRIP_ID, UsedCatchTable.Columns.CATCH_ID);
    }
    //endregion

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
    public int getCatchCount() {
        return QueryHelper.queryTripsCatchCount(this);
    }
    //endregion

    @Override
    public String toString() {
        return getName();
    }

    public String getNameAsString() {
        return (getName() != null) ? getName() : "";
    }

    public String getNotesAsString() {
        return (mNotes != null) ? mNotes : "";
    }

    public String getStartDateAsString() {
        return DateFormat.format(DATE_FORMAT, mStartDate).toString();
    }

    public String getEndDateAsString() {
        return DateFormat.format(DATE_FORMAT, mEndDate).toString();
    }

    public String getDateAsString(Context context) {
        String to = context.getResources().getString(R.string.to);
        return DateFormat.format(DATE_FORMAT, mStartDate).toString() + " " + to + " " + DateFormat.format(DATE_FORMAT, mEndDate).toString();
    }

    public String getCatchesAsString(Context context) {
        int count = getCatchCount();
        String catchesStr = count == 1 ? context.getResources().getString(R.string.catch_string) : context.getResources().getString(R.string.drawer_catches);
        return count + " " + catchesStr;
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

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(TripTable.Columns.START_DATE, mStartDate.getTime());
        values.put(TripTable.Columns.END_DATE, mEndDate.getTime());

        if (mNotes != null)
            values.put(TripTable.Columns.NOTES, mNotes);

        return values;
    }

    /**
     * Used for deleting trips. This method will remove any external ties to the database. For
     * example, removing used locations and catches. It removes the trip-to-object pairs in the
     * "Used *" tables.
     */
    public void removeDatabaseProperties() {
        mUsedCatches.deleteObjects();
        mUsedLocations.deleteObjects();
        mUsedAnglers.deleteObjects();
    }
}
