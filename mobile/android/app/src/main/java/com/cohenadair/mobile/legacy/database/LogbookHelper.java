package com.cohenadair.mobile.legacy.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.cohenadair.mobile.legacy.database.LogbookSchema.SpeciesTable;

import static com.cohenadair.mobile.legacy.database.LogbookSchema.AnglerTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.BaitCategoryTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.BaitPhotoTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.BaitTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.CatchTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.FishingMethodTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.FishingSpotTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.LocationTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.TripTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.UsedAnglerTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.UsedCatchTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.UsedFishingMethodTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.UsedLocationTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.WaterClarityTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.WeatherTable;

/**
 * The LogbookHelper is a {@link SQLiteOpenHelper} subclass that interacts with the application's
 * database.
 *
 * @author Cohen Adair
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
        createAnglerTable(db);
        createTripTable(db);
        createUsedFishingMethodTable(db);
        createUsedAnglerTable(db);
        createUsedCatchTable(db);
        createUsedLocationTable(db);
        createWaterClarityTable(db);
        createWeatherTable(db);
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
            CatchTable.Columns.IS_FAVORITE + " INTEGER, " +
            CatchTable.Columns.SELECTED + " INTEGER, " +
            CatchTable.Columns.LENGTH + " REAL, " +
            CatchTable.Columns.WEIGHT + " REAL, " +
            CatchTable.Columns.WATER_DEPTH + " REAL, " +
            CatchTable.Columns.WATER_TEMPERATURE + " INTEGER, " +
            CatchTable.Columns.QUANTITY + " INTEGER, " +
            CatchTable.Columns.NOTES + " TEXT" +
            ")"
        );
    }

    private void createSpeciesTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + SpeciesTable.NAME + "(" +
            SpeciesTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            SpeciesTable.Columns.NAME + " TEXT UNIQUE NOT NULL, " +
            SpeciesTable.Columns.SELECTED + " INTEGER" +
            ")"
        );
    }

    private void createBaitCategoryTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + BaitCategoryTable.NAME + "(" +
            BaitCategoryTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            BaitCategoryTable.Columns.SELECTED + " INTEGER, " +
            BaitCategoryTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );
    }

    private void createBaitTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + BaitTable.NAME + "(" +
            BaitTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            BaitTable.Columns.NAME + " TEXT NOT NULL, " +
            BaitTable.Columns.SELECTED + " INTEGER, " +
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
            LocationTable.Columns.NAME + " TEXT UNIQUE NOT NULL, " +
            LocationTable.Columns.SELECTED + " INTEGER" +
            ")"
        );
    }

    private void createFishingSpotTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + FishingSpotTable.NAME + "(" +
            FishingSpotTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            FishingSpotTable.Columns.NAME + " TEXT NOT NULL, " +
            FishingSpotTable.Columns.SELECTED + " INTEGER, " +
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
            FishingMethodTable.Columns.SELECTED + " INTEGER, " +
            FishingMethodTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );
    }

    public void createTripTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + TripTable.NAME + "(" +
            TripTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            TripTable.Columns.NAME + " TEXT, " +
            TripTable.Columns.SELECTED + " INTEGER, " +
            TripTable.Columns.START_DATE + " INTEGER UNIQUE NOT NULL, " +
            TripTable.Columns.END_DATE + " INTEGER UNIQUE NOT NULL, " +
            TripTable.Columns.NOTES + " TEXT" +
            ")"
        );
    }

    public void createAnglerTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + AnglerTable.NAME + "(" +
            AnglerTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            AnglerTable.Columns.SELECTED + " INTEGER, " +
            AnglerTable.Columns.NAME + " TEXT UNIQUE NOT NULL" +
            ")"
        );
    }

    public void createUsedAnglerTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + UsedAnglerTable.NAME + "(" +
            UsedAnglerTable.Columns.TRIP_ID + " TEXT NOT NULL, " +
            UsedAnglerTable.Columns.ANGLER_ID + " TEXT NOT NULL REFERENCES " + AnglerTable.NAME + "(" + AnglerTable.Columns.ID + "), " +
            "UNIQUE(" + UsedAnglerTable.Columns.TRIP_ID + ", " + UsedAnglerTable.Columns.ANGLER_ID + ")" +
            ")"
        );
    }

    public void createUsedLocationTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + UsedLocationTable.NAME + "(" +
            UsedLocationTable.Columns.TRIP_ID + " TEXT NOT NULL, " +
            UsedLocationTable.Columns.LOCATION_ID + " TEXT NOT NULL REFERENCES " + LocationTable.NAME + "(" + LocationTable.Columns.ID + "), " +
            "UNIQUE(" + UsedLocationTable.Columns.TRIP_ID + ", " + UsedLocationTable.Columns.LOCATION_ID + ")" +
            ")"
        );
    }

    public void createUsedCatchTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + UsedCatchTable.NAME + "(" +
            UsedCatchTable.Columns.TRIP_ID + " TEXT NOT NULL, " +
            UsedCatchTable.Columns.CATCH_ID + " TEXT NOT NULL REFERENCES " + CatchTable.NAME + "(" + CatchTable.Columns.ID + "), " +
            "UNIQUE(" + UsedCatchTable.Columns.TRIP_ID + ", " + UsedCatchTable.Columns.CATCH_ID + ")" +
            ")"
        );
    }

    private void createUsedFishingMethodTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + UsedFishingMethodTable.NAME + "(" +
            UsedFishingMethodTable.Columns.CATCH_ID + " TEXT NOT NULL, " + // not REFERENCES because table entries are added after Catch entries (results in FOREIGN KEY constraint failure)
            UsedFishingMethodTable.Columns.FISHING_METHOD_ID + " TEXT NOT NULL REFERENCES " + FishingMethodTable.NAME + "(" + FishingMethodTable.Columns.ID + "), " +
            "UNIQUE(" + UsedFishingMethodTable.Columns.CATCH_ID + ", " + UsedFishingMethodTable.Columns.FISHING_METHOD_ID + ")" +
            ")"
        );
    }

    private void createWaterClarityTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + WaterClarityTable.NAME + "(" +
            WaterClarityTable.Columns.ID + " TEXT PRIMARY KEY NOT NULL, " +
            WaterClarityTable.Columns.SELECTED + " INTEGER, " +
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

    public void createWeatherTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + WeatherTable.NAME + "(" +
            WeatherTable.Columns.CATCH_ID + " TEXT PRIMARY KEY NOT NULL, " + // not REFERENCES because Weather entries are added after Catch entries (results in FOREIGN KEY constraint failure)
            WeatherTable.Columns.TEMPERATURE + " INTEGER NOT NULL, " +
            WeatherTable.Columns.WIND_SPEED + " INTEGER NOT NULL, " +
            WeatherTable.Columns.SKY_CONDITIONS + " TEXT NOT NULL" +
            ")"
        );
    }
}
