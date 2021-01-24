package com.cohenadair.mobile.legacy.database;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.cohenadair.mobile.legacy.Weather;
import com.cohenadair.mobile.legacy.database.LogbookSchema.BaitTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.CatchTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.PhotoTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.TripTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.UserDefineTable;
import com.cohenadair.mobile.legacy.database.LogbookSchema.WeatherTable;
import com.cohenadair.mobile.legacy.database.cursors.BaitCursor;
import com.cohenadair.mobile.legacy.database.cursors.CatchCursor;
import com.cohenadair.mobile.legacy.database.cursors.TripCursor;
import com.cohenadair.mobile.legacy.database.cursors.UserDefineCursor;
import com.cohenadair.mobile.legacy.database.cursors.WeatherCursor;
import com.cohenadair.mobile.legacy.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.UUID;

/**
 * A class for easy database querying. This is also used so the rest of the application doesn't
 * need to interact directly with the database.
 *
 * @author Cohen Adair
 */
public class QueryHelper {
    private static SQLiteDatabase mDatabase;

    public interface UserDefineQueryInterface {
        UserDefineObject getObject(UserDefineCursor cursor);
    }

    public interface UsedQueryCallbacks {
        UserDefineObject getFromLogbook(String id);
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
    public static UserDefineObject queryUserDefine(String table, String column, String columnValue, UserDefineQueryInterface callbacks) {
        return queryUserDefine(table, column + " = ?", new String[] { columnValue }, callbacks);
    }

    /**
     * Retrieves a single {@link UserDefineObject} from the database.
     *
     * @param callbacks Callbacks for casting the resulting {@link UserDefineObject}.
     * @return A {@link UserDefineObject} subclass.
     *
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
                objs.add(callbacks.getFromLogbook(cursor.getString(cursor.getColumnIndex(resultColumn))));
                cursor.moveToNext();
            }

        cursor.close();
        return objs;
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

    public static boolean deleteQuery(String table, String whereClause, String[] args) {
        try {
            return mDatabase.delete(table, whereClause, args) == 1;
        } catch (SQLiteException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deletePhoto(String table, String fileName) {
        return deleteQuery(table, PhotoTable.Columns.NAME + " = ?", new String[]{fileName});
    }

    /**
     * Retrieves the weather data for the specified catch id.
     *
     * @param catchId The {@link com.cohenadair.mobile.legacy.user_defines.Catch} id.
     * @return A {@link com.cohenadair.mobile.legacy.Weather} object for the given catch id.
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
}
