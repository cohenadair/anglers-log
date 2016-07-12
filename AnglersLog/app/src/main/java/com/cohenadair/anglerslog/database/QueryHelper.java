package com.cohenadair.anglerslog.database;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.cohenadair.anglerslog.database.cursors.BaitCursor;
import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.TripCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.database.cursors.WeatherCursor;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.*;

/**
 * A class for easy database querying. This is also used so the rest of the application doesn't
 * need to interact directly with the database.
 *
 * @author Cohen Adair
 */
public class QueryHelper {

    private static final String COUNT = "COUNT(*)";

    private static SQLiteDatabase mDatabase;

    public interface UserDefineQueryInterface {
        UserDefineObject getObject(UserDefineCursor cursor);
    }

    public interface UsedQueryCallbacks {
        UserDefineObject getFromLogbook(UUID id);
    }

    private QueryHelper() {
        // prevents instantiation
    }

    public static void setDatabase(SQLiteDatabase database) {
        mDatabase = database;
    }

    /**
     * A simple single column query.
     *
     * @param table The table to query.
     * @param column The column to query.
     * @param whereClause The where conditions.
     * @param args The where conditions arguments.
     * @return A Cursor of the query.
     */
    public static Cursor simpleQuery(String table, String column, String whereClause, String[] args) {
        return mDatabase.query(table, new String[]{column}, whereClause, args, null, null, null);
    }

    @NonNull
    public static CatchCursor queryCatches(String whereClause, String[] args) {
        return new CatchCursor(mDatabase.query(CatchTable.NAME, null, whereClause, args, null, null, CatchTable.Columns.DATE + " DESC"));
    }

    @NonNull
    public static CatchCursor queryCatches(String column, String whereClause, String[] args) {
        return new CatchCursor(mDatabase.query(CatchTable.NAME, new String[] { column }, whereClause, args, null, null, null));
    }

    @NonNull
    public static BaitCursor queryBaits(String whereClause, String[] args) {
        return new BaitCursor(mDatabase.query(BaitTable.NAME, null, whereClause, args, null, null, BaitTable.Columns.NAME));
    }

    @NonNull
    public static TripCursor queryTrips(String whereClause, String[] args) {
        return new TripCursor(mDatabase.query(TripTable.NAME, null, whereClause, args, null, null, TripTable.Columns.START_DATE + " DESC"));
    }

    /**
     * Gets a {@link UserDefineCursor} subclass for a given table. This method is normally used
     * in combination with {@link #queryUserDefines(UserDefineCursor, UserDefineQueryInterface)}.
     *
     * @param table The table (i.e. BaitTable.Name).
     * @param whereClause The SQL where clause.
     * @param args The arguments for the where clause.
     * @return A {@link UserDefineCursor} subclass.
     *
     * @see #queryUserDefines(UserDefineCursor, UserDefineQueryInterface)
     */
    @NonNull
    public static UserDefineCursor queryUserDefines(String table, String whereClause, String[] args) {
        return new UserDefineCursor(mDatabase.query(table, null, whereClause, args, null, null, UserDefineTable.Columns.NAME));
    }

    /**
     * Queries for all instances of a {@link UserDefineObject} subclass.
     *
     * @param cursor The {@link UserDefineCursor} to be iterated through.
     * @param callbacks Callbacks for casting the {@link UserDefineObject} to the desired object.
     * @return An array of {@link UserDefineObject} subclasses.
     *
     * @see #queryUserDefines(String, String, String[])
     */
    public static ArrayList<UserDefineObject> queryUserDefines(UserDefineCursor cursor, UserDefineQueryInterface callbacks) {
        ArrayList<UserDefineObject> objs = new ArrayList<>();

        if (cursor.moveToFirst())
            while (!cursor.isAfterLast()) {
                objs.add((callbacks == null) ? cursor.getObject() : callbacks.getObject(cursor));
                cursor.moveToNext();
            }

        cursor.close();
        return objs;
    }

    /**
     * @see #queryUserDefine(String, String, String[], UserDefineQueryInterface)
     */
    public static UserDefineObject queryUserDefine(String table, UUID id, UserDefineQueryInterface callbacks) {
        return queryUserDefine(table, UserDefineTable.Columns.ID, id.toString(), callbacks);
    }

    /**
     * @see #queryUserDefine(String, String, String[], UserDefineQueryInterface)
     */
    public static UserDefineObject queryUserDefine(String table, String column, String columnValue, UserDefineQueryInterface callbacks) {
        return queryUserDefine(table, column + " = ?", new String[] { columnValue }, callbacks);
    }

