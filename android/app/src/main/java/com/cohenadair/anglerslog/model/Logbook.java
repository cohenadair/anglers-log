package com.cohenadair.anglerslog.model;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.net.Uri;
import android.os.Handler;
import android.support.annotation.NonNull;
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
import com.cohenadair.anglerslog.model.backup.Exporter;
import com.cohenadair.anglerslog.model.backup.Importer;
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
import com.cohenadair.anglerslog.model.utilities.SortingMethod;
import com.cohenadair.anglerslog.model.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.LogbookPreferences;
import com.cohenadair.anglerslog.utilities.PhotoUtils;
import com.drew.lang.annotations.NotNull;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
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
 * The Logbook class is a static class storing all of the user's log data.
 * @author Cohen Adair
 */
public class Logbook {

    public static final int UNIT_IMPERIAL = 0;

    private static final String TAG = "Logbook";

    private static SQLiteDatabase mDatabase;

    public interface OnResetListener {
        void onFinish();
    }

    private Logbook() { }

    public static void init(Context context) {
        init(new LogbookHelper(context).getWritableDatabase());
    }

    public static void init(SQLiteDatabase database) {
        mDatabase = database;
        mDatabase.setForeignKeyConstraintsEnabled(true);
        QueryHelper.setDatabase(mDatabase);
        cleanDatabasePhotos();
    }

    static void initForTesting(Context context, SQLiteDatabase database) {
        init(database);
    }

    /**
     * Set some default UserDefineObjects if there aren't any.
     */
    public static void setDefaults(Context context) {
        String lureText = context.getString(R.string.default_bait_category_lure);

        if (getBaitCategoryCount() <= 0) {
            addBaitCategory(new BaitCategory(lureText));
            addBaitCategory(new BaitCategory(
                    context.getString(R.string.default_bait_category_minnow)));
            addBaitCategory(new BaitCategory(
                    context.getString(R.string.default_bait_category_fly)));
        }

        if (getSpeciesCount() <= 0) {
            addSpecies(new Species(
                    context.getString(R.string.default_species_steelhead)));
            addSpecies(new Species(
                    context.getString(R.string.default_species_pike)));
            addSpecies(new Species(
                    context.getString(R.string.default_species_bass)));
            addSpecies(new Species(
                    context.getString(R.string.default_species_salmon)));
        }

        if (getFishingMethodCount() <= 0) {
            addFishingMethod(new FishingMethod(
                    context.getString(R.string.default_fishing_method_boat)));
            addFishingMethod(new FishingMethod(
                    context.getString(R.string.default_fishing_method_shore)));
            addFishingMethod(new FishingMethod(
                    context.getString(R.string.default_fishing_method_ice)));
            addFishingMethod(new FishingMethod(
                    context.getString(R.string.default_fishing_method_trolling)));
        }

        if (getWaterClarityCount() <= 0) {
            addWaterClarity(new WaterClarity(
                    context.getString(R.string.default_water_clarity_crystal)));
            addWaterClarity(new WaterClarity(
                    context.getString(R.string.default_water_clarity_clear)));
            addWaterClarity(new WaterClarity(
                    context.getString(R.string.default_water_clarity_muddy)));
        }

        if (getBaitCount() <= 0) {
            // ensure the BaitCategory exists
            BaitCategory baitCategory = getBaitCategory(lureText);
            if (baitCategory == null) {
                // if for some reason it wasn't added above, try adding it again
                addBaitCategory(new BaitCategory(lureText));
                baitCategory = getBaitCategory(lureText);
                // if the second add attempt failed, don't bother creating example baits
                if (baitCategory == null) {
                    return;
                }
            }

            String spinner = "spinner.jpg";
            String rap = "rapala.jpg";
            PhotoUtils.saveImageResource(context, R.drawable.spinner, spinner);
            PhotoUtils.saveImageResource(context, R.drawable.rapala, rap);

            Bait bait = new Bait("Blue Fox Spinner", baitCategory);
            bait.setType(Bait.TYPE_ARTIFICIAL);
            bait.setSize("6");
            bait.setColor(context.getString(R.string.default_color_silver));
            bait.addPhoto(spinner);
            Logbook.addBait(bait);

            bait = new Bait("Rippin' Rap", baitCategory);
            bait.setType(Bait.TYPE_ARTIFICIAL);
            bait.setSize("2");
            bait.setColor(context.getString(R.string.default_color_blue));
            bait.addPhoto(rap);
            Logbook.addBait(bait);
        }
    }

