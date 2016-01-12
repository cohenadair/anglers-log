package com.cohenadair.anglerslog.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.cohenadair.anglerslog.database.LogbookSchema.SpeciesTable;

import static com.cohenadair.anglerslog.database.LogbookSchema.*;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitCategoryTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.FishingMethodTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.FishingSpotTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.LocationTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.WaterClarityTable;

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
        createCatchTable(db);
        createSpeciesTable(db);
        createBaitCategoryTable(db);
        createBaitTable(db);
        createPhotoTables(db);
        createLocationTable(db);
        createFishingSpotTable(db);
        createFishingMethodTable(db);
        createUsedFishingMethodTable(db);
        createWaterClarityTable(db);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

    }

    private void createCatchTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + CatchTable.NAME + "(" +
            CatchTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            CatchTable.Columns.NAME + " TEXT NOT NULL, " +
            CatchTable.Columns.DATE + " INTEGER UNIQUE NOT NULL, " +
            CatchTable.Columns.SPECIES_ID + " TEXT REFERENCES " + SpeciesTable.NAME + "(" + SpeciesTable.Columns.ID + "), " +
            CatchTable.Columns.BAIT_ID + " TEXT REFERENCES " + BaitTable.NAME + "(" + BaitTable.Columns.ID + "), " +
            CatchTable.Columns.FISHING_SPOT_ID + " TEXT REFERENCES " + FishingSpotTable.NAME + "(" + FishingSpotTable.Columns.ID + "), " +
            CatchTable.Columns.CLARITY_ID + " TEXT REFERENCES " + WaterClarityTable.NAME + "(" + WaterClarityTable.Columns.ID + "), " +
            CatchTable.Columns.CATCH_RESULT + " INTEGER, " +
            CatchTable.Columns.IS_FAVORITE + " INTEGER" +
            ")"
        );
    }

    private void createSpeciesTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + SpeciesTable.NAME + "(" +
            SpeciesTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            SpeciesTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );
    }

    private void createBaitCategoryTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + BaitCategoryTable.NAME + "(" +
            BaitCategoryTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            BaitCategoryTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );
    }

    private void createBaitTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + BaitTable.NAME + "(" +
            BaitTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            BaitTable.Columns.NAME + " TEXT NOT NULL, " +
            BaitTable.Columns.CATEGORY_ID + " TEXT NOT NULL REFERENCES " + BaitCategoryTable.NAME + "(" + BaitCategoryTable.Columns.ID + "), " +
            BaitTable.Columns.COLOR + " TEXT, " +
            BaitTable.Columns.SIZE + " TEXT, " +
            BaitTable.Columns.DESCRIPTION + " TEXT, " +
            BaitTable.Columns.TYPE + " INTEGER, " +
            "UNIQUE(" + BaitTable.Columns.NAME + ", " + BaitTable.Columns.CATEGORY_ID + ")" +
            ")"
        );
    }

    private void createLocationTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + LocationTable.NAME + "(" +
            LocationTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            LocationTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );
    }

    private void createFishingSpotTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + FishingSpotTable.NAME + "(" +
            FishingSpotTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            FishingSpotTable.Columns.NAME + " TEXT NOT NULL, " +
            FishingSpotTable.Columns.LOCATION_ID + " TEXT NOT NULL, " +
            FishingSpotTable.Columns.LATITUDE + " REAL," +
            FishingSpotTable.Columns.LONGITUDE + " REAL, " +
            "UNIQUE(" + FishingSpotTable.Columns.NAME + ", " + FishingSpotTable.Columns.LOCATION_ID + ")" +
            ")"
        );
    }

    private void createFishingMethodTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + FishingMethodTable.NAME + "(" +
            FishingMethodTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            FishingMethodTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );
    }

    private void createUsedFishingMethodTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + UsedFishingMethodsTable.NAME + "(" +
            UsedFishingMethodsTable.Columns.CATCH_ID + " TEXT NOT NULL, " +
            UsedFishingMethodsTable.Columns.FISHING_METHOD_ID + " TEXT NOT NULL REFERENCES " + FishingMethodTable.NAME + "(" + FishingMethodTable.Columns.ID + "), " +
            "UNIQUE(" + UsedFishingMethodsTable.Columns.CATCH_ID + ", " + UsedFishingMethodsTable.Columns.FISHING_METHOD_ID + ")" +
            ")"
        );
    }

    private void createWaterClarityTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + WaterClarityTable.NAME + "(" +
            WaterClarityTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            WaterClarityTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );
    }

    private void createPhotoTables(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + CatchPhotoTable.NAME + "(" +
            CatchPhotoTable.Columns.USER_DEFINE_ID + " TEXT, " +
            CatchPhotoTable.Columns.NAME + " TEXT NOT NULL" +
            ")"
        );

        db.execSQL("CREATE TABLE " + BaitPhotoTable.NAME + "(" +
            BaitPhotoTable.Columns.USER_DEFINE_ID + " TEXT, " +
            BaitPhotoTable.Columns.NAME + " TEXT NOT NULL" +
            ")"
        );
    }
}
