package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.content.Context;
import android.text.format.DateFormat;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.utilities.UsedUserDefineObject;
import com.cohenadair.anglerslog.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.Utils;

import java.util.ArrayList;
import java.util.Date;
import java.util.UUID;

import static com.cohenadair.anglerslog.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.CatchTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.UsedFishingMethodTable;
import static com.cohenadair.anglerslog.database.LogbookSchema.WeatherTable;

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
    private CatchResult mCatchResult = CatchResult.RELEASED;
    private WaterClarity mWaterClarity;
    private float mWaterDepth = -1;
    private int mWaterTemperature = -1;
    private int mQuantity = 1;
    private float mLength = -1;
    private float mWeight = -1;
    private String mNotes;

    // utility objects used for database accessing
    private UsedUserDefineObject mUsedFishingMethods;

    /**
     * Represents what was done after a catch was made. Values correspond to the catch results
     * array in arrays.xml.
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

        public String getString(Context context) {
            String[] arr = context.getResources().getStringArray(R.array.result_types);
            return arr[value];
        }
    }

    //region Constructors
    public Catch(Date date) {
        super(Utils.getDisplayDate(date), CatchPhotoTable.NAME);
        mDate = date;
        init();
    }

    public Catch(Catch aCatch, boolean keepId) {
        super(aCatch, keepId);
        mDate = new Date(aCatch.getDate().getTime());
        mIsFavorite = aCatch.isFavorite();
        mSpecies = new Species(aCatch.getSpecies(), true);
        mCatchResult = aCatch.getCatchResult();
        mQuantity = aCatch.getQuantity();
        mLength = aCatch.getLength();
        mWeight = aCatch.getWeight();
        mWaterDepth = aCatch.getWaterDepth();
        mWaterTemperature = aCatch.getWaterTemperature();
        mNotes = aCatch.getNotes();

        if (aCatch.getBait() != null)
            mBait = new Bait(aCatch.getBait(), true);

        if (aCatch.getFishingSpot() != null)
            mFishingSpot = new FishingSpot(aCatch.getFishingSpot(), true);

        if (aCatch.getWaterClarity() != null)
            mWaterClarity = new WaterClarity(aCatch.getWaterClarity(), true);

        init();
    }

    public Catch(UserDefineObject obj) {
        super(obj);
        setPhotoTable(CatchPhotoTable.NAME);
        init();
    }

    public Catch(UserDefineObject obj, boolean keepId) {
        super(obj, keepId);
        setPhotoTable(CatchPhotoTable.NAME);
        init();
    }

    private void init() {
        mUsedFishingMethods = new UsedUserDefineObject(getId(), UsedFishingMethodTable.NAME, UsedFishingMethodTable.Columns.CATCH_ID, UsedFishingMethodTable.Columns.FISHING_METHOD_ID);
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

    public float getWaterDepth() {
        return mWaterDepth;
    }

    public void setWaterDepth(float waterDepth) {
        mWaterDepth = waterDepth;
    }

    public int getWaterTemperature() {
        return mWaterTemperature;
    }

    public void setWaterTemperature(int waterTemperature) {
        mWaterTemperature = waterTemperature;
    }

    public int getQuantity() {
        return mQuantity;
    }

    public void setQuantity(int quantity) {
        mQuantity = quantity;
    }

    public float getLength() {
        return mLength;
    }

    public void setLength(float length) {
        mLength = length;
    }

    public float getWeight() {
        return mWeight;
    }

    public void setWeight(float weight) {
        mWeight = weight;
    }

    public String getNotes() {
        return mNotes;
    }

    public void setNotes(String notes) {
        mNotes = notes;
    }

    @Override
    public void setIsSelected(boolean isSelected) {
        super.setIsSelected(isSelected);
        Logbook.editCatch(getId(), this);
    }
    //endregion

    //region Fishing Method Manipulation
    public ArrayList<UserDefineObject> getFishingMethods() {
        return mUsedFishingMethods.getObjects(new QueryHelper.UsedQueryCallbacks() {
            @Override
            public UserDefineObject getFromLogbook(UUID id) {
                return Logbook.getFishingMethod(id);
            }
        });
    }

    public void setFishingMethods(ArrayList<UserDefineObject> fishingMethods) {
        mUsedFishingMethods.setObjects(fishingMethods);
    }

    public int getFishingMethodCount() {
        return getFishingMethods().size();
    }

    public boolean hasFishingMethods() {
        return getFishingMethodCount() > 0;
    }
    //endregion

    //region Weather Manipulation
    public Weather getWeather() {
        return QueryHelper.queryWeather(getId());
    }

    public boolean setWeather(Weather weather) {
        // if the weather is being reset to null, try to delete any existing weather data
        if (weather == null) {
            removeWeather();
            return false;
        }

        return QueryHelper.replaceQuery(WeatherTable.NAME, weather.getContentValues(getId()));
    }

    public boolean removeWeather() {
        return QueryHelper.deleteQuery(WeatherTable.NAME, WeatherTable.Columns.CATCH_ID + " = ?", new String[] { idAsString() });
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
        return (mFishingSpot != null) ? mFishingSpot.getDisplayName() : "";
    }

    public String getWaterClarityAsString() {
        return (mWaterClarity != null) ? mWaterClarity.getName() : "";
    }

    public String getQuantityAsString() {
        return (mQuantity != -1) ? Integer.toString(mQuantity) : "";
    }

    public String getLengthAsStringWithUnits() {
        return (mLength != -1) ? Float.toString(mLength) + Logbook.getLengthUnits() : "";
    }

    public String getLengthAsString() {
        return (mLength != -1) ? Float.toString(mLength) : "";
    }

    public String getWeightAsStringWithUnits() {
        return (mWeight != -1) ? Float.toString(mWeight) + " " + Logbook.getWeightUnits() : "";
    }

    public String getWeightAsString() {
        return (mWeight != -1) ? Float.toString(mWeight) : "";
    }

    public String getWaterDepthAsStringWithUnits() {
        return (mWaterDepth != -1) ? Float.toString(mWaterDepth) + " " + Logbook.getDepthUnits() : "";
    }

    public String getWaterDepthAsString() {
        return (mWaterDepth != -1) ? Float.toString(mWaterDepth) : "";
    }

    public String getWaterTemperatureAsStringWithUnits() {
        return (mWaterTemperature != -1) ? Integer.toString(mWaterTemperature) + Logbook.getTemperatureUnits() : "";
    }

    public String getWaterTemperatureAsString() {
        return (mWaterTemperature != -1) ? Integer.toString(mWaterTemperature) : "";
    }

    public String getNotesAsString() {
        return (mNotes != null) ? mNotes : "";
    }

    public String getFishingMethodsAsString() {
        return UserDefineArrays.namesAsString(getFishingMethods());
    }

    /**
     * Gets the Catch's CatchResult as a String. A Context is needed to retrieve the String array
     * resource.
     *
     * @param context The context.
     * @return A String representing the catch result.
     */
    public String getCatchResultAsString(Context context) {
        return (mCatchResult != null) ? mCatchResult.getString(context) : "";
    }

    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(CatchTable.Columns.DATE, mDate.getTime());
        values.put(CatchTable.Columns.IS_FAVORITE, mIsFavorite ? 1 : 0);
        values.put(CatchTable.Columns.SPECIES_ID, mSpecies.idAsString());
        values.put(CatchTable.Columns.CATCH_RESULT, mCatchResult.getValue());
        values.put(CatchTable.Columns.QUANTITY, mQuantity);
        values.put(CatchTable.Columns.LENGTH, mLength);
        values.put(CatchTable.Columns.WEIGHT, mWeight);
        values.put(CatchTable.Columns.WATER_DEPTH, mWaterDepth);
        values.put(CatchTable.Columns.WATER_TEMPERATURE, mWaterTemperature);

        if (mBait != null)
            values.put(CatchTable.Columns.BAIT_ID, mBait.idAsString());

        if (mFishingSpot != null)
            values.put(CatchTable.Columns.FISHING_SPOT_ID, mFishingSpot.idAsString());

        if (mWaterClarity != null)
            values.put(CatchTable.Columns.CLARITY_ID, mWaterClarity.idAsString());

        if (mNotes != null)
            values.put(CatchTable.Columns.NOTES, mNotes);

        return values;
    }

    /**
     * Used deleting catches. This method will remove any external ties to the database. For
     * example, removing images and weather data from the database.
     */
    public void removeDatabaseProperties() {
        ArrayList<String> photos = getPhotos();
        for (String s : photos)
            removePhoto(s);

        removeWeather();
        mUsedFishingMethods.deleteObjects();
    }
}