    /**
     * Retrieves a single {@link UserDefineObject} from the database.
     *
     * @param callbacks Callbacks for casting the resulting {@link UserDefineObject}.
     * @return A {@link UserDefineObject} subclass.
     *
     * @see #queryUserDefine(String, UUID, UserDefineQueryInterface)
     * @see #queryUserDefine(String, String, String, UserDefineQueryInterface)
     */
    public static UserDefineObject queryUserDefine(String table, String whereClause, String[] args, UserDefineQueryInterface callbacks) {
        UserDefineObject obj = null;
        UserDefineCursor cursor = queryUserDefines(table, whereClause, args);

        if (cursor.moveToFirst())
            obj = (callbacks == null) ? cursor.getObject() : callbacks.getObject(cursor);

        cursor.close();
        return obj;
    }

    /**
     * Gets the "Used*" UserDefineObjects for a "super" UserDefineObject. Example: Can get all the
     * used fishing methods for a given Catch.
     *
     * @param table The "Used *" table name (i.e. UsedFishingMethodTable).
     * @param resultColumn If getting FishingMethod objects, for example, use UsedFishingMethodTable.Columns.FISHING_METHOD_ID.
     * @param superColumn The superclass columns (i.e. UsedFishinMethodsTable.Columns.CATCH_ID).
     * @param superId The id of the superclass to filter used user define objects (i.e. catch id).
     * @param callbacks Callbacks for the method.
     * @return An ArrayList of UserDefineObjects associated with the give superclass id.
     */
    public static ArrayList<UserDefineObject> queryUsedUserDefineObject(String table, String resultColumn, String superColumn, UUID superId, UsedQueryCallbacks callbacks) {
        ArrayList<UserDefineObject> objs = new ArrayList<>();
        Cursor cursor = simpleQuery(table, resultColumn, superColumn + " = ?", new String[]{superId.toString()});

        if (cursor.moveToFirst())
            while (!cursor.isAfterLast()) {
                UUID id = UUID.fromString(cursor.getString(cursor.getColumnIndex(resultColumn)));
                objs.add(callbacks.getFromLogbook(id));
                cursor.moveToNext();
            }

        cursor.close();
        return objs;
    }

    /**
     * Returns the number of items matching the given criteria.
     * @return The number of rows returned by the query.
     *
     * @see #queryCount(String)
     */
    public static int queryCount(String table, String whereClause, String[] args) {
        int count = 0;
        Cursor cursor = mDatabase.query(table, new String[]{COUNT}, whereClause, args, null, null, null);

        if (cursor.moveToFirst())
            count = cursor.getInt(cursor.getColumnIndex(COUNT));

        cursor.close();
        return count;
    }

    /**
     * @see #queryCount(String, String, String[])
     */
    public static int queryCount(String table) {
        return queryCount(table, null, null);
    }

    public static boolean queryHasResults(Cursor cursor) {
        boolean result = cursor.getCount() > 0;
        cursor.close();
        return result;
    }

    /**
     * Gets photo names from the specified table and id. If id is null, returns all photos in the
     * specified table.
     *
     * @param table The photo table to query.
     * @param id The object id to query.
     * @return An ArrayList<String> of photo names.
     */
    public static ArrayList<String> queryPhotos(String table, UUID id) {
        ArrayList<String> photos = new ArrayList<>();
        Cursor cursor;

        if (id != null)
            cursor = simpleQuery(table, PhotoTable.Columns.NAME, PhotoTable.Columns.USER_DEFINE_ID + " = ?", new String[] { id.toString() });
        else
            cursor = simpleQuery(table, PhotoTable.Columns.NAME, null, null);

        if (cursor.moveToFirst())
            while (!cursor.isAfterLast()) {
                photos.add(cursor.getString(cursor.getColumnIndex(PhotoTable.Columns.NAME)));
                cursor.moveToNext();
            }

        cursor.close();
        return photos;
    }

