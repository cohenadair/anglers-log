package com.cohenadair.anglerslog.database;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
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
        return new UserDefineCursor(mDatabase.query(table, null, whereClause, args, null, null, null));
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

    public static ArrayList<String> queryPhotos(String table, String whereClause, String[] args) {
        ArrayList<String> catches = new ArrayList<>();
        Cursor cursor = mDatabase.query(table, new String[] { PhotoTable.Columns.NAME }, whereClause, args, null, null, null);

        if (cursor.moveToFirst())
            while (!cursor.isAfterLast()) {
                catches.add(cursor.getString(cursor.getColumnIndex(PhotoTable.Columns.NAME)));
                cursor.moveToNext();
            }

        cursor.close();
        return catches;
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
        UserDefineCursor cursor = QueryHelper.queryUserDefines(table, UserDefineTable.Columns.ID + " = ?", new String[]{ id.toString() });

        if (cursor.moveToFirst())
            obj = (callbacks == null) ? cursor.getObject() : callbacks.getObject(cursor);

        cursor.close();
        return obj;
    }

    public static boolean insertUserDefine(String table, ContentValues contentValues) {
        return mDatabase.insert(table, null, contentValues) != -1;
    }

    public static boolean deleteUserDefine(String table, UUID id) {
        return mDatabase.delete(table, UserDefineTable.Columns.ID + " = ?", new String[]{ id.toString() }) == 1;
    }

    public static boolean updateUserDefine(String table, ContentValues contentValues, UUID id) {
        return mDatabase.update(table, contentValues, UserDefineTable.Columns.ID + " = ?", new String[] { id.toString() }) == 1;
    }
}
