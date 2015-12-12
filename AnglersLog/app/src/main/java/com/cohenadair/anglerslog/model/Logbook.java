package com.cohenadair.anglerslog.model;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.support.annotation.Nullable;
import android.util.Log;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.database.cursors.BaitCategoryCursor;
import com.cohenadair.anglerslog.database.cursors.BaitCursor;
import com.cohenadair.anglerslog.database.cursors.CatchCursor;
import com.cohenadair.anglerslog.database.cursors.FishingSpotCursor;
import com.cohenadair.anglerslog.database.cursors.LocationCursor;
import com.cohenadair.anglerslog.database.cursors.SpeciesCursor;
import com.cohenadair.anglerslog.database.cursors.UserDefineCursor;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import java.util.ArrayList;
import java.util.Random;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.BaitCategoryTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.BaitTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.FishingSpotTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.LocationTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.SpeciesTable;

/**
 * The Logbook class is a monostate class storing all of the user's log data.
 * @author Cohen Adair
 */
public class Logbook {

    private static final String TAG = "Logbook";

    private static SQLiteDatabase mDatabase;
    private static Context mContext;

    private Logbook() { }

    public static void init(Context context) {
        init(context, new LogbookHelper(context).getWritableDatabase());
        setDefaults();
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
    private static void setDefaults() {
        if (getBaitCategoryCount() <= 0) {
            Log.d(TAG, "Adding default bait category");

            addBaitCategory(new BaitCategory("Woolly Bugger"));
            addBaitCategory(new BaitCategory("Yarn Fly"));
            addBaitCategory(new BaitCategory("Bead"));
        }

        if (getSpeciesCount() <= 0) {
            Log.d(TAG, "Adding default species.");

            addSpecies(new Species("Steelhead"));
            addSpecies(new Species("Pike"));
            addSpecies(new Species("Bass - Smallmouth"));
            addSpecies(new Species("Salmon - Coho"));
        }
    }

    //region Getters & Setters
    public static SQLiteDatabase getDatabase() {
        return mDatabase;
    }
    //endregion

    /**
     * Gets a random Catch photo to use in the NavigationView.
     * @return A String representing a random photo name, or null if no photos exist.
     */
    @Nullable
    public static String getRandomCatchPhoto() {
        ArrayList<String> photoNames = QueryHelper.queryPhotos(CatchPhotoTable.NAME, null);

        if (photoNames.size() <= 0)
            return null;

        return photoNames.get(new Random().nextInt(photoNames.size()));
    }

    /**
     * Deletes all database entries for photos that aren't associated with any UserDefineObject
     * instances.
     */
    public static void cleanDatabasePhotos() {
        // TODO delete photos from BaitPhotoTable

        int numDeleted = mDatabase.delete(
                CatchPhotoTable.NAME,
                CatchPhotoTable.Columns.USER_DEFINE_ID + " NOT IN(SELECT " + CatchTable.Columns.ID + " FROM " + CatchTable.NAME + ")",
                null);

        Log.i(TAG, "Deleted " + numDeleted + " photos from the database.");
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
        return QueryHelper.deleteUserDefine(CatchTable.NAME, id);
    }

    public static boolean editCatch(UUID id, Catch newCatch) {
        return QueryHelper.updateUserDefine(CatchTable.NAME, newCatch.getContentValues(), id);
    }

    public static int getCatchCount() {
        return QueryHelper.queryCount(CatchTable.NAME);
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
        UserDefineObject obj = QueryHelper.queryUserDefine(SpeciesTable.NAME, id, new QueryHelper.UserDefineQueryInterface() {
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
        UserDefineObject obj = QueryHelper.queryUserDefine(BaitCategoryTable.NAME, id, new QueryHelper.UserDefineQueryInterface() {
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
        return QueryHelper.queryUserDefines(QueryHelper.queryBaits(null, null), new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new BaitCursor(cursor).getBait();
            }
        });
    }

    public static Bait getBait(UUID id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(BaitTable.NAME, id, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new BaitCursor(cursor).getBait();
            }
        });

        return (obj == null) ? null : (Bait)obj;
    }

    /**
     * Checks to see if the Bait already exists in the database.
     *
     * @param bait The Bait object to look for.
     * @return True if the Bait exists; false otherwise.
     */
    public static boolean baitExists(Bait bait) {
        Cursor cursor = mDatabase.query(BaitTable.NAME, null, BaitTable.Columns.CATEGORY_ID + " = ? AND " + BaitTable.Columns.NAME + " = ?", new String[]{ bait.getCategoryId().toString(), bait.getName() }, null, null, null);
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
     * Gets an ordered array of bait categories with their respective baits.
     *
     * @return An ArrayList of BaitCategory and Bait objects.
     */
    public static ArrayList<UserDefineObject> getBaitsAndCategories() {
        ArrayList<UserDefineObject> result = new ArrayList<>();
        ArrayList<UserDefineObject> categories = getBaitCategories();
        ArrayList<UserDefineObject> baits = getBaits();

        for (UserDefineObject category : categories) {
            result.add(category);

            for (UserDefineObject bait : baits)
                if (((Bait)bait).getCategoryId().equals(category.getId()))
                    result.add(bait);
        }

        return result;
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
        UserDefineObject obj = QueryHelper.queryUserDefine(LocationTable.NAME, id, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new LocationCursor(cursor).getLocation();
            }
        });

        return (obj == null) ? null : (Location)obj;
    }

    public static FishingSpot getFishingSpot(UUID id) {
        UserDefineObject obj = QueryHelper.queryUserDefine(FishingSpotTable.NAME, id, new QueryHelper.UserDefineQueryInterface() {
            @Override
            public UserDefineObject getObject(UserDefineCursor cursor) {
                return new FishingSpotCursor(cursor).getFishingSpot();
            }
        });

        return (obj == null) ? null : (FishingSpot)obj;
    }

    /**
     * Checks to see if the Location already exists in the database.
     *
     * @param location The Location object to look for.
     * @return True if the Location exists; false otherwise.
     */
    public static boolean locationExists(Location location) {
        Cursor cursor = mDatabase.query(LocationTable.NAME, null, LocationTable.Columns.NAME + " = ?", new String[]{ location.getName() }, null, null, null);
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
    //endregion
}
