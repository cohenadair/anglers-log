package com.cohenadair.mobile.legacy;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import androidx.annotation.NonNull;

import com.cohenadair.mobile.legacy.database.LogbookHelper;
import com.cohenadair.mobile.legacy.database.LogbookSchema.AnglerTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.BaitCategoryTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.BaitPhotoTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.BaitTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.CatchPhotoTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.CatchTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.FishingMethodTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.FishingSpotTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.LocationTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.SpeciesTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.WaterClarityTable;
import com.cohenadair.mobile.legacy.database.QueryHelper;
import com.cohenadair.mobile.legacy.database.cursors.AnglerCursor;
import com.cohenadair.mobile.legacy.database.cursors.BaitCategoryCursor;
import com.cohenadair.mobile.legacy.database.cursors.BaitCursor;
import com.cohenadair.mobile.legacy.database.cursors.CatchCursor;
import com.cohenadair.mobile.legacy.database.cursors.FishingMethodCursor;
import com.cohenadair.mobile.legacy.database.cursors.FishingSpotCursor;
import com.cohenadair.mobile.legacy.database.cursors.LocationCursor;
import com.cohenadair.mobile.legacy.database.cursors.SpeciesCursor;
import com.cohenadair.mobile.legacy.database.cursors.TripCursor;
import com.cohenadair.mobile.legacy.database.cursors.WaterClarityCursor;
import com.cohenadair.mobile.legacy.user_defines.Angler;
import com.cohenadair.mobile.legacy.user_defines.Bait;
import com.cohenadair.mobile.legacy.user_defines.BaitCategory;
import com.cohenadair.mobile.legacy.user_defines.Catch;
import com.cohenadair.mobile.legacy.user_defines.FishingMethod;
import com.cohenadair.mobile.legacy.user_defines.FishingSpot;
import com.cohenadair.mobile.legacy.user_defines.Location;
import com.cohenadair.mobile.legacy.user_defines.Species;
import com.cohenadair.mobile.legacy.user_defines.UserDefineObject;
import com.cohenadair.mobile.legacy.user_defines.WaterClarity;

import java.io.File;
import java.util.ArrayList;

/**
 * The Logbook class is a static class storing all of the user's log data.
 * @author Cohen Adair
 */
public class Logbook {
    private static final String TAG = "Logbook";

    private static SQLiteDatabase mDatabase;

    private Logbook() { }

    public static String init(Context context) {
        File dbFile = context.getDatabasePath(LogbookHelper.DATABASE_NAME);
        if (!dbFile.exists()) {
            return null;
        }
        init(new LogbookHelper(context).getWritableDatabase());
        return dbFile.getPath();
    }

    public static void init(SQLiteDatabase database) {
        mDatabase = database;
        mDatabase.setForeignKeyConstraintsEnabled(true);
        QueryHelper.setDatabase(mDatabase);
        cleanDatabasePhotos();
    }

    //region Getters & Setters
    public static SQLiteDatabase getDatabase() {
        return mDatabase;
    }

    public static String getName() {
        return TAG;
    }
    //endregion

    /**
     * Deletes all database entries for photos that aren't associated with any UserDefineObject
     * instances.
     */
    private static void cleanDatabasePhotos() {
        int numDeleted = mDatabase.delete(
                CatchPhotoTable.NAME,
                CatchPhotoTable.Columns.USER_DEFINE_ID + " NOT IN(SELECT " + CatchTable.Columns.ID + " FROM " + CatchTable.NAME + ")",
                null
        );

        numDeleted += mDatabase.delete(
                BaitPhotoTable.NAME,
                BaitPhotoTable.Columns.USER_DEFINE_ID + " NOT IN(SELECT " + BaitTable.Columns.ID + " FROM " + BaitTable.NAME + ")",
                null
        );

        Log.i(TAG, "Deleted " + numDeleted + " unused photos from the database.");
    }

    //region Catch Manipulation
    public static ArrayList<UserDefineObject> getCatches() {
        return QueryHelper.queryUserDefines(QueryHelper.queryCatches(null, null), cursor -> new CatchCursor(cursor).getCatch());
    }

    public static Catch getCatch(String id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(CatchTable.NAME, CatchTable.Columns.ID, id, cursor -> new CatchCursor(cursor).getCatch());
        return (obj == null) ? null : (Catch)obj;
    }
    //endregion

