package com.cohenadair.anglerslog.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.cohenadair.anglerslog.database.LogbookSchema.CatchPhotoTable;
import com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import com.cohenadair.anglerslog.database.LogbookSchema.SpeciesTable;

import static com.cohenadair.anglerslog.database.LogbookSchema.*;

/**
 * The LogbookHelper is a {@link SQLiteOpenHelper} subclass that interacts with the application's
 * database.
 *
 * Created by Cohen Adair on 2015-10-24.
 */
public class LogbookHelper extends SQLiteOpenHelper {

    public static final int VERSION = 1;
    public static final String DATABASE_EXT = ".db";
    public static final String DATABASE_NAME = "AnglersLogData" + DATABASE_EXT;

    public LogbookHelper(Context context) {
        super(context, DATABASE_NAME, null, VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + CatchTable.NAME + "(" +
            CatchTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            CatchTable.Columns.NAME + " TEXT UNIQUE NOT NULL, " +
            CatchTable.Columns.DATE + " INTEGER UNIQUE NOT NULL, " +
            CatchTable.Columns.SPECIES_ID + " TEXT REFERENCES " + SpeciesTable.NAME + "(" + SpeciesTable.Columns.ID + "), " +
            CatchTable.Columns.IS_FAVORITE + " INTEGER" +
            ")"
        );

        db.execSQL("CREATE TABLE " + SpeciesTable.NAME + "(" +
            SpeciesTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            SpeciesTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );

        db.execSQL("CREATE TABLE " + BaitCategoryTable.NAME + "(" +
            BaitCategoryTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            BaitCategoryTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );

        db.execSQL("CREATE TABLE " + BaitTable.NAME + "(" +
            BaitTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            BaitTable.Columns.NAME + " TEXT NOT NULL, " +
            BaitTable.Columns.CATEGORY_ID + " TEXT REFERENCES " + BaitCategoryTable.NAME + "(" + BaitCategoryTable.Columns.ID + "), " +
            "UNIQUE(" + BaitTable.Columns.NAME + ", " + BaitTable.Columns.CATEGORY_ID + ")" +
            ")"
        );

        db.execSQL("CREATE TABLE " + CatchPhotoTable.NAME + "(" +
            CatchPhotoTable.Columns.USER_DEFINE_ID + " TEXT, " +
            CatchPhotoTable.Columns.NAME + " TEXT NOT NULL" +
            ")"
        );
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }
}
