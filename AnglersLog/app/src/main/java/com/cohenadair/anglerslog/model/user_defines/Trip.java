package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;

import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.utilities.UsedUserDefineObject;

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

    private Date mStartDate;
    private Date mEndDate;
    private String mNotes;

    // utility objects for database interaction
    private UsedUserDefineObject mUsedAnglers;
    private UsedUserDefineObject mUsedLocations;
    private UsedUserDefineObject mUsedCatches;

    //region Constructors
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
    //endregion

    @Override
    public String toString() {
        return getName();
    }

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(TripTable.Columns.START_DATE, mStartDate.getTime());
        values.put(TripTable.Columns.END_DATE, mEndDate.getTime());

        if (mNotes != null)
            values.put(TripTable.Columns.NOTES, mNotes);

        return values;
    }
}
