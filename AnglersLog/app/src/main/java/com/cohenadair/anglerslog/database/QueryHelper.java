package com.cohenadair.anglerslog.database;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

import com.cohenadair.anglerslog.database.cursors.BaitCursor;
import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.database.cursors.WeatherCursor;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.FishingSpotTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.PhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.UsedCatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.UserDefineTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.WeatherTable;

// TODO finish documentation for this file

/**
 * A class for easy database querying.
 * Created by Cohen Adair on 2015-10-24.
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

    private QueryHelper() { }

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
        return new CatchCursor(mDatabase.query(CatchTable.NAME, null, whereClause, args, null, null, null));
    }

    @NonNull
    public static CatchCursor queryCatches(String[] cols, String whereClause, String[] args) {
        return new CatchCursor(mDatabase.query(CatchTable.NAME, cols, whereClause, args, null, null, null));
    }

    @NonNull
    public static BaitCursor queryBaits(String whereClause, String[] args) {
        return new BaitCursor(mDatabase.query(BaitTable.NAME, null, whereClause, args, null, null, null));
    }

    @NonNull
    public static UserDefineCursor queryUserDefines(String table, String whereClause, String[] args) {
        return new UserDefineCursor(mDatabase.query(table, null, whereClause, args, null, null, UserDefineTable.Columns.NAME));
    }

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

    public static UserDefineObject queryUserDefine(String table, UUID id, UserDefineQueryInterface callbacks) {
        return queryUserDefine(table, UserDefineTable.Columns.ID, id.toString(), callbacks);
    }

    public static UserDefineObject queryUserDefine(String table, String column, String columnValue, UserDefineQueryInterface callbacks) {
        return queryUserDefine(table, column + " = ?", new String[] { columnValue }, callbacks);
    }

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

    public static int queryCount(String table, String whereClause, String[] args) {
        int count = 0;
        Cursor cursor = mDatabase.query(table, new String[]{COUNT}, whereClause, args, null, null, null);

        if (cursor.moveToFirst())
            count = cursor.getInt(cursor.getColumnIndex(COUNT));

        cursor.close();
        return count;
    }

    public static int queryCount(String table) {
        return queryCount(table, null, null);
    }

    public static boolean queryHasResults(Cursor cursor) {
        boolean result = cursor.getCount() > 0;
        cursor.close();
        return result;
    }

    public static boolean queryBoolean(Cursor cursor, String column) {
        boolean result = false;

        if (cursor.moveToFirst())
            result = cursor.getInt(cursor.getColumnIndex(column)) == 1;

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
        return deleteQuery(table, UserDefineTable.Columns.ID + " = ?", new String[]{ id.toString() });
    }

    public static boolean updateUserDefine(String table, ContentValues contentValues, UUID id) {
        return updateQuery(table, contentValues, UserDefineTable.Columns.ID + " = ?", new String[]{id.toString()});
    }

    public static boolean deletePhoto(String table, String fileName) {
        return deleteQuery(table, PhotoTable.Columns.NAME + " = ?", new String[]{fileName});
    }

    public static int photoCount(String table, UUID id) {
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
     * Queries for the sum of the quantities for all the catches in a given {@link Trip}.
     *
     * @param trip The {@link Trip} for which to count catches.
     * @return The quantity of catches.
     */
    public static int queryTripsCatchCount(Trip trip) {
        String totalQuantity = "totalQuantity";

        // SELECT SUM(quantity) AS totalQuantity FROM Catch WHERE id IN (SELECT catchId FROM UsedCatch WHERE(tripId = givenId));
        return querySingleValue(
                totalQuantity,
                "SELECT SUM(" + CatchTable.Columns.QUANTITY + ") AS " + totalQuantity + " " +
                "FROM " + CatchTable.NAME + " " +
                "WHERE " + CatchTable.Columns.ID + " IN (" +
                    "SELECT " + UsedCatchTable.Columns.CATCH_ID + " " +
                    "FROM " + UsedCatchTable.NAME + " " +
                    "WHERE(" + UsedCatchTable.Columns.TRIP_ID + " = ?)" +
                ")",
                new String[]{ trip.idAsString() });
    }

    /**
     * Queries for the number of catches for a give {@link Trip} at a given {@link Location}.
     *
     * @param trip The {@link Trip} object.
     * @param location The {@link Location} object.
     * @return The number of catches for the given trip at the given location.
     */
    public static int queryTripsLocationCatchCount(Trip trip, Location location) {
        String totalQuantity = "totalQuantity";

        return querySingleValue(
                totalQuantity,
                "SELECT SUM(" + CatchTable.Columns.QUANTITY + ") AS " + totalQuantity + " " +
                "FROM " + CatchTable.NAME + " " +
                "WHERE " + CatchTable.Columns.FISHING_SPOT_ID + " IN (" +
                    "SELECT " + FishingSpotTable.Columns.ID + " " +
                    "FROM " + FishingSpotTable.NAME + " " +
                    "WHERE(" + FishingSpotTable.Columns.LOCATION_ID + " = ?)" +
                ") " +
                "AND " + CatchTable.Columns.ID + " IN (" +
                    "SELECT " + UsedCatchTable.Columns.CATCH_ID + " " +
                    "FROM " + UsedCatchTable.NAME + " " +
                    "WHERE(" + UsedCatchTable.Columns.TRIP_ID + " = ?)" +
                ")",
                new String[]{ location.idAsString(), trip.idAsString() }
        );
    }

    public static int queryLocationCatchCount(Location location) {
        String totalQuantity = "totalQuantity";

        return querySingleValue(
                totalQuantity,
                "SELECT SUM(" + CatchTable.Columns.QUANTITY + ") AS " + totalQuantity + " " +
                "FROM " + CatchTable.NAME + " " +
                "WHERE " + CatchTable.Columns.FISHING_SPOT_ID + " IN (" +
                    "SELECT " + FishingSpotTable.Columns.ID + " " +
                    "FROM " + FishingSpotTable.NAME + " " +
                    "WHERE(" + FishingSpotTable.Columns.LOCATION_ID + " = ?)" +
                ") ",
                new String[]{ location.idAsString() }
        );
    }

    public static int queryUserDefineCatchCount(UserDefineObject object, String catchColumn) {
        String total = "total";
        return querySingleValue(
                total,
                "SELECT SUM(" + CatchTable.Columns.QUANTITY + ") AS " + total + " " +
                "FROM " + CatchTable.NAME + " " +
                "WHERE (" + catchColumn + " = ?)",
                new String[]{ object.idAsString() }
        );
    }

    /**
     * Gets a {@link Catch} with the highest value at the specified column.
     *
     * @param column The column with max value.
     * @param species The species to get the max value. This value can be null.
     * @return A {@link Catch} object.
     */
    @Nullable
    public static Catch queryCatchMax(String column, Species species) {
        String sql = "SELECT * FROM " + CatchTable.NAME + " WHERE " + column + " IN (" + "SELECT MAX(" + column + ") FROM " + CatchTable.NAME;

        if (species != null)
            sql += " WHERE " + CatchTable.Columns.SPECIES_ID + " = ?";

        CatchCursor cursor = new CatchCursor(mDatabase.rawQuery(sql + ")", species == null ? null : new String[] { species.idAsString() }));

        if (cursor.moveToFirst())
            return cursor.getCatch();

        return null;
    }

    @Nullable
    public static Catch queryCatchMax(String column) {
        return queryCatchMax(column, null);
    }

    private static int querySingleValue(String colName, String sql, String[] args) {
        int value = 0;

        Cursor cursor = mDatabase.rawQuery(sql, args);

        if (cursor.moveToFirst())
            value = cursor.getInt(cursor.getColumnIndex(colName));

        cursor.close();
        return value;
    }
}
