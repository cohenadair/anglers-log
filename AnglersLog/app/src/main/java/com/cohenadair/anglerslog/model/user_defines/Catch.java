package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.text.format.DateFormat;
import android.util.Log;

import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;
import java.util.Date;

import static com.cohenadair.anglerslog.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.UsedFishingMethodsTable;

/**
 * The Catch class stores relative information for a single fishing catch.
 * @author Cohen Adair
 */
public class Catch extends PhotoUserDefineObject {

    private static final String TAG = "Catch";

    private Date mDate;
    private Species mSpecies;
    private boolean mIsFavorite;
    private Bait mBait;
    private FishingSpot mFishingSpot;
    private WaterClarity mWaterClarity;
    private CatchResult mCatchResult = CatchResult.RELEASED;

    /**
     * Represents what was done after a catch was made.
     */
    public enum CatchResult {
        RELEASED(0), KEPT(1);

        private final int value;

        CatchResult(int v) {
            value = v;
        }

        public int getValue() {
            return value;
        }

        public static CatchResult fromInt(int i) {
            switch (i) {
                case 0:
                    return RELEASED;
                case 1:
                    return KEPT;
            }

            return null;
        }
    }

    //region Constructors
    public Catch(Date date) {
        super(Utils.getDisplayDate(date), CatchPhotoTable.NAME);
        mDate = date;
    }

    public Catch(Catch aCatch, boolean keepId) {
        super(aCatch, keepId);
        mDate = new Date(aCatch.getDate().getTime());
        mIsFavorite = aCatch.isFavorite();
        mSpecies = new Species(aCatch.getSpecies(), true);
        mCatchResult = aCatch.getCatchResult();

        if (aCatch.getBait() != null)
            mBait = new Bait(aCatch.getBait(), true);

        if (aCatch.getFishingSpot() != null)
            mFishingSpot = new FishingSpot(aCatch.getFishingSpot(), true);

        if (aCatch.getWaterClarity() != null)
            mWaterClarity = new WaterClarity(aCatch.getWaterClarity(), true);
    }

    public Catch(UserDefineObject obj) {
        super(obj);
        setPhotoTable(CatchPhotoTable.NAME);
    }

    public Catch(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
        setPhotoTable(CatchPhotoTable.NAME);
    }
    //endregion

    //region Getters & Setters
    public Date getDate() {
        return mDate;
    }

    public void setDate(Date date) {
        mDate = date;
    }

    public Species getSpecies() {
        return mSpecies;
    }

    public void setSpecies(Species species) {
        mSpecies = species;
    }

    public boolean isFavorite() {
        return mIsFavorite;
    }

    public void setIsFavorite(boolean isFavorite) {
        mIsFavorite = isFavorite;
    }

    public Bait getBait() {
        return mBait;
    }

    public void setBait(Bait bait) {
        mBait = bait;
    }

    public FishingSpot getFishingSpot() {
        return mFishingSpot;
    }

    public void setFishingSpot(FishingSpot fishingSpot) {
        mFishingSpot = fishingSpot;
    }

    public WaterClarity getWaterClarity() {
        return mWaterClarity;
    }

    public void setWaterClarity(WaterClarity waterClarity) {
        mWaterClarity = waterClarity;
    }

    public CatchResult getCatchResult() {
        return mCatchResult;
    }

    public void setCatchResult(CatchResult catchResult) {
        mCatchResult = catchResult;
    }
    //endregion

    //region Fishing Method Manipulation
    public ArrayList<FishingMethod> getFishingMethods() {
        return QueryHelper.queryUsedFishingMethod(getId());
    }

    public void setFishingMethods(ArrayList<FishingMethod> fishingMethods) {
        deleteFishingMethods();
        addFishingMethods(fishingMethods);
    }

    private void addFishingMethods(ArrayList<FishingMethod> fishingMethods) {
        for (FishingMethod method : fishingMethods)
            if (!QueryHelper.insertQuery(UsedFishingMethodsTable.NAME, getUsedFishingMethodContentValues(method)))
                Log.e(TAG, "Error adding FishingMethod to database.");
    }

    private void deleteFishingMethods() {
        if (!QueryHelper.deleteQuery(
                UsedFishingMethodsTable.NAME,
                UsedFishingMethodsTable.Columns.CATCH_ID + " = ?",
                new String[] { idAsString() }))
            Log.e(TAG, "Error deleting FishingMethods from database.");
    }

    private ContentValues getUsedFishingMethodContentValues(FishingMethod method) {
        ContentValues values = new ContentValues();

        values.put(UsedFishingMethodsTable.Columns.CATCH_ID, idAsString());
        values.put(UsedFishingMethodsTable.Columns.FISHING_METHOD_ID, method.idAsString());

        return values;
    }
    //endregion

    @Override
    public String getName() {
        return getDateTimeAsString();
    }

    public String getSpeciesAsString() {
        return (mSpecies != null) ? mSpecies.getName() : "";
    }

    public String getBaitAsString() {
        return (mBait != null) ? mBait.getDisplayName() : "";
    }

    public String getDateAsString() {
        return Utils.getDisplayDate(mDate);
    }

    public String getTimeAsString() {
        return Utils.getDisplayTime(mDate);
    }

    public String getDateTimeAsString() {
        return DateFormat.format("MMM dd, yyyy 'at' h:mm a", mDate).toString();
    }

    public String getFishingSpotAsString() {
        return (mFishingSpot != null) ? mFishingSpot.getLocationName() + " - " + mFishingSpot.getName() : "";
    }

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(CatchTable.Columns.DATE, mDate.getTime());
        values.put(CatchTable.Columns.IS_FAVORITE, mIsFavorite ? 1 : 0);
        values.put(CatchTable.Columns.SPECIES_ID, mSpecies.idAsString());
        values.put(CatchTable.Columns.CATCH_RESULT, mCatchResult.getValue());

        if (mBait != null)
            values.put(CatchTable.Columns.BAIT_ID, mBait.idAsString());

        if (mFishingSpot != null)
            values.put(CatchTable.Columns.FISHING_SPOT_ID, mFishingSpot.idAsString());

        if (mWaterClarity != null)
            values.put(CatchTable.Columns.CLARITY_ID, mWaterClarity.idAsString());

        return values;
    }

    /**
     * Creates a concatenated String of this Catch's fishing methods.
     * @return A concatenated String.
     */
    private String fishingMethodsAsString() {
        ArrayList<FishingMethod> methods = getFishingMethods();
        String str = "";

        for (int i = 0; i < methods.size() - 1; i++)
            str += methods.get(i).getName() + ",";

        return str + methods.get(methods.size() - 1).getName();
    }
}
