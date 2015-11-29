package com.cohenadair.anglerslog.database;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.support.annotation.NonNull;

import com.cohenadair.anglerslog.database.cursors.BaitCursor;
import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.PhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.UserDefineTable;

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

    private QueryHelper() { }

    public static void setDatabase(SQLiteDatabase database) {
        mDatabase = database;
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

    public static int queryCount(String table, String whereClause, String[] args) {
        int count = 0;
        Cursor cursor = mDatabase.query(table, new String[] { COUNT }, whereClause, args, null, null, null);

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
            cursor = mDatabase.query(table, new String[] { PhotoTable.Columns.NAME }, PhotoTable.Columns.USER_DEFINE_ID + " = ?", new String[]{ id.toString() }, null, null, null);
        else
            cursor = mDatabase.query(table, new String[] { PhotoTable.Columns.NAME }, null, null, null, null, null);

        if (cursor.moveToFirst())
            while (!cursor.isAfterLast()) {
                photos.add(cursor.getString(cursor.getColumnIndex(PhotoTable.Columns.NAME)));
                cursor.moveToNext();
            }

        cursor.close();
        return photos;
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
        UserDefineObject obj = null;
        UserDefineCursor cursor = queryUserDefines(table, UserDefineTable.Columns.ID + " = ?", new String[]{ id.toString() });

        if (cursor.moveToFirst())
            obj = (callbacks == null) ? cursor.getObject() : callbacks.getObject(cursor);

        cursor.close();
        return obj;
    }

    public static boolean insertQuery(String table, ContentValues contentValues) {
        return mDatabase.insert(table, null, contentValues) != -1;
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
        return mDatabase.update(table, newContentValues, whereClause, args) == 1;
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
        return queryCount(table, PhotoTable.Columns.USER_DEFINE_ID + " = ?", new String[]{ id.toString() });
    }

}
