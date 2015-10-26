package com.cohenadair.anglerslog.database;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;

import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;

import java.util.ArrayList;

import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.PhotoTable;

/**
 * A class for easy database querying.
 * Created by Cohen Adair on 2015-10-24.
 */
public class QueryHelper {

    private static final String COUNT = "COUNT(*)";

    private static SQLiteDatabase mDatabase;

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
}
