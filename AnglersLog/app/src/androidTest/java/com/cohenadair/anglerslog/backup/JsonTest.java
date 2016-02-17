package com.cohenadair.anglerslog.backup;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.Weather;
import com.cohenadair.anglerslog.model.backup.JsonExporter;
import com.cohenadair.anglerslog.model.backup.JsonImporter;
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

import org.json.JSONException;
import org.json.JSONObject;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import static android.support.test.InstrumentationRegistry.getTargetContext;
import static org.junit.Assert.assertTrue;

/**
 * Tests for importing and exporting JSON objects. Tests are done by first creating some dummy
 * objects with some and all attributes set and adding these objects to the test Logbook database.
 *
 * These dummy objects are then exported to JSON.  The exported JSON is then used to for importing.
 * If all is successful, the dummy objects' and the imported objects' attributes should all be
 * equal.
 *
 * @author Cohen Adair
 */
@RunWith(AndroidJUnit4.class)
public class JsonTest {

    private SQLiteDatabase mDatabase;

    private Location mLocation;
    private BaitCategory mBaitCategory;
    private Bait mBait;
    private WaterClarity mWaterClarity;
    private FishingSpot mFishingSpot;
    private Species mSpecies;
    private Catch mCatch;
    private Angler mAngler;
    private FishingMethod mFishingMethod;
    private Trip mTrip;

    @Before
    public void setUp() throws Exception {
        RenamingDelegatingContext context = new RenamingDelegatingContext(getTargetContext(), "test_");
        context.deleteDatabase(LogbookHelper.DATABASE_NAME);
        mDatabase = new LogbookHelper(context).getWritableDatabase();
        Logbook.init(context, mDatabase);
        initTestObjects();
    }

    @After
    public void tearDown() throws Exception {
        mDatabase.close();
        mLocation = null;
        mBait = null;
        mBaitCategory = null;
        mWaterClarity = null;
        mFishingSpot = null;
        mSpecies = null;
        mCatch = null;
        mAngler = null;
        mFishingMethod = null;
        mTrip = null;
    }

