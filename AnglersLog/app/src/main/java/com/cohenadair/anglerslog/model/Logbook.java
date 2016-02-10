package com.cohenadair.anglerslog.model;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.database.cursors.AnglerCursor;
import com.cohenadair.anglerslog.database.cursors.BaitCategoryCursor;
import com.cohenadair.anglerslog.database.cursors.BaitCursor;
import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.FishingMethodCursor;
import com.cohenadair.anglerslog.database.cursors.FishingSpotCursor;
import com.cohenadair.anglerslog.database.cursors.LocationCursor;
import com.cohenadair.anglerslog.database.cursors.SpeciesCursor;
import com.cohenadair.anglerslog.database.cursors.TripCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.database.cursors.WaterClarityCursor;
import com.cohenadair.anglerslog.model.user_defines.Angler;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.FishingMethod;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;
import com.cohenadair.anglerslog.model.user_defines.WaterClarity;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.PhotoUtils;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.AnglerTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitCategoryTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.FishingMethodTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.FishingSpotTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.LocationTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.SpeciesTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.TripTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.WaterClarityTable;

/**
 * The Logbook class is a "monostate" class storing all of the user's log data.
 * @author Cohen Adair
 */
public class Logbook {

    public static final int UNIT_IMPERIAL = 0;
    public static final int UNIT_METRIC = 1;

    private static final String TAG = "Logbook";

    private static SQLiteDatabase mDatabase;
    private static Context mContext;

    private Logbook() { }

    public static void init(Context context) {
        init(context, new LogbookHelper(context).getWritableDatabase());
    }

    public static void init(Context context, SQLiteDatabase database) {
        mContext = context;
        mDatabase = database;
        mDatabase.setForeignKeyConstraintsEnabled(true);
        QueryHelper.setDatabase(mDatabase);
        cleanDatabasePhotos();
    }

    public static void initForTesting(Context context, SQLiteDatabase database) {
        init(context, database);
    }

    /**
     * Set some default UserDefineObjects if there aren't any.
     */
    public static void setDefaults() {
        if (getBaitCategoryCount() <= 0) {
            addBaitCategory(new BaitCategory("Lure"));
            addBaitCategory(new BaitCategory("Minnow"));
            addBaitCategory(new BaitCategory("Fly"));
        }

        if (getSpeciesCount() <= 0) {
            addSpecies(new Species("Steelhead"));
            addSpecies(new Species("Pike"));
            addSpecies(new Species("Bass - Smallmouth"));
            addSpecies(new Species("Salmon - Coho"));
        }

        if (getFishingMethodCount() <= 0) {
            addFishingMethod(new FishingMethod("Boat"));
            addFishingMethod(new FishingMethod("Shore"));
            addFishingMethod(new FishingMethod("Ice"));
            addFishingMethod(new FishingMethod("Trolling"));
        }

        if (getWaterClarityCount() <= 0) {
            addWaterClarity(new WaterClarity("Crystal Clear"));
            addWaterClarity(new WaterClarity("Clear"));
            addWaterClarity(new WaterClarity("Muddy"));
        }

        if (getBaitCount() <= 0) {
            BaitCategory baitCategory = getBaitCategory("Lure");
            if (baitCategory == null)
                addBaitCategory(new BaitCategory("Lure"));

            String spinner = "spinner_blue_fox.png";
            String rap = "rippin_rap.png";
            PhotoUtils.saveImageResource(R.drawable.spinner_blue_fox, spinner);
            PhotoUtils.saveImageResource(R.drawable.rippin_rap, rap);

            Bait bait = new Bait("Spinner - Blue Fox", baitCategory);
            bait.setType(Bait.TYPE_ARTIFICIAL);
            bait.setSize("6");
            bait.setColor("Silver");
            bait.addPhoto(spinner);
            Logbook.addBait(bait);

            bait = new Bait("Rippin' Rap", baitCategory);
            bait.setType(Bait.TYPE_ARTIFICIAL);
            bait.setSize("2");
            bait.setColor("Blue Chrome");
            bait.addPhoto(rap);
            Logbook.addBait(bait);
        }
    }