    //region Species Manipulation
    public static ArrayList<UserDefineObject> getSpecies() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(SpeciesTable.NAME, null, null), cursor -> new SpeciesCursor(cursor).getSpecies());
    }

    public static Species getSpecies(String id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(SpeciesTable.NAME, SpeciesTable.Columns.ID, id, cursor -> new SpeciesCursor(cursor).getSpecies());
        return (obj == null) ? null : (Species)obj;
    }

    //region BaitCategory Manipulation
    public static ArrayList<UserDefineObject> getBaitCategories() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(BaitCategoryTable.NAME, null, null), cursor -> new BaitCategoryCursor(cursor).getBaitCategory());
    }

    public static BaitCategory getBaitCategory(String id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(BaitCategoryTable.NAME, BaitCategoryTable.Columns.ID, id, cursor -> new BaitCategoryCursor(cursor).getBaitCategory());
        return (obj == null) ? null : (BaitCategory)obj;
    }
    //endregion

    //region Bait Manipulation
    /**
     * Gets all {@link Bait} objects based on the given WHERE clause.
     * @return An ArrayList of {@link Bait} objects matching the WHERE clause.
     */
    public static ArrayList<UserDefineObject> getBaits() {
        return QueryHelper.queryUserDefines(QueryHelper.queryBaits("", null), cursor -> new BaitCursor(cursor).getBait());
    }

    public static Bait getBait(String id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(BaitTable.NAME, BaitTable.Columns.ID, id, getBaitQueryInterface());
        return baitOrNull(obj);
    }

    @NonNull
    private static QueryHelper.UserDefineQueryInterface getBaitQueryInterface() {
        return cursor -> new BaitCursor(cursor).getBait();
    }

    private static Bait baitOrNull(UserDefineObject obj) {
        return (obj == null) ? null : (Bait)obj;
    }
    //endregion

    //region Location Manipulation
    public static ArrayList<UserDefineObject> getLocations() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(LocationTable.NAME, null, null), cursor -> new LocationCursor(cursor).getLocation());
    }

    public static Location getLocation(String id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(LocationTable.NAME, LocationTable.Columns.ID, id, cursor -> new LocationCursor(cursor).getLocation());
        return (obj == null) ? null : (Location)obj;
    }

    public static FishingSpot getFishingSpot(String id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(FishingSpotTable.NAME, FishingSpotTable.Columns.ID, id, getFishingSpotQueryInterface());
        return fishingSpotOrNull(obj);
    }

    @NonNull
    private static QueryHelper.UserDefineQueryInterface getFishingSpotQueryInterface() {
        return cursor -> new FishingSpotCursor(cursor).getFishingSpot();
    }

    private static FishingSpot fishingSpotOrNull(UserDefineObject obj) {
        return (obj == null) ? null : (FishingSpot)obj;
    }
    //endregion

    //region WaterClarity Manipulation
    public static ArrayList<UserDefineObject> getWaterClarities() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(WaterClarityTable.NAME, null, null), cursor -> new WaterClarityCursor(cursor).getWaterClarity());
    }

    public static WaterClarity getWaterClarity(String id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(WaterClarityTable.NAME, WaterClarityTable.Columns.ID, id, cursor -> new WaterClarityCursor(cursor).getWaterClarity());
        return (obj == null) ? null : (WaterClarity)obj;
    }
    //endregion

    //region FishingMethod Manipulation
    public static ArrayList<UserDefineObject> getFishingMethods() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(FishingMethodTable.NAME, null, null), cursor -> new FishingMethodCursor(cursor).getFishingMethod());
    }

    public static FishingMethod getFishingMethod(String id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(FishingMethodTable.NAME, FishingMethodTable.Columns.ID, id, cursor -> new FishingMethodCursor(cursor).getFishingMethod());
        return (obj == null) ? null : (FishingMethod)obj;
    }
    //endregion

    //region Angler Manipulation
    public static ArrayList<UserDefineObject> getAnglers() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(AnglerTable.NAME, null, null), cursor -> new AnglerCursor(cursor).getAngler());
    }

    public static Angler getAngler(String id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(AnglerTable.NAME, AnglerTable.Columns.ID, id, cursor -> new AnglerCursor(cursor).getAngler());
        return (obj == null) ? null : (Angler)obj;
    }
    //endregion

    //region Trip Manipulation
    public static ArrayList<UserDefineObject> getTrips() {
        return QueryHelper.queryUserDefines(QueryHelper.queryTrips(null, null), cursor -> new TripCursor(cursor).getTrip());
    }
    //endregion
}