    public static boolean insertQuery(String table, ContentValues contentValues) {
        try {
            return mDatabase.insert(table, null, contentValues) != -1;
        } catch (SQLiteException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteQuery(String table, String whereClause, String[] args) {
        try {
            return mDatabase.delete(table, whereClause, args) == 1;
        } catch (SQLiteException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean updateQuery(String table, ContentValues newContentValues, String whereClause, String[] args) {
        try {
            return mDatabase.update(table, newContentValues, whereClause, args) == 1;
        } catch (SQLiteException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * The Replace method uses the row's PRIMARY KEY to insert or update the row.
     *
     * @param table The table.
     * @param contentValues The replacement ContentValues.
     * @return True is successful, false otherwise.
     */
    public static boolean replaceQuery(String table, ContentValues contentValues) {
        try {
            return mDatabase.replace(table, null, contentValues) != -1;
        } catch (SQLiteException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteUserDefine(String table, UUID id) {
        return deleteQuery(table, UserDefineTable.Columns.ID + " = ?", new String[]{id.toString()});
    }

    public static boolean updateUserDefine(String table, ContentValues contentValues, UUID id) {
        return updateQuery(table, contentValues, UserDefineTable.Columns.ID + " = ?", new String[]{id.toString()});
    }

    public static boolean deletePhoto(String table, String fileName) {
        return deleteQuery(table, PhotoTable.Columns.NAME + " = ?", new String[]{fileName});
    }

    /**
     * Gets the number of photos associated with the given {@link UserDefineObject} id.
     *
     * @param table The table (i.e. BaitPhotoTable.NAME).
     * @param id The id of the object for which to count photos.
     * @return The number of photos associated with the given id.
     */
    public static int getPhotoCount(String table, UUID id) {
        return queryCount(table, PhotoTable.Columns.USER_DEFINE_ID + " = ?", new String[]{id.toString()});
    }

    /**
     * Retrieves the weather data for the specified catch id.
     *
     * @param catchId The {@link com.cohenadair.anglerslog.model.user_defines.Catch} id.
     * @return A {@link Weather} object for the given catch id.
     */
    @Nullable
    public static Weather queryWeather(UUID catchId) {
        WeatherCursor cursor = new WeatherCursor(simpleQuery(
                WeatherTable.NAME,
                "*",
                WeatherTable.Columns.CATCH_ID + " = ?",
                new String[] { catchId.toString() }
        ));

        if (cursor.moveToFirst())
            return cursor.getWeather();

        return null;
    }

    /**
     * Queries for the sum of the quantities for all the catches in a given {@link Bait}.
     *
     * @see #getTotalCatchQuantity(Cursor)
     *
     * @param bait The {@link Bait} to look for.
     * @return The total number of catches associated with the given {@link Bait}.
     */
    public static int queryBaitsCatchCount(Bait bait) {
        return getTotalCatchQuantity(queryCatches(
                CatchTable.Columns.QUANTITY,
                CatchTable.Columns.BAIT_ID + " IN (" +
                        "SELECT " + BaitTable.Columns.ID + " " +
                        "FROM " + BaitTable.NAME + " " +
                        "WHERE(" + BaitTable.Columns.ID + " = ?)" +
                        ")",
                new String[] { bait.getIdAsString() }
        ));
    }

    /**
     * Queries for the sum of the quantities for all the catches in a given {@link Trip}.
     *
     * @see #getTotalCatchQuantity(Cursor)
     *
     * @param trip The {@link Trip} for which to count catches.
     * @return The quantity of catches.
     */
    public static int queryTripsCatchCount(Trip trip) {
        return getTotalCatchQuantity(queryCatches(
                CatchTable.Columns.QUANTITY,
                CatchTable.Columns.ID + " IN (" +
                        "SELECT " + UsedCatchTable.Columns.CATCH_ID + " " +
                        "FROM " + UsedCatchTable.NAME + " " +
                        "WHERE(" + UsedCatchTable.Columns.TRIP_ID + " = ?)" +
                ")",
                new String[] { trip.getIdAsString() }
        ));
    }

    /**
     * @param trip The {@link Trip} object.
     * @param location The {@link Location} object.
     * @return The number of catches for the given {@link Trip} at the given {@link Location}.
     *
     * @see #getTotalCatchQuantity(Cursor)
     */
    public static int queryTripsLocationCatchCount(Trip trip, Location location) {
        return getTotalCatchQuantity(queryCatches(
                CatchTable.Columns.QUANTITY,
                CatchTable.Columns.FISHING_SPOT_ID + " IN (" +
                        "SELECT " + FishingSpotTable.Columns.ID + " " +
                        "FROM " + FishingSpotTable.NAME + " " +
                        "WHERE(" + FishingSpotTable.Columns.LOCATION_ID + " = ?)" +
                ") " +
                "AND " + CatchTable.Columns.ID + " IN (" +
                        "SELECT " + UsedCatchTable.Columns.CATCH_ID + " " +
                        "FROM " + UsedCatchTable.NAME + " " +
                        "WHERE(" + UsedCatchTable.Columns.TRIP_ID + " = ?)" +
                ")",
                new String[] { location.getIdAsString(), trip.getIdAsString() }
        ));
    }

    /**
     * @param location The {@link Location} to check for catches.
     * @return The number of catches made at the given {@link Location}.
     *
     * @see #getTotalCatchQuantity(Cursor)
     */
    public static int queryLocationCatchCount(Location location) {
        return getTotalCatchQuantity(queryCatches(
                CatchTable.Columns.QUANTITY,
                CatchTable.Columns.FISHING_SPOT_ID + " IN (" +
                        "SELECT " + FishingSpotTable.Columns.ID + " " +
                        "FROM " + FishingSpotTable.NAME + " " +
                        "WHERE (" + FishingSpotTable.Columns.LOCATION_ID + " = ?)" +
                ")",
                new String[] { location.getIdAsString() }
        ));
    }

    /**
     * @param fishingSpot The {@link FishingSpot} to query for.
     * @return The number of catches made at the given {@link FishingSpot}.
     *
     * @see #getTotalCatchQuantity(Cursor)
     */
    public static int queryFishingSpotCatchCount(FishingSpot fishingSpot) {
        return getTotalCatchQuantity(queryCatches(
                CatchTable.Columns.QUANTITY,
                CatchTable.Columns.FISHING_SPOT_ID + " IN (" +
                        "SELECT " + FishingSpotTable.Columns.ID + " " +
                        "FROM " + FishingSpotTable.NAME + " " +
                        "WHERE (" + FishingSpotTable.Columns.ID + " = ?)" +
                ")",
                new String[] { fishingSpot.getIdAsString() }
        ));
    }

    /**
     * Gets the {@link Catch} quantities that match the given parameters. For example, one might
     * check CatchTable.Columns.SPECIES_ID for the total number of catches for that particular
     * species.
     *
     * @param object The {@link UserDefineObject} to look for in the given column.
     * @param catchColumn The table column to compare the given object to.
     * @return The number of catches based on the given criteria.
     *
     * @see #getTotalCatchQuantity(Cursor)
     */
    public static int queryUserDefineCatchCount(UserDefineObject object, String catchColumn) {
        return queryUserDefineCatchCount(
                catchColumn + " = ?",
                new String[] { object.getIdAsString() }
        );
    }

    /**
     * Works like {@link #queryUserDefineCatchCount(UserDefineObject, String)} except it takes in
     * a custom where clause.
     *
     * @see #queryUserDefineCatchCount(UserDefineObject, String)
     */
    public static int queryUserDefineCatchCount(String whereClause, String[] args) {
        return getTotalCatchQuantity(queryCatches(CatchTable.Columns.QUANTITY, whereClause, args));
    }

    /**
     * Adds together all values from the given {@link Cursor}.
     *
     * Note that SQLite's SUM() function is not used here because if the user doesn't fill out
     * the catch quantity field, that property is set to -1. This method assumes that any catch
     * without an assigned quantity has a quantity of 1.
     *
     * @param cursor The {@link Cursor} to iterate.
     * @return The total value of each value in the given {@link Cursor}.
     */
    public static int getTotalCatchQuantity(Cursor cursor) {
        int count = 0;

        if (cursor.moveToFirst())
            while (!cursor.isAfterLast()){
                int c = cursor.getInt(cursor.getColumnIndex(CatchTable.Columns.QUANTITY));
                count += (c > 0) ? c : 1; // if the quantity wasn't set, assume 1 was caught
                cursor.moveToNext();
            }

        cursor.close();
        return count;
    }

    /**
     * Gets a {@link Catch} with the highest value at the specified column.
     *
     * @param column The column with max value.
     * @param species The species to get the max value. This value can be null.
     * @return The {@link Catch} object with the highest value at the given column for the given
     *         {@link Species}.
     */
    @Nullable
    public static Catch queryCatchMax(String column, Species species) {
        String sql = "SELECT * FROM " + CatchTable.NAME + " WHERE " + column + " IN (" + "SELECT MAX(" + column    + ") FROM " + CatchTable.NAME;

        if (species != null)
            sql += " WHERE " + CatchTable.Columns.SPECIES_ID + " = ?) AND (" + CatchTable.Columns.SPECIES_ID + " = ?";

        sql += ")";

        CatchCursor cursor = new CatchCursor(mDatabase.rawQuery(sql, species == null ? null : new String[] { species.getIdAsString(), species.getIdAsString() }));

        if (cursor.moveToFirst())
            return cursor.getCatch();

        return null;
    }

    /**
     * Gets the largest {@link Catch} for the given column, regardless of species.
     * @see #queryCatchMax(String, Species)
     */
    @Nullable
    public static Catch queryCatchMax(String column) {
        return queryCatchMax(column, null);
    }
}