    /**
     * Completely resets the database.
     */
    public static void reset() {
        File data = new File(mDatabase.getPath());
        mDatabase.close();
        FileUtils.deleteQuietly(data);

        init(mContext);
        setDefaults();
    }

    //region Getters & Setters
    public static SQLiteDatabase getDatabase() {
        return mDatabase;
    }
    //endregion

    /**
     * Gets all of the user's catch photos.
     * @return A list of all the catch photo names.
     */
    @Nullable
    public static ArrayList<String> getAllCatchPhotos() {
        return QueryHelper.queryPhotos(CatchPhotoTable.NAME, null);
    }

    /**
     * Deletes all database entries for photos that aren't associated with any UserDefineObject
     * instances.
     */
    public static void cleanDatabasePhotos() {
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
        return QueryHelper.queryUserDefines(QueryHelper.queryCatches(null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new CatchCursor(cursor).getCatch();
            }
        });
    }

    public static Catch getCatch(UUID id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(CatchTable.NAME, id, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new CatchCursor(cursor).getCatch();
            }
        });

        return (obj == null) ? null : (Catch)obj;
    }

    public static boolean addCatch(Catch aCatch) {
        return QueryHelper.insertQuery(CatchTable.NAME, aCatch.getContentValues());
    }

    public static boolean removeCatch(UUID id) {
        Catch aCatch = Logbook.getCatch(id);
        aCatch.removeDatabaseProperties();
        return QueryHelper.deleteUserDefine(CatchTable.NAME, id);
    }

    public static boolean editCatch(UUID id, Catch newCatch) {
        return QueryHelper.updateUserDefine(CatchTable.NAME, newCatch.getContentValues(), id);
    }

    public static int getCatchCount() {
        return QueryHelper.queryCount(CatchTable.NAME);
    }

    public static Catch getLongestCatch() {
        return QueryHelper.queryCatchMax(CatchTable.Columns.LENGTH);
    }

    public static Catch getHeaviestCatch() {
        return QueryHelper.queryCatchMax(CatchTable.Columns.WEIGHT);
    }

    public static Catch getLongestCatch(Species species) {
        return QueryHelper.queryCatchMax(CatchTable.Columns.LENGTH, species);
    }

    public static Catch getHeaviestCatch(Species species) {
        return QueryHelper.queryCatchMax(CatchTable.Columns.WEIGHT, species);
    }
    //endregion

    //region Species Manipulation
    public static ArrayList<UserDefineObject> getSpecies() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(SpeciesTable.NAME, null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new SpeciesCursor(cursor).getSpecies();
            }
        });
    }

    public static Species getSpecies(UUID id) {
        return getSpecies(SpeciesTable.Columns.ID, id.toString());
    }

    public static Species getSpecies(String name) {
        return getSpecies(SpeciesTable.Columns.NAME, name);
    }

    private static Species getSpecies(String column, String columnValue) {
        UserDefineObject obj = QueryHelper.queryUserDefine(SpeciesTable.NAME, column, columnValue, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new SpeciesCursor(cursor).getSpecies();
            }
        });

        return (obj == null) ? null : (Species)obj;
    }

    public static boolean addSpecies(Species species) {
        return QueryHelper.insertQuery(SpeciesTable.NAME, species.getContentValues());
    }

    public static boolean removeSpecies(UUID id) {
        return QueryHelper.deleteUserDefine(SpeciesTable.NAME, id);
    }

    public static boolean editSpecies(UUID id, Species newSpecies) {
        return QueryHelper.updateUserDefine(SpeciesTable.NAME, newSpecies.getContentValues(), id);
    }

    public static int getSpeciesCount() {
        return QueryHelper.queryCount(SpeciesTable.NAME);
    }

    public static ArrayList<Stats.Quantity> getSpeciesCaughtCount() {
        return getCatchQuantity(getSpecies(), new OnQueryQuantityListener() {
            @Override
            public int query(UserDefineObject obj) {
                return QueryHelper.queryUserDefineCatchCount(obj, CatchTable.Columns.SPECIES_ID);
            }
        });
    }
    //endregion

    //region BaitCategory Manipulation
    public static ArrayList<UserDefineObject> getBaitCategories() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(BaitCategoryTable.NAME, null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new BaitCategoryCursor(cursor).getBaitCategory();
            }
        });
    }

    public static BaitCategory getBaitCategory(UUID id) {
        return getBaitCategory(BaitCategoryTable.Columns.ID, id.toString());
    }

    public static BaitCategory getBaitCategory(String name) {
        return getBaitCategory(BaitCategoryTable.Columns.NAME, name);
    }

    private static BaitCategory getBaitCategory(String column, String columnValue) {
        UserDefineObject obj = QueryHelper.queryUserDefine(BaitCategoryTable.NAME, column, columnValue, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new BaitCategoryCursor(cursor).getBaitCategory();
            }
        });

        return (obj == null) ? null : (BaitCategory)obj;
    }

    public static boolean addBaitCategory(BaitCategory baitCategory) {
        return QueryHelper.insertQuery(BaitCategoryTable.NAME, baitCategory.getContentValues());
    }

    public static boolean removeBaitCategory(UUID id) {
        return QueryHelper.deleteUserDefine(BaitCategoryTable.NAME, id);
    }

    public static boolean editBaitCategory(UUID id, BaitCategory newBaitCategory) {
        return QueryHelper.updateUserDefine(BaitCategoryTable.NAME, newBaitCategory.getContentValues(), id);
    }

    public static int getBaitCategoryCount() {
        return QueryHelper.queryCount(BaitCategoryTable.NAME);
    }
    //endregion

    //region Bait Manipulation
    public static ArrayList<UserDefineObject> getBaits() {
        return getBaits(null, null);
    }

    /**
     * Gets all {@link Bait} objects associated with the given {@link BaitCategory}.
     * @param baitCategory The BaitCategory.
     * @return An ArrayList of {@link Bait} objects.
     */
    public static ArrayList<UserDefineObject> getBaits(BaitCategory baitCategory) {
        return getBaits(BaitTable.Columns.CATEGORY_ID + " = ?", new String[]{baitCategory.idAsString()});
    }

    /**
     * Gets all {@link Bait} objects based on the given WHERE clause.
     * @param whereClause The WHERE clause.
     * @param args The WHERE clause arguments.
     * @return An ArrayList of {@link Bait} objects matching the WHERE clause.
     */
    private static ArrayList<UserDefineObject> getBaits(String whereClause, String[] args) {
        return QueryHelper.queryUserDefines(QueryHelper.queryBaits(whereClause, args), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new BaitCursor(cursor).getBait();
            }
        });
    }

    public static Bait getBait(UUID id) {
        return getBait(BaitTable.Columns.ID, id.toString());
    }

    public static Bait getBait(String name, UUID categoryId) {
        UserDefineObject obj = QueryHelper.queryUserDefine(
                BaitTable.NAME,
                BaitTable.Columns.NAME + " = ? AND " + BaitTable.Columns.CATEGORY_ID + " = ?",
                new String[]{ name, categoryId.toString() },
                getBaitQueryInterface()
        );
        return baitOrNull(obj);
    }

    private static Bait getBait(String column, String columnValue) {
        UserDefineObject obj = QueryHelper.queryUserDefine(BaitTable.NAME, column, columnValue, getBaitQueryInterface());
        return baitOrNull(obj);
    }

    @NonNull
    private static QueryHelper.UserDefineQueryInterface getBaitQueryInterface() {
        return new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new BaitCursor(cursor).getBait();
            }
        };
    }

    private static Bait baitOrNull(UserDefineObject obj) {
        return (obj == null) ? null : (Bait)obj;
    }

    /**
     * Checks to see if the Bait already exists in the database.
     *
     * @param bait The Bait object to look for.
     * @return True if the Bait exists; false otherwise.
     */
    public static boolean baitExists(Bait bait) {
        Cursor cursor = mDatabase.query(BaitTable.NAME, null, BaitTable.Columns.CATEGORY_ID + " = ? AND " + BaitTable.Columns.NAME + " = ?", new String[]{bait.getCategoryId().toString(), bait.getName()}, null, null, null);
        return QueryHelper.queryHasResults(cursor);
    }

    public static boolean addBait(Bait bait) {
        return QueryHelper.insertQuery(BaitTable.NAME, bait.getContentValues());
    }

    public static boolean removeBait(UUID id) {
        return QueryHelper.deleteUserDefine(BaitTable.NAME, id);
    }

    public static boolean editBait(UUID id, Bait newBait) {
        return QueryHelper.updateUserDefine(BaitTable.NAME, newBait.getContentValues(), id);
    }

    public static int getBaitCount() {
        return QueryHelper.queryCount(BaitTable.NAME);
    }

    /**
     * Gets an ordered array of {@link BaitCategory} objects and their respective {@link Bait}
     * objects.
     * @return An ArrayList of BaitCategory and Bait objects.
     */
    public static ArrayList<UserDefineObject> getBaitsAndCategories() {
        ArrayList<UserDefineObject> result = new ArrayList<>();
        ArrayList<UserDefineObject> categories = getBaitCategories();

        for (UserDefineObject category : categories) {
            result.add(category);
            result.addAll(getBaits((BaitCategory) category));
        }

        return result;
    }

    public static ArrayList<Stats.Quantity> getBaitUsedCount() {
        return getCatchQuantity(getBaits(), new OnQueryQuantityListener() {
            @Override
            public int query(UserDefineObject obj) {
                return QueryHelper.queryUserDefineCatchCount(obj, CatchTable.Columns.BAIT_ID);
            }
        });
    }
    //endregion

    //region Location Manipulation
    public static ArrayList<UserDefineObject> getLocations() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(LocationTable.NAME, null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new LocationCursor(cursor).getLocation();
            }
        });
    }

    public static Location getLocation(UUID id) {
        return getLocation(LocationTable.Columns.ID, id.toString());
    }

    public static Location getLocation(String name) {
        return getLocation(LocationTable.Columns.NAME, name);
    }

    private static Location getLocation(String column, String columnValue) {
        UserDefineObject obj = QueryHelper.queryUserDefine(LocationTable.NAME, column, columnValue, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new LocationCursor(cursor).getLocation();
            }
        });

        return (obj == null) ? null : (Location)obj;
    }

    public static FishingSpot getFishingSpot(UUID id) {
        return getFishingSpot(FishingSpotTable.Columns.ID, id.toString());
    }

    public static FishingSpot getFishingSpot(String name, UUID locationId) {
        UserDefineObject obj = QueryHelper.queryUserDefine(
                FishingSpotTable.NAME,
                FishingSpotTable.Columns.NAME + " = ? AND " + FishingSpotTable.Columns.LOCATION_ID + " = ?",
                new String[]{name, locationId.toString()},
                getFishingSpotQueryInterface()
        );
        return fishingSpotOrNull(obj);
    }

    private static FishingSpot getFishingSpot(String column, String columnValue) {
        UserDefineObject obj = QueryHelper.queryUserDefine(FishingSpotTable.NAME, column, columnValue, getFishingSpotQueryInterface());
        return fishingSpotOrNull(obj);
    }

    @NonNull
    private static QueryHelper.UserDefineQueryInterface getFishingSpotQueryInterface() {
        return new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new FishingSpotCursor(cursor).getFishingSpot();
            }
        };
    }

    private static FishingSpot fishingSpotOrNull(UserDefineObject obj) {
        return (obj == null) ? null : (FishingSpot)obj;
    }

    public static ArrayList<UserDefineObject> getAllFishingSpots() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(FishingSpotTable.NAME, null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new FishingSpotCursor(cursor).getFishingSpot();
            }
        });
    }

    /**
     * Checks to see if the Location already exists in the database.
     *
     * @param location The Location object to look for.
     * @return True if the Location exists; false otherwise.
     */
    public static boolean locationExists(Location location) {
        Cursor cursor = mDatabase.query(LocationTable.NAME, null, LocationTable.Columns.NAME + " = ?", new String[]{location.getName()}, null, null, null);
        return QueryHelper.queryHasResults(cursor);
    }

    public static boolean addLocation(Location location) {
        return QueryHelper.insertQuery(LocationTable.NAME, location.getContentValues());
    }

    public static boolean removeLocation(UUID id) {
        return getLocation(id).removeAllFishingSpots() && QueryHelper.deleteUserDefine(LocationTable.NAME, id);
    }

    public static boolean editLocation(UUID id, Location newLocation) {
        return QueryHelper.updateUserDefine(LocationTable.NAME, newLocation.getContentValues(), id);
    }

    public static int getLocationCount() {
        return QueryHelper.queryCount(LocationTable.NAME);
    }

    public static ArrayList<Stats.Quantity> getLocationCatchCount() {
        return getCatchQuantity(getLocations(), new OnQueryQuantityListener() {
            @Override
            public int query(UserDefineObject obj) {
                return QueryHelper.queryLocationCatchCount((Location)obj);
            }
        });
    }
    //endregion

    //region WaterClarity Manipulation
    public static ArrayList<UserDefineObject> getWaterClarities() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(WaterClarityTable.NAME, null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new WaterClarityCursor(cursor).getWaterClarity();
            }
        });
    }

    public static WaterClarity getWaterClarity(UUID id) {
        return getWaterClarity(WaterClarityTable.Columns.ID, id.toString());
    }

    public static WaterClarity getWaterClarity(String name) {
        return getWaterClarity(WaterClarityTable.Columns.NAME, name);
    }

    private static WaterClarity getWaterClarity(String column, String columnValue) {
        UserDefineObject obj = QueryHelper.queryUserDefine(WaterClarityTable.NAME, column, columnValue, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new WaterClarityCursor(cursor).getWaterClarity();
            }
        });

        return (obj == null) ? null : (WaterClarity)obj;
    }

    public static boolean addWaterClarity(WaterClarity clarity) {
        return QueryHelper.insertQuery(WaterClarityTable.NAME, clarity.getContentValues());
    }

    public static boolean removeWaterClarity(UUID id) {
        return QueryHelper.deleteUserDefine(WaterClarityTable.NAME, id);
    }

    public static boolean editWaterClarity(UUID id, WaterClarity newClarity) {
        return QueryHelper.updateUserDefine(WaterClarityTable.NAME, newClarity.getContentValues(), id);
    }

    public static int getWaterClarityCount() {
        return QueryHelper.queryCount(WaterClarityTable.NAME);
    }
    //endregion

    //region FishingMethod Manipulation
    public static ArrayList<UserDefineObject> getFishingMethods() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(FishingMethodTable.NAME, null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new FishingMethodCursor(cursor).getFishingMethod();
            }
        });
    }

    public static FishingMethod getFishingMethod(UUID id) {
        return getFishingMethod(FishingMethodTable.Columns.ID, id.toString());
    }

    public static FishingMethod getFishingMethod(String name) {
        return getFishingMethod(FishingMethodTable.Columns.NAME, name);
    }

    private static FishingMethod getFishingMethod(String column, String columnValue) {
        UserDefineObject obj = QueryHelper.queryUserDefine(FishingMethodTable.NAME, column, columnValue, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new FishingMethodCursor(cursor).getFishingMethod();
            }
        });

        return (obj == null) ? null : (FishingMethod)obj;
    }

    public static boolean addFishingMethod(FishingMethod method) {
        return QueryHelper.insertQuery(FishingMethodTable.NAME, method.getContentValues());
    }

    public static boolean removeFishingMethod(UUID id) {
        return QueryHelper.deleteUserDefine(FishingMethodTable.NAME, id);
    }

    public static boolean editFishingMethod(UUID id, FishingMethod newFishingMethod) {
        return QueryHelper.updateUserDefine(FishingMethodTable.NAME, newFishingMethod.getContentValues(), id);
    }

    public static int getFishingMethodCount() {
        return QueryHelper.queryCount(FishingMethodTable.NAME);
    }
    //endregion

    //region Angler Manipulation
    public static ArrayList<UserDefineObject> getAnglers() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(AnglerTable.NAME, null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new AnglerCursor(cursor).getAngler();
            }
        });
    }

    public static Angler getAngler(UUID id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(AnglerTable.NAME, id, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new AnglerCursor(cursor).getAngler();
            }
        });

        return (obj == null) ? null : (Angler)obj;
    }

    public static boolean addAngler(Angler angler) {
        return QueryHelper.insertQuery(AnglerTable.NAME, angler.getContentValues());
    }

    public static boolean removeAngler(UUID id) {
        return QueryHelper.deleteUserDefine(AnglerTable.NAME, id);
    }

    public static boolean editAngler(UUID id, Angler newAngler) {
        return QueryHelper.updateUserDefine(AnglerTable.NAME, newAngler.getContentValues(), id);
    }

    public static int getAnglerCount() {
        return QueryHelper.queryCount(AnglerTable.NAME);
    }
    //endregion

    //region Trip Manipulation
    /**
     * Checks to see if a trip with the given date range already exists in the database.
     *
     * @param trip The {@link Trip} object to look for.
     * @return True if the trip exists, false otherwise.
     */
    public static boolean tripExists(Trip trip) {
        ArrayList<UserDefineObject> trips = getTrips();

        for (UserDefineObject object : trips)
            if (trip.overlapsTrip((Trip)object))
                return true;

        return false;
    }

    public static ArrayList<UserDefineObject> getTrips() {
        return QueryHelper.queryUserDefines(QueryHelper.queryUserDefines(TripTable.NAME, null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new TripCursor(cursor).getTrip();
            }
        });
    }

    public static Trip getTrip(UUID id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(TripTable.NAME, id, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new TripCursor(cursor).getTrip();
            }
        });

        return (obj == null) ? null : (Trip)obj;
    }

    public static boolean addTrip(Trip trip) {
        return QueryHelper.insertQuery(TripTable.NAME, trip.getContentValues());
    }

    public static boolean removeTrip(UUID id) {
        Trip trip = Logbook.getTrip(id);
        trip.removeDatabaseProperties();
        return QueryHelper.deleteUserDefine(TripTable.NAME, id);
    }

    public static boolean editTrip(UUID id, Trip newTrip) {
        return QueryHelper.updateUserDefine(TripTable.NAME, newTrip.getContentValues(), id);
    }

    public static int getTripCount() {
        return QueryHelper.queryCount(TripTable.NAME);
    }
    //endregion

    //region Common Manipulation
    private interface OnQueryQuantityListener {
        int query(UserDefineObject obj);
    }

    /**
     * Gets an array of {@link com.cohenadair.anglerslog.model.Stats.Quantity} objects that
     * represent the quantity of catches associated with the given {@link UserDefineObject}s.
     *
     * @param objects The objects to check for {@link Catch} association.
     * @param listener The listener for querying the database.
     * @return An array of sorted UserDefineObject stat quantities.
     */
    private static ArrayList<Stats.Quantity> getCatchQuantity(ArrayList<UserDefineObject> objects, OnQueryQuantityListener listener) {
        ArrayList<Stats.Quantity> list = new ArrayList<>();

        for (UserDefineObject obj : objects)
            list.add(new Stats.Quantity(obj.getId(), obj.getDisplayName(), listener.query(obj)));

        Collections.sort(list, new Stats.QuantityComparator());
        return list;
    }
    //endregion

    public static String getLengthUnits() {
        return isImperial() ? getString(R.string.inches) : " " + getString(R.string.cm);
    }

    public static String getWeightUnits() {
        return isImperial() ? getString(R.string.lbs) : getString(R.string.kg);
    }

    public static String getDepthUnits() {
        return isImperial() ? getString(R.string.ft) : getString(R.string.meters);
    }

    public static String getTemperatureUnits() {
        return getTemperatureUnits(isImperial());
    }

    public static String getTemperatureUnits(boolean isImperial) {
        return isImperial ? getString(R.string.degrees_f) : getString(R.string.degrees_c);
    }

    public static String getSpeedUnits(boolean isImperial) {
        return isImperial ? getString(R.string.mph) : getString(R.string.kmh);
    }

    @NonNull
    private static String getString(int id) {
        return mContext.getResources().getString(id);
    }

    private static boolean isImperial() {
        return (LogbookPreferences.getUnits() == UNIT_IMPERIAL);
    }
}
