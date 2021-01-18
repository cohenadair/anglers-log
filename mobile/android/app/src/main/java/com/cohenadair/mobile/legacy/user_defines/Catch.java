package com.cohenadair.mobile.legacy.user_defines;

import android.content.ContentValues;
import android.content.Context;

import com.cohenadair.mobile.legacy.Utils;
import com.cohenadair.mobile.legacy.database.QueryHelper;
import com.cohenadair.mobile.legacy.Logbook;
import com.cohenadair.mobile.legacy.Weather;
import com.cohenadair.mobile.legacy.backup.Json;
import com.cohenadair.mobile.legacy.backup.JsonExporter;
import com.cohenadair.mobile.legacy.HasDateInterface;
import com.cohenadair.mobile.legacy.UsedUserDefineObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;

import static com.cohenadair.mobile.legacy.database.LogbookSchema.CatchPhotoTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.CatchTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.UsedFishingMethodTable;
import static com.cohenadair.mobile.legacy.database.LogbookSchema.WeatherTable;

/**
 * The Catch class stores relative information for a single fishing catch.
 * @author Cohen Adair
 */
public class Catch extends PhotoUserDefineObject implements HasDateInterface {
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
    }

    //region Constructors
    public Catch(Date date, Context context) {
        super(Utils.getLongDisplayDate(date, context), CatchPhotoTable.NAME);
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
    @Override
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
        mNotes = Utils.stringOrNull(notes);
    }
    //endregion

    //region Fishing Method Manipulation
    public ArrayList<UserDefineObject> getFishingMethods() {
        return mUsedFishingMethods.getObjects(Logbook::getFishingMethod);
    }
    //endregion

    //region Weather Manipulation
    public Weather getWeather() {
        return QueryHelper.queryWeather(getId());
    }

    public boolean removeWeather() {
        return QueryHelper.deleteQuery(WeatherTable.NAME, WeatherTable.Columns.CATCH_ID + " = ?", new String[] { getIdAsString() });
    }
    //endregion

    @Override
    public String getName() {
        return getSpeciesAsString();
    }

    public String getSpeciesAsString() {
        return (mSpecies != null) ? mSpecies.getName() : "";
    }

    public String getWaterClarityAsString() {
        return (mWaterClarity != null) ? mWaterClarity.getName() : "";
    }

    String getDateJsonString() {
        return JsonExporter.dateToString(mDate);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ContentValues getContentValues() {
        ContentValues values = super.getContentValues();

        values.put(CatchTable.Columns.DATE, mDate.getTime());
        values.put(CatchTable.Columns.IS_FAVORITE, mIsFavorite ? 1 : 0);
        values.put(CatchTable.Columns.SPECIES_ID, mSpecies.getIdAsString());
        values.put(CatchTable.Columns.CATCH_RESULT, mCatchResult.getValue());
        values.put(CatchTable.Columns.QUANTITY, mQuantity);
        values.put(CatchTable.Columns.LENGTH, mLength);
        values.put(CatchTable.Columns.WEIGHT, mWeight);
        values.put(CatchTable.Columns.WATER_DEPTH, mWaterDepth);
        values.put(CatchTable.Columns.WATER_TEMPERATURE, mWaterTemperature);

        if (mBait != null)
            values.put(CatchTable.Columns.BAIT_ID, mBait.getIdAsString());

        if (mFishingSpot != null)
            values.put(CatchTable.Columns.FISHING_SPOT_ID, mFishingSpot.getIdAsString());

        if (mWaterClarity != null)
            values.put(CatchTable.Columns.CLARITY_ID, mWaterClarity.getIdAsString());

        if (mNotes != null)
            values.put(CatchTable.Columns.NOTES, mNotes);

        return values;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public JSONObject toJson() throws JSONException {
        JSONObject json = super.toJson();

        json.put(Json.DATE, getDateJsonString());
        json.put(Json.IS_FAVORITE, mIsFavorite);
        json.put(Json.FISH_SPECIES, getSpeciesAsString());
        json.put(Json.FISH_RESULT, mCatchResult.getValue());
        json.put(Json.FISH_QUANTITY, mQuantity);
        json.put(Json.FISH_LENGTH, mLength);
        json.put(Json.FISH_WEIGHT, mWeight);
        json.put(Json.WATER_DEPTH, mWaterDepth);
        json.put(Json.WATER_TEMPERATURE, mWaterTemperature);
        json.put(Json.WATER_CLARITY, getWaterClarityAsString());
        json.put(Json.BAIT_USED, mBait == null ? "" : mBait.getName());
        json.put(Json.BAIT_CATEGORY, mBait == null ? "" : mBait.getCategoryId().toString());
        json.put(Json.LOCATION, mFishingSpot == null ? "" : mFishingSpot.getLocationName());
        json.put(Json.FISHING_SPOT, mFishingSpot == null ? "" : mFishingSpot.getName());
        json.put(Json.NOTES, mNotes == null ? "" : mNotes);
        json.put(Json.FISHING_METHOD_NAMES, JsonExporter.getNameJsonArray(getFishingMethods()));

        // for iOS compatibility
        json.put(Json.JOURNAL, Logbook.getName());

        // weather data
        Weather weather = getWeather();
        json.put(Json.WEATHER_DATA, (weather == null) ? new JSONObject() : weather.toJson(this));

        return json;
    }
}