    @Test
    public void testUserDefineObject() {
        try {
            UserDefineObject obj = new UserDefineObject("Name");
            JSONObject exportObj = obj.toJson();
            UserDefineObject importObj = new UserDefineObject(exportObj);

            assertTrue(obj.getId().equals(importObj.getId()));
            assertTrue(obj.getName().equals(importObj.getName()));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testTrip() {
        try {
            // default object with no properties set
            Trip obj = new Trip("Name");
            JSONObject exportObj = obj.toJson();
            Trip importObj = new Trip(exportObj);

            assertTrue(obj.getStartDate().equals(importObj.getStartDate()));
            assertTrue(obj.getEndDate().equals(importObj.getEndDate()));

            // all properties set
            ArrayList<UserDefineObject> anglers = new ArrayList<>();
            anglers.add(mAngler);
            obj.setAnglers(anglers);

            ArrayList<UserDefineObject> locations = new ArrayList<>();
            locations.add(mLocation);
            obj.setAnglers(locations);

            ArrayList<UserDefineObject> catches = new ArrayList<>();
            catches.add(mCatch);
            obj.setAnglers(catches);

            exportObj = obj.toJson();
            importObj = new Trip(exportObj);

            assertTrue(obj.getAnglers().equals(importObj.getAnglers()));
            assertTrue(obj.getLocations().equals(importObj.getLocations()));
            assertTrue(obj.getCatches().equals(importObj.getCatches()));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testCatch() {
        try {
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(new Date());
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);

            // default object with no properties set
            Catch obj = new Catch(calendar.getTime());
            JSONObject exportObj = obj.toJson();
            Catch importObj = new Catch(exportObj);

            assertTrue(obj.getDate().equals(importObj.getDate()));

            // all properties set
            obj.setIsFavorite(true);
            obj.setSpecies(mSpecies);
            obj.setCatchResult(Catch.CatchResult.RELEASED);
            obj.setQuantity(5);
            obj.setLength(15);
            obj.setWeight((float) 3.5);
            obj.setWaterDepth((float) 5.5);
            obj.setWaterTemperature(67);
            obj.setWaterClarity(mWaterClarity);
            obj.setNotes("Average bass");
            obj.setBait(mBait);
            obj.setFishingSpot(mFishingSpot);

            ArrayList<String> photos = new ArrayList<>();
            photos.add("img1.png");
            photos.add("img2.png");
            obj.setPhotos(photos);

            ArrayList<UserDefineObject> fishingMethods = new ArrayList<>();
            fishingMethods.add(mLocation);
            obj.setFishingMethods(fishingMethods);

            exportObj = obj.toJson();
            importObj = new Catch(exportObj);

            assertTrue(obj.isFavorite() == importObj.isFavorite());
            assertTrue(obj.getSpecies().getId().equals(importObj.getSpecies().getId()));
            assertTrue(obj.getCatchResult().getValue() == importObj.getCatchResult().getValue());
            assertTrue(obj.getQuantity() == importObj.getQuantity());
            assertTrue(obj.getLength() == importObj.getLength());
            assertTrue(obj.getWeight() == importObj.getWeight());
            assertTrue(obj.getWaterDepth() == importObj.getWaterDepth());
            assertTrue(obj.getWaterTemperature() == importObj.getWaterTemperature());
            assertTrue(obj.getWaterClarity().getId().equals(importObj.getWaterClarity().getId()));
            assertTrue(obj.getNotes().equals(importObj.getNotes()));
            assertTrue(obj.getBait().getId().equals(importObj.getBait().getId()));
            assertTrue(obj.getFishingSpot().getId().equals(importObj.getFishingSpot().getId()));
            assertTrue(obj.getPhotos().equals(importObj.getPhotos()));
            assertTrue(obj.getFishingMethods().equals(importObj.getFishingMethods()));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testWeather() {
        try {
            Weather obj = new Weather(50, 10, "Cloudy");
            JSONObject exportObj = obj.toJson(mCatch);
            Weather importObj = new Weather(exportObj);

            assertTrue(obj.getTemperature() == importObj.getTemperature());
            assertTrue(obj.getWindSpeed() == importObj.getWindSpeed());
            assertTrue(obj.getSkyConditions().equals(importObj.getSkyConditions()));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Test
     public void testLocation() {
        try {
            Location obj = new Location("Location");
            obj.addFishingSpot(mFishingSpot);

            JSONObject exportObj = obj.toJson();
            Location importObj = new Location(exportObj);

            assertTrue(obj.getFishingSpots().equals(importObj.getFishingSpots()));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testBait() {
        try {
            // default with no properties set
            Bait obj = new Bait("Bait", mBaitCategory);
            JSONObject exportObj = obj.toJson();
            Bait importObj = new Bait(exportObj);

            assertTrue(obj.getCategoryId().equals(importObj.getCategoryId()));

            // with all properties set
            obj.setColor("Red");
            obj.setSize("Large");
            obj.setDescription("An awesome bait.");
            obj.setType(Bait.TYPE_LIVE);

            exportObj = obj.toJson();
            importObj = new Bait(exportObj);

            assertTrue(obj.getColorAsString().equals(importObj.getColorAsString()));
            assertTrue(obj.getSizeAsString().equals(importObj.getSizeAsString()));
            assertTrue(obj.getDescriptionAsString().equals(importObj.getDescriptionAsString()));
            assertTrue(obj.getType() == importObj.getType());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Test
    public void testLogbook() {
        try {
            int anglerCount = Logbook.getAnglerCount();
            int baitCount = Logbook.getBaitCount();
            int baitCategoryCount = Logbook.getBaitCategoryCount();
            int catchCount = Logbook.getCatchCount();
            int fishingMethodCount = Logbook.getFishingMethodCount();
            int fishingSpotCount = Logbook.getAllFishingSpots().size();
            int locationCount = Logbook.getLocationCount();
            int speciesCount = Logbook.getSpeciesCount();
            int tripCount = Logbook.getTripCount();
            int waterClarityCount = Logbook.getWaterClarityCount();
            int photoCount = Logbook.getAllBaitPhotos().size() + Logbook.getAllCatchPhotos().size();

            JSONObject jsonLogbook = JsonExporter.getJson();
            JsonImporter.parse(jsonLogbook);

            assertTrue(Logbook.getAnglerCount() == anglerCount);
            assertTrue(Logbook.getBaitCount() == baitCount);
            assertTrue(Logbook.getBaitCategoryCount() == baitCategoryCount);
            assertTrue(Logbook.getFishingMethodCount() == fishingMethodCount);
            assertTrue(Logbook.getAllFishingSpots().size() == fishingSpotCount);
            assertTrue(Logbook.getLocationCount() == locationCount);
            assertTrue(Logbook.getSpeciesCount() == speciesCount);
            assertTrue(Logbook.getTripCount() == tripCount);
            assertTrue(Logbook.getWaterClarityCount() == waterClarityCount);
            assertTrue(Logbook.getCatchCount() == catchCount);
            assertTrue(Logbook.getAllBaitPhotos().size() + Logbook.getAllCatchPhotos().size() == photoCount);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void initTestObjects() {
        mSpecies = new Species("Bass");
        Logbook.addSpecies(mSpecies);

        mBaitCategory = new BaitCategory("Minnow");
        Logbook.addBaitCategory(mBaitCategory);

        mBait = new Bait("Shiner", mBaitCategory);
        Logbook.addBait(mBait);

        mWaterClarity = new WaterClarity("Clear");
        Logbook.addWaterClarity(mWaterClarity);

        mFishingSpot = new FishingSpot("Rocks");
        mLocation = new Location("Port Albert");
        mLocation.addFishingSpot(mFishingSpot);
        Logbook.addLocation(mLocation);

        mCatch = new Catch(new Date());
        mCatch.setSpecies(mSpecies);
        Logbook.addCatch(mCatch);

        mAngler = new Angler("Angler");
        Logbook.addAngler(mAngler);

        mFishingMethod = new FishingMethod("Boat");
        Logbook.addFishingMethod(mFishingMethod);

        mTrip = new Trip("Trip");

        ArrayList<UserDefineObject> anglers = new ArrayList<>();
        anglers.add(mAngler);
        mTrip.setAnglers(anglers);

        ArrayList<UserDefineObject> locations = new ArrayList<>();
        locations.add(mLocation);
        mTrip.setAnglers(locations);

        ArrayList<UserDefineObject> catches = new ArrayList<>();
        catches.add(mCatch);
        mTrip.setAnglers(catches);

        Logbook.addTrip(mTrip);
    }
}
