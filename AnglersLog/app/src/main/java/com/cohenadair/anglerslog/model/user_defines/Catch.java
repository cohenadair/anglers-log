package com.cohenadair.anglerslog.model.user_defines;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.text.format.DateFormat;
import android.util.Log;

import com.cohenadair.anglerslog.R;
import com.cohenadair.anglerslog.database.QueryHelper;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.backup.Json;
import com.cohenadair.anglerslog.model.backup.JsonExporter;
import com.cohenadair.anglerslog.model.backup.JsonImporter;
import com.cohenadair.anglerslog.model.utilities.HasDateInterface;
import com.cohenadair.anglerslog.model.utilities.UsedUserDefineObject;
import com.cohenadair.anglerslog.model.utilities.UserDefineArrays;
import com.cohenadair.anglerslog.utilities.Utils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

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
public class Catch extends PhotoUserDefineObject implements HasDateInterface {

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

    public Catch(JSONObject catchJson) throws JSONException {
        super(catchJson, CatchPhotoTable.NAME);
        init();

        mDate = JsonImporter.parseDate(catchJson.getString(Json.DATE));
        mSpecies = Logbook.getSpecies(catchJson.getString(Json.FISH_SPECIES));
        mLength = (float)catchJson.getDouble(Json.FISH_LENGTH);
        mQuantity = catchJson.getInt(Json.FISH_QUANTITY);
        mCatchResult = CatchResult.fromInt(catchJson.getInt(Json.FISH_RESULT));
        mWaterTemperature = catchJson.getInt(Json.WATER_TEMPERATURE);
        mWaterClarity = Logbook.getWaterClarity(catchJson.getString(Json.WATER_CLARITY));
        mWaterDepth = (float)catchJson.getDouble(Json.WATER_DEPTH);
        mNotes = catchJson.getString(Json.NOTES);

        mWeight = (float)catchJson.getDouble(Json.FISH_WEIGHT);

        // there is no Json.FISH_OUNCES property when importing from Android
        try {
            mWeight += JsonImporter.ouncesToDecimal(catchJson.getInt(Json.FISH_OUNCES));
        } catch (JSONException e) {
            Log.e(TAG, "No JSON value for " + Json.FISH_OUNCES);
        }

        // from iOS, weight could equal 0
        if (mWeight <= 0)
            mWeight = -1;

        // there is no Json.IS_FAVORITE when importing from iOS
        try {
            mIsFavorite = catchJson.getBoolean(Json.IS_FAVORITE);
        } catch (JSONException e) {
            Log.e(TAG, "No JSON value " + Json.IS_FAVORITE);
        }

        // location
        Location location = Logbook.getLocation(catchJson.getString(Json.LOCATION));
        if (location != null)
            mFishingSpot = Logbook.getFishingSpot(catchJson.getString(Json.FISHING_SPOT), location.getId());

        // bait
        // if there is no used bait, don't even bother looking for the bait category
        // an "Other" category will be returned in this case
        String baitName = catchJson.getString(Json.BAIT_USED);
        if (!baitName.isEmpty())
            mBait = Logbook.getBait(baitName, JsonImporter.baitCategoryOrOther(catchJson).getId());

        // fishing methods
        JSONArray fishingMethodsJson = catchJson.getJSONArray(Json.FISHING_METHOD_NAMES);
        mUsedFishingMethods.setObjects(JsonImporter.parseUserDefineArray(fishingMethodsJson, new JsonImporter.OnGetObject() {
            @Override
            public UserDefineObject onGetObject(String name) {
                return Logbook.getFishingMethod(name);
            }
        }));

        // weather data
        JSONObject weatherJson = catchJson.getJSONObject(Json.WEATHER_DATA);
        try {
            Weather weather = new Weather(
                    weatherJson.getInt(Json.TEMPERATURE),
                    (int) Float.parseFloat(weatherJson.getString(Json.WIND_SPEED)),
                    weatherJson.getString(Json.SKY_CONDITIONS)
            );
            setWeather(weather);
        } catch (JSONException e) {
            Log.e(TAG, "No JSON value for " + Json.WEATHER_DATA);
        }
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
        return Utils.emptyStringOrString(mNotes);
    }

    public String getFishingMethodsAsString() {
        return UserDefineArrays.namesAsString(getFishingMethods());
    }

    public String getCatchResultAsString(Context context) {
        return (mCatchResult != null) ? mCatchResult.getString(context) : "";
    }

    public String getDateJsonString() {
        return JsonExporter.dateToString(mDate);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Intent getShareIntent(Context context) {
        Intent intent = super.getShareIntent(context);

        String text = getSpeciesAsString();

        if (mLength > 0 && mWeight > 0)
            text += " measuring " + getLengthAsStringWithUnits() + " and weighing " + getWeightAsStringWithUnits();
        else if (mWeight > 0)
            text += " weighing " + getWeightAsStringWithUnits();
        else if (mLength > 0)
            text += " measuring " + getLengthAsStringWithUnits();

        intent.putExtra(Intent.EXTRA_TEXT, text + ". " + intent.getStringExtra(Intent.EXTRA_TEXT));

        return intent;
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

    /**
     * {@inheritDoc}
     */
    @Override
    public String toKeywordsString(Context context) {
        StringBuilder builder = new StringBuilder();

        // appendToBuilder isn't used here because it's used in the "nested" toKeywordsString calls
        builder.append((mSpecies == null) ? "" : mSpecies.toKeywordsString(context));
        builder.append((mWaterClarity == null) ? "" : mWaterClarity.toKeywordsString(context));
        builder.append((mBait == null) ? "" : mBait.toKeywordsString(context));
        builder.append((mBait == null) ? "" : mBait.getCategory().toKeywordsString(context));
        builder.append((mFishingSpot == null) ? "" : mFishingSpot.getLocation().toKeywordsString(context));
        builder.append((mFishingSpot == null) ? "" : mFishingSpot.toKeywordsString(context));
        builder.append(UserDefineArrays.keywordsAsString(context, getFishingMethods()));

        appendToBuilder(builder, getDateAsString());
        appendToBuilder(builder, mIsFavorite ? context.getResources().getString(R.string.favorite) : null);
        appendToBuilder(builder, mCatchResult.getString(context));
        appendToBuilder(builder, mQuantity);
        appendToBuilder(builder, mLength);
        appendToBuilder(builder, mWeight);
        appendToBuilder(builder, mWaterDepth);
        appendToBuilder(builder, mWaterTemperature);
        appendToBuilder(builder, mNotes);

        Weather weather = getWeather();
        appendToBuilder(builder, (weather == null) ? null : weather.toKeywordsString());

        return builder.toString();
    }

    /**
     * {@inheritDoc}
     *
     * Used in deleting catches. This method will remove any external ties to the database. For
     * example, removing images and weather data from the database.
     */
    @Override
    public void removeDatabaseProperties() {
        super.removeDatabaseProperties();

        ArrayList<String> photos = getPhotos();
        for (String s : photos)
            removePhoto(s);

        removeWeather();
        mUsedFishingMethods.deleteObjects();
    }
}