    public static void cleanup(Context context) {
        // delete backup file if one exists
        String backupFile = LogbookPreferences.getBackupFile(context);
        if (backupFile != null) {
            FileUtils.deleteQuietly(new File(backupFile));
            LogbookPreferences.setBackupFile(context, null);
        }
    }

    public static void updatePreferences(Context context) {
    }

    /**
     * Completely resets the database. This is done in a background thread.
     */
    public static void resetAsync(final Context context, final boolean addDefaults,
                                  final OnResetListener callbacks)
    {
        final Handler handler = new Handler();

        Runnable r = new Runnable() {
            @Override
            public void run() {
                reset(context, addDefaults);

                if (callbacks != null)
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            callbacks.onFinish();
                        }
                    });
            }
        };

        new Thread(r).start();
    }

    /**
     * Completely resets the Logbook's data. This cannot be undone.
     * @param addDefaults True to add default objects after reset; false otherwise.
     */
    public static void reset(Context context, boolean addDefaults) {
        File data = new File(mDatabase.getPath());
        mDatabase.close();
        FileUtils.deleteQuietly(data);

        init(context);

        if (addDefaults)
            setDefaults(context);

        PhotoUtils.cleanPhotos(context);
    }

    //region Getters & Setters
    public static SQLiteDatabase getDatabase() {
        return mDatabase;
    }

    public static String getName() {
        return TAG;
    }
    //endregion

    //region Backup
    public static void importFromUri(
            Context context, Uri uri, Importer.OnProgressListener onProgress)
    {
        Importer.importFromUri(context, uri, onProgress);
    }

    public static void exportToPath(
            Context context, File filePath, Exporter.OnProgressListener onProgress)
    {
        Exporter.exportToPath(context, filePath, onProgress);
    }
    //endregion

    /**
     * Gets all of the user's catch photos.
     * @return A list of all the catch photo names.
     */
    @NonNull
    public static ArrayList<String> getAllCatchPhotos() {
        return QueryHelper.queryPhotos(CatchPhotoTable.NAME, null);
    }

    /**
     * Gets all of the user's bait photos.
     * @return A list of all the bait photo names.
     */
    @NotNull
    public static ArrayList<String> getAllBaitPhotos() {
        return QueryHelper.queryPhotos(BaitPhotoTable.NAME, null);
    }

    /**
     * Deletes all database entries for photos that aren't associated with any UserDefineObject
     * instances.
     */
    private static void cleanDatabasePhotos() {
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

    public static ArrayList<UserDefineObject> getCatches(
            Context context, String searchQuery, SortingMethod sortingMethod)
    {
        return UserDefineArrays.searchAndSort(context, getCatches(), searchQuery, sortingMethod);
    }

    public static ArrayList<UserDefineObject> getCatches(Context context, String searchQuery) {
        return getCatches(context, searchQuery, null);
    }

    public static Catch getCatch(UUID id) {
        return getCatch(CatchTable.Columns.ID, id.toString());
    }

    public static Catch getCatch(Date date) {
        return getCatch(CatchTable.Columns.DATE, Long.toString(date.getTime()));
    }

    private static Catch getCatch(String column, String columnValue) {
        UserDefineObject obj = QueryHelper.queryUserDefine(CatchTable.NAME, column, columnValue, new QueryHelper.UserDefineQueryInterface() {
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
        return removeUserDefine(CatchTable.NAME, Logbook.getCatch(id));
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

    /**
     * Gets a list of {@link com.cohenadair.anglerslog.model.Stats.Quantity} objects representing
     * the number of {@link Species} that were caught with the given {@link Species}.
     *
     * @param bait The {@link Bait} object used to query the database.
     * @return A list of {@link com.cohenadair.anglerslog.model.Stats.Quantity} objects.
     */
    public static ArrayList<Stats.Quantity> getSpeciesCaughtCount(final Bait bait) {
        return getCatchQuantity(getSpecies(), new OnQueryQuantityListener() {
            @Override
            public int query(UserDefineObject obj) {
                return QueryHelper.queryUserDefineCatchCount(
                        CatchTable.Columns.BAIT_ID + " = ? AND " + CatchTable.Columns.SPECIES_ID + " = ?",
                        new String[] { bait.getIdAsString(), obj.getIdAsString() }
                );
            }
        });
    }

    /**
     * Gets a list of {@link com.cohenadair.anglerslog.model.Stats.Quantity} objects representing
     * the number of {@link Species} that were caught at the given {@link Location}.
     *
     * @param location The {@link Location} object used to query the database.
     * @return A list of {@link com.cohenadair.anglerslog.model.Stats.Quantity} objects.
     */
    public static ArrayList<Stats.Quantity> getSpeciesCaughtCount(final Location location) {
        return getCatchQuantity(getSpecies(), new OnQueryQuantityListener() {
            @Override
            public int query(UserDefineObject obj) {
                return QueryHelper.queryUserDefineCatchCount(
                        CatchTable.Columns.SPECIES_ID + " = ? AND " + CatchTable.Columns.FISHING_SPOT_ID + " IN (SELECT " + FishingSpotTable.Columns.ID + " FROM " + FishingSpotTable.NAME + " WHERE " + FishingSpotTable.Columns.LOCATION_ID + " = ?)",
                        new String[] { obj.getIdAsString(), location.getIdAsString() }
                );
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
        return getBaits("", null);
    }

    /**
     * Gets all {@link Bait} objects associated with the given {@link BaitCategory}.
     * @param baitCategory The BaitCategory.
     * @return An ArrayList of {@link Bait} objects.
     */
    private static ArrayList<UserDefineObject> getBaits(BaitCategory baitCategory) {
        return getBaits(BaitTable.Columns.CATEGORY_ID + " = ?", new String[]{baitCategory.getIdAsString()});
    }

    /**
     * Gets all {@link Bait} objects based on the given WHERE clause.
     * @param whereClause The WHERE clause.
     * @param args The WHERE clause arguments.
     * @return An ArrayList of {@link Bait} objects matching the WHERE clause.
     */
    private static ArrayList<UserDefineObject> getBaits(String whereClause, String[] args) {
        if (whereClause.isEmpty())
            whereClause = null;

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
     * @see #getBaitsAndCategories(Context, String, SortingMethod)
     */
    public static ArrayList<UserDefineObject> getBaitsAndCategories(Context context) {
        return getBaitsAndCategories(context, null, null);
    }

    /**
     * @see #getBaitsAndCategories(Context, String, SortingMethod)
     */
    public static ArrayList<UserDefineObject> getBaitsAndCategories(
            Context context, String searchQuery)
    {
        return getBaitsAndCategories(context, searchQuery, null);
    }

    /**
     * Gets an ordered array of {@link BaitCategory} objects and their respective {@link Bait}
     * objects.
     *
     * @param searchQuery A String of keywords used to filter the {@link Bait} objects. If null, all
     *                    possible baits will be returned.
     * @param sortingMethod A {@link SortingMethod} instance used to sort the {@link Bait} objects
     *                      for each {@link BaitCategory}.
     * @return An ArrayList of BaitCategory and Bait objects.
     */
    public static ArrayList<UserDefineObject> getBaitsAndCategories(
            Context context, String searchQuery, SortingMethod sortingMethod)
    {
        ArrayList<UserDefineObject> result = new ArrayList<>();
        ArrayList<UserDefineObject> categories = getBaitCategories();

        for (UserDefineObject category : categories) {
            result.add(category);
            result.addAll(UserDefineArrays.searchAndSort(
                    context, getBaits((BaitCategory) category), searchQuery, sortingMethod));
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

    /**
     * Gets a list of {@link com.cohenadair.anglerslog.model.Stats.Quantity} objects representing
     * the number of {@link Bait} objects that were used to catch a given {@link Species}.
     *
     * @param species The {@link Species} object used to query the database.
     * @return A list of {@link com.cohenadair.anglerslog.model.Stats.Quantity} objects.
     */
    public static ArrayList<Stats.Quantity> getBaitUsedCount(final Species species) {
        return getCatchQuantity(getBaits(), new OnQueryQuantityListener() {
            @Override
            public int query(UserDefineObject obj) {
                return QueryHelper.queryUserDefineCatchCount(
                        CatchTable.Columns.BAIT_ID + " = ? AND " + CatchTable.Columns.SPECIES_ID + " = ?",
                        new String[] { obj.getIdAsString(), species.getIdAsString() }
                );
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

    public static ArrayList<UserDefineObject> getLocations(
            Context context, String searchQuery, SortingMethod sortingMethod)
    {
        return UserDefineArrays.searchAndSort(context, getLocations(), searchQuery, sortingMethod);
    }

    public static ArrayList<UserDefineObject> getLocations(Context context, String searchQuery) {
        return getLocations(context, searchQuery, null);
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
                return ((Location)obj).getFishCaughtCount();
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
        return getAngler(AnglerTable.Columns.ID, id.toString());
    }

    static Angler getAngler(String name) {
        return getAngler(AnglerTable.Columns.NAME, name);
    }

    private static Angler getAngler(String column, String columnValue) {
        UserDefineObject obj = QueryHelper.queryUserDefine(AnglerTable.NAME, column, columnValue, new QueryHelper.UserDefineQueryInterface() {
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
    public static boolean tripExists(Trip trip) {
        ArrayList<UserDefineObject> trips = getTrips();

        for (UserDefineObject object : trips) {
            Trip tr = (Trip) object;
            if (!trip.getId().equals(tr.getId()) && trip.overlapsTrip((Trip) object)) {
                return true;
            }
        }

        return false;
    }

    public static ArrayList<UserDefineObject> getTrips() {
        return QueryHelper.queryUserDefines(QueryHelper.queryTrips(null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new TripCursor(cursor).getTrip();
            }
        });
    }

    public static ArrayList<UserDefineObject> getTrips(
            Context context, String searchQuery, SortingMethod sortingMethod)
    {
        return UserDefineArrays.searchAndSort(context, getTrips(), searchQuery, sortingMethod);
    }

    public static ArrayList<UserDefineObject> getTrips(Context context, String searchQuery) {
        return getTrips(context, searchQuery, null);
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
        return removeUserDefine(TripTable.NAME, Logbook.getTrip(id));
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

    public static String getLengthUnits(Context context) {
        return isImperial(context)
                ? context.getString(R.string.inches)
                : " " + context.getString(R.string.cm);
    }

    public static String getWeightUnits(Context context) {
        return isImperial(context) ? context.getString(R.string.lbs) : context.getString(R.string.kg);
    }

    public static String getDepthUnits(Context context) {
        return isImperial(context) ? context.getString(R.string.ft) : context.getString(R.string.meters);
    }

    public static String getTemperatureUnits(Context context) {
        return getTemperatureUnits(context, isImperial(context));
    }

    public static String getTemperatureUnits(Context context, boolean isImperial) {
        return isImperial
                ? context.getString(R.string.degrees_f)
                : context.getString(R.string.degrees_c);
    }

    public static String getSpeedUnits(Context context, boolean isImperial) {
        return isImperial ? context.getString(R.string.mph) : context.getString(R.string.kmh);
    }

    public static String getShareText(Context context) {
        return context.getResources().getString(R.string.share_text);
    }

    private static boolean isImperial(Context context) {
        return (LogbookPreferences.getUnits(context) == UNIT_IMPERIAL);
    }

    private static boolean removeUserDefine(String table, UserDefineObject obj) {
        if (QueryHelper.deleteUserDefine(table, obj.getId())) {
            obj.removeDatabaseProperties();
            return true;
        }

        return false;
    }
}
