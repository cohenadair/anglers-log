package com.cohenadair.anglerslog.model;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;

import com.cohenadair.anglerslog.database.LogbookHelper;
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

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.ArrayList;
import java.util.Date;

import static android.support.test.InstrumentationRegistry.getTargetContext;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * Tests for the Logbook (top level) class.
 * @author Cohen Adair
 */
@RunWith(AndroidJUnit4.class)
public class LogbookTest {

    private SQLiteDatabase mDatabase;

    @Before
    public void setUp() throws Exception {
        RenamingDelegatingContext context = new RenamingDelegatingContext(getTargetContext(), "test_");
        context.deleteDatabase(LogbookHelper.DATABASE_NAME);
        mDatabase = new LogbookHelper(context).getWritableDatabase();
        Logbook.initForTesting(context, mDatabase);
    }

    @After
    public void tearDown() throws Exception {
        mDatabase.close();
    }

    @Test
    public void testSpecies() {
        Species species0 = new Species("Steelhead");
        Species species1 = new Species("Bass");
        Species species2 = new Species(species1, true);
        species2.setName("Largemouth Bass");

        // add
        assertTrue(Logbook.addSpecies(species1));
        assertFalse(Logbook.addSpecies(species1));
        assertTrue(Logbook.getSpeciesCount() == 1);
        assertTrue(Logbook.getSpecies("Bass") != null);

        // edit
        assertTrue(Logbook.editSpecies(species1.getId(), species2));
        assertTrue(Logbook.getSpecies(species1.getId()) != null);

        // get single
        Species species3 = Logbook.getSpecies(species1.getId());
        assertTrue(species3.getId().equals(species2.getId()));
        assertTrue(species3.getName().equals(species2.getName()));

        // delete
        assertTrue(Logbook.removeSpecies(species1.getId()));
        assertTrue(Logbook.getSpeciesCount() == 0);

        // get multiple
        Logbook.addSpecies(species0);
        Logbook.addSpecies(species1);
        ArrayList<UserDefineObject> species = Logbook.getSpecies();
        assertTrue(species.size() == 2);
    }

    @Test
    public void testCatch() {
        Species species0 = new Species("Bass");
        Species species1 = new Species("Pike");
        Logbook.addSpecies(species0);
        Logbook.addSpecies(species1);

        Catch catch0 = new Catch(new Date());
        catch0.setSpecies(species0);

        Catch catch1 = new Catch(new Date(1444000000));
        catch1.setSpecies(species1);

        Catch catch2 = new Catch(catch1, true);
        catch2.setDate(new Date(1444777000));
        assertTrue(catch2.getId().equals(catch1.getId()));
        assertTrue(catch2.getSpecies() != null);

        // add
        assertTrue(Logbook.addCatch(catch1));
        assertFalse(Logbook.addCatch(catch1));
        assertTrue(Logbook.getCatchCount() == 1);
        assertTrue(Logbook.getCatch(new Date(1444000000)) != null);

        // edit
        assertTrue(Logbook.editCatch(catch1.getId(), catch2));
        assertTrue(Logbook.getCatch(catch1.getId()) != null);
        assertTrue(Logbook.getCatch(catch1.getId()).getDate().equals(catch2.getDate()));
        assertTrue(Logbook.getCatch(catch1.getId()).getSpecies().getName().equals("Pike"));

        // get single
        Catch catch3 = Logbook.getCatch(catch1.getId());
        assertTrue(catch3.getId().equals(catch1.getId()));
        assertTrue(catch3.getDate().equals(catch2.getDate()));

        // delete
        assertTrue(Logbook.removeCatch(catch1.getId()));
        assertTrue(Logbook.getCatchCount() == 0);

        // get multiple
        Logbook.addCatch(catch0);
        Logbook.addCatch(catch1);
        ArrayList<UserDefineObject> catches = Logbook.getCatches();
        assertTrue(catches.size() == 2);

        // delete with photos and weather (properties stored outside the CatchTable)
        catch0.setWeather(new Weather(10, 15, "Cloudy"));
        catch0.addPhoto("photo.png");
        Logbook.editCatch(catch0.getId(), catch0);
        assertTrue(Logbook.getCatch(catch0.getId()).getWeather() != null);
        assertTrue(Logbook.removeCatch(catch0.getId()));
        assertTrue(Logbook.removeCatch(catch1.getId()));
        assertTrue(Logbook.getCatchCount() == 0);

        // photos
        catch0.addPhoto("img1.png");
        catch0.addPhoto("img2.png");
        catch0.addPhoto("img3.png");
        Logbook.addCatch(catch0);
        ArrayList<String> photos = Logbook.getAllCatchPhotos();
        assertTrue(photos.size() == 3);
        assertTrue(Logbook.removeCatch(catch0.getId()));

        // searching
        catch0 = new Catch(new Date());
        catch0.setSpecies(species0);
        catch0.setWeather(new Weather(15, 20, "Cloudy"));
        catch0.setNotes("Awesome catch!");
        Logbook.addCatch(catch0);

        catch1 = new Catch(new Date(1444000000));
        catch1.setSpecies(species1);
        catch1.setNotes("Cool catch.");
        Logbook.addCatch(catch1);

        assertTrue(Logbook.getCatchCount() == 2);
        assertTrue(Logbook.getCatches("cloudy").size() == 1);
        assertTrue(Logbook.getCatches("awesome bass").size() == 1);
        assertTrue(Logbook.getCatches("cool pike").size() == 1);
        assertTrue(Logbook.getCatches("ike bass").size() == 2);
    }

    @Test
    public void testBaitCategory() {
        BaitCategory category0 = new BaitCategory("Stone Fly");
        BaitCategory category1 = new BaitCategory("Minnow");
        BaitCategory category2 = new BaitCategory(category1, true);
        category2.setName("Woolly Bugger");

        // add
        assertTrue(Logbook.addBaitCategory(category1));
        assertFalse(Logbook.addBaitCategory(category1));
        assertTrue(Logbook.getBaitCategoryCount() == 1);
        assertTrue(Logbook.getBaitCategory("Minnow") != null);

        // edit
        assertTrue(Logbook.editBaitCategory(category1.getId(), category2));
        assertTrue(Logbook.getBaitCategory(category1.getId()) != null);

        // get single
        BaitCategory category3 = Logbook.getBaitCategory(category1.getId());
        assertTrue(category3.getId().equals(category2.getId()));
        assertTrue(category3.getName().equals(category2.getName()));

        // delete
        assertTrue(Logbook.removeBaitCategory(category1.getId()));
        assertTrue(Logbook.getBaitCategoryCount() == 0);

        // get multiple
        Logbook.addBaitCategory(category0);
        Logbook.addBaitCategory(category1);
        ArrayList<UserDefineObject> categories = Logbook.getBaitCategories();
        assertTrue(categories.size() == 2);
    }

    @Test
    public void testBait() {
        BaitCategory bugger = new BaitCategory("Woolly Bugger");
        BaitCategory stone = new BaitCategory("Stone Fly");
        Logbook.addBaitCategory(bugger);
        Logbook.addBaitCategory(stone);

        Bait bait0 = new Bait("Pink", bugger);
        Bait bait1 = new Bait("Olive", bugger);
        Bait bait2 = new Bait(bait1, true);
        bait2.setName("Black");
        bait2.setCategory(stone);
        Bait bait3 = new Bait("Black", stone);

        // add
        assertTrue(Logbook.addBait(bait1));
        assertFalse(Logbook.addBait(bait1));
        assertTrue(Logbook.getBaitCount() == 1);
        assertTrue(Logbook.getBait("Olive", bugger.getId()) != null);

        // exists
        Bait dupBait = new Bait("Olive", bugger);
        assertTrue(Logbook.baitExists(dupBait));
        Bait dupBait2 = new Bait("White", stone);
        assertFalse(Logbook.baitExists(dupBait2));

        // add same name, different category
        assertTrue(Logbook.addBait(bait3));
        assertTrue(Logbook.removeBait(bait3.getId()));

        // edit
        assertTrue(Logbook.editBait(bait1.getId(), bait2));
        assertTrue(Logbook.getBait(bait1.getId()) != null);
        assertTrue(Logbook.getBait(bait1.getId()).getCategory().getName().equals("Stone Fly"));

        // get single
        Bait bait4 = Logbook.getBait(bait1.getId());
        assertTrue(bait4.getId().equals(bait1.getId()));
        assertTrue(bait4.getName().equals(bait2.getName()));

        // delete
        assertTrue(Logbook.removeBait(bait1.getId()));
        assertTrue(Logbook.getBaitCount() == 0);

        // get multiple
        Logbook.addBait(bait0);
        Logbook.addBait(bait1);
        ArrayList<UserDefineObject> baits = Logbook.getBaits();
        assertTrue(baits.size() == 2);
    }

    @Test
    public void testGetBaitsAndCategories() {
        BaitCategory bugger = new BaitCategory("Woolly Bugger");
        BaitCategory stone = new BaitCategory("Stone Fly");
        Logbook.addBaitCategory(bugger);
        Logbook.addBaitCategory(stone);

        Bait blackBugger = new Bait("Black", bugger);
        blackBugger.setSize("Large");
        blackBugger.setDescription("Excellent bait.");

        Bait whiteBugger = new Bait("White", bugger);
        Bait oliveBugger = new Bait("Olive", bugger);
        Bait blackStone = new Bait("Black", stone);
        Bait whiteStone = new Bait("White", stone);

        Bait yellowStone = new Bait("Yellow", stone);
        yellowStone.setSize("Small");
        yellowStone.setType(Bait.TYPE_REAL);
        yellowStone.setColor("Bright Yellow");

        Logbook.addBait(blackBugger);
        Logbook.addBait(whiteBugger);
        Logbook.addBait(oliveBugger);
        Logbook.addBait(blackStone);
        Logbook.addBait(whiteStone);
        Logbook.addBait(yellowStone);

        ArrayList<UserDefineObject> baitsAndCategories = Logbook.getBaitsAndCategories();
        assertTrue(baitsAndCategories.size() == 8);

        // searching
        assertTrue(Logbook.getBaitsAndCategories("bugger").size() == 5); // 3 baits + 2 categories
        assertTrue(Logbook.getBaitsAndCategories("black").size() == 4); // 2 baits + 2 categories
        assertTrue(Logbook.getBaitsAndCategories("bright").size() == 3); // 1 bait + 2 categories
        assertTrue(Logbook.getBaitsAndCategories("small").size() == 3); // 1 bait + 2 categories
        assertTrue(Logbook.getBaitsAndCategories("large").size() == 3); // 1 bait + 2 categories
        assertTrue(Logbook.getBaitsAndCategories("llent large").size() == 3); // 1 bait + 2 categories
        assertTrue(Logbook.getBaitsAndCategories("real olive").size() == 4); // 2 baits + 2 categories
    }

    @Test
    public void testLocation() {
        Location loc0 = new Location("Port Albert");
        Location loc1 = new Location("Goderich");
        Location loc2 = new Location(loc1, true);
        loc2.setName("River");

        // add
        assertTrue(Logbook.addLocation(loc1));
        assertFalse(Logbook.addLocation(loc1));
        assertTrue(Logbook.getLocationCount() == 1);
        assertTrue(Logbook.getLocation("Goderich") != null);

        // exists
        Location dupLoc = new Location("Goderich");
        assertTrue(Logbook.locationExists(dupLoc));
        Location dupLoc2 = new Location("Port Albert");
        assertFalse(Logbook.locationExists(dupLoc2));

        // edit
        assertTrue(Logbook.editLocation(loc1.getId(), loc2));
        assertTrue(Logbook.getLocation(loc1.getId()) != null);
        assertTrue(Logbook.getLocation(loc1.getId()).getName().equals("River"));

        // get single
        Location loc4 = Logbook.getLocation(loc1.getId());
        assertTrue(loc4.getId().equals(loc1.getId()));
        assertTrue(loc4.getName().equals(loc2.getName()));

        // delete
        Location loc5 = Logbook.getLocation(loc1.getId());
        loc5.addFishingSpot(new FishingSpot("Spot1"));
        loc5.addFishingSpot(new FishingSpot("Spot2"));
        assertTrue(Logbook.removeLocation(loc5.getId()));
        assertTrue(Logbook.getLocationCount() == 0);

        // get multiple
        Logbook.addLocation(loc0);
        Logbook.addLocation(loc1);
        ArrayList<UserDefineObject> locs = Logbook.getLocations();
        assertTrue(locs.size() == 2);

        // get all fishing spots
        loc0.addFishingSpot(new FishingSpot("Spot 1"));
        loc0.addFishingSpot(new FishingSpot("Spot 2"));
        loc1.addFishingSpot(new FishingSpot("Spot 1"));
        loc1.addFishingSpot(new FishingSpot("Spot 2"));
        loc1.addFishingSpot(new FishingSpot("Spot 3"));
        assertTrue(Logbook.getAllFishingSpots().size() == 5);
        assertTrue(Logbook.getFishingSpot("Spot 1", loc0.getId()) != null);

        // searching
        assertTrue(Logbook.getLocations("rich").size() == 1);
        assertTrue(Logbook.getLocations("albert").size() == 1);
        assertTrue(Logbook.getLocations("rich spot 3 spot 1").size() == 2);
    }

    @Test
    public void testWaterClarity() {
        WaterClarity charity0 = new WaterClarity("Clear");
        WaterClarity charity1 = new WaterClarity("Chocolate Milk");
        WaterClarity charity2 = new WaterClarity(charity1, true);
        charity2.setName("Crystal");

        // add
        assertTrue(Logbook.addWaterClarity(charity1));
        assertFalse(Logbook.addWaterClarity(charity1));
        assertTrue(Logbook.getWaterClarityCount() == 1);
        assertTrue(Logbook.getWaterClarity("Chocolate Milk") != null);

        // edit
        assertTrue(Logbook.editWaterClarity(charity1.getId(), charity2));
        assertTrue(Logbook.getWaterClarity(charity1.getId()) != null);

        // get single
        WaterClarity charity3 = Logbook.getWaterClarity(charity1.getId());
        assertTrue(charity3.getId().equals(charity2.getId()));
        assertTrue(charity3.getName().equals(charity2.getName()));

        // delete
        assertTrue(Logbook.removeWaterClarity(charity1.getId()));
        assertTrue(Logbook.getWaterClarityCount() == 0);

        // get multiple
        Logbook.addWaterClarity(charity0);
        Logbook.addWaterClarity(charity1);
        ArrayList<UserDefineObject> clarities = Logbook.getWaterClarities();
        assertTrue(clarities.size() == 2);
    }

    @Test
    public void testFishingMethod() {
        FishingMethod method0 = new FishingMethod("Drifting");
        FishingMethod method1 = new FishingMethod("Trolling");
        FishingMethod method2 = new FishingMethod(method1, true);
        method2.setName("Fly");

        // add
        assertTrue(Logbook.addFishingMethod(method1));
        assertFalse(Logbook.addFishingMethod(method1));
        assertTrue(Logbook.getFishingMethodCount() == 1);
        assertTrue(Logbook.getFishingMethod("Trolling") != null);

        // edit
        assertTrue(Logbook.editFishingMethod(method1.getId(), method2));
        assertTrue(Logbook.getFishingMethod(method1.getId()) != null);

        // get single
        FishingMethod method3 = Logbook.getFishingMethod(method1.getId());
        assertTrue(method3.getId().equals(method2.getId()));
        assertTrue(method3.getName().equals(method2.getName()));

        // delete
        assertTrue(Logbook.removeFishingMethod(method1.getId()));
        assertTrue(Logbook.getFishingMethodCount() == 0);

        // get multiple
        Logbook.addFishingMethod(method0);
        Logbook.addFishingMethod(method1);
        ArrayList<UserDefineObject> methods = Logbook.getFishingMethods();
        assertTrue(methods.size() == 2);
    }

    @Test
    public void testAngler() {
        Angler angler0 = new Angler("Cohen Adair");
        Angler angler1 = new Angler("Eli Adair");
        Angler angler2 = new Angler(angler1, true);
        angler2.setName("Ethan Adair");

        // add
        assertTrue(Logbook.addAngler(angler1));
        assertFalse(Logbook.addAngler(angler1));
        assertTrue(Logbook.getAnglerCount() == 1);
        assertTrue(Logbook.getAngler("Eli Adair") != null);

        // edit
        assertTrue(Logbook.editAngler(angler1.getId(), angler2));
        assertTrue(Logbook.getAngler(angler1.getId()) != null);

        // get single
        Angler angler3 = Logbook.getAngler(angler1.getId());
        assertTrue(angler3.getId().equals(angler2.getId()));
        assertTrue(angler3.getName().equals(angler2.getName()));

        // delete
        assertTrue(Logbook.removeAngler(angler1.getId()));
        assertTrue(Logbook.getAnglerCount() == 0);

        // get multiple
        Logbook.addAngler(angler0);
        Logbook.addAngler(angler1);
        ArrayList<UserDefineObject> anglers = Logbook.getAnglers();
        assertTrue(anglers.size() == 2);
    }

    @Test
    public void testTrip() {
        Trip trip0 = new Trip("Silver Lake 2014");
        trip0.setStartDate(new Date(1000000));
        trip0.setEndDate(new Date(2000000));
        Trip trip1 = new Trip("Lake Ontario 2013");
        trip1.setStartDate(new Date(3000000));
        trip1.setEndDate(new Date(4000000));
        Trip trip2 = new Trip(trip1, true);
        trip2.setName("Port Albert Opening Weekend 2014");

        // add
        assertTrue(Logbook.addTrip(trip1));
        assertFalse(Logbook.addTrip(trip1));
        assertTrue(Logbook.getTripCount() == 1);

        // exists
        assertTrue(Logbook.tripExists(trip1));
        Trip trip3 = new Trip("");
        trip3.setStartDate(new Date(3100000));
        trip3.setEndDate(new Date(4200000));
        assertTrue(Logbook.tripExists(trip3));
        trip3.setStartDate(new Date(2900000));
        trip3.setEndDate(new Date(5000000));
        assertTrue(Logbook.tripExists(trip3));
        trip3.setStartDate(new Date(3100000));
        trip3.setEndDate(new Date(3900000));
        assertTrue(Logbook.tripExists(trip3));
        trip3.setStartDate(new Date(2900000));
        trip3.setEndDate(new Date(3900000));
        assertTrue(Logbook.tripExists(trip3));

        // edit
        assertTrue(Logbook.editTrip(trip1.getId(), trip2));
        assertTrue(Logbook.getTrip(trip1.getId()) != null);

        // get single
        Trip trip4 = Logbook.getTrip(trip1.getId());
        assertTrue(trip4.getId().equals(trip2.getId()));
        assertTrue(trip4.getName().equals(trip2.getName()));

        // delete
        assertTrue(Logbook.removeTrip(trip1.getId()));
        assertTrue(Logbook.getTripCount() == 0);

        // get multiple
        Logbook.addTrip(trip0);
        Logbook.addTrip(trip1);
        ArrayList<UserDefineObject> trips = Logbook.getTrips();
        assertTrue(trips.size() == 2);

        // searching
        assertTrue(Logbook.getTrips("lake").size() == 2);
        assertTrue(Logbook.getTrips("lake ontario silver").size() == 2);
        assertTrue(Logbook.getTrips("silver").size() == 1);
        assertTrue(Logbook.getTrips("ontario").size() == 1);
    }

    @Test
    public void testCatchQuantities() {
        Species aSpecies = new Species("Steelhead");
        Logbook.addSpecies(aSpecies);

        BaitCategory aBaitCategory = new BaitCategory("Bugger");
        Logbook.addBaitCategory(aBaitCategory);

        Bait aBait = new Bait("Olive", aBaitCategory);
        Logbook.addBait(aBait);

        Location aLocation = new Location("Port Albert");
        FishingSpot aFishingSpot = new FishingSpot("Baskets");
        aLocation.addFishingSpot(aFishingSpot);
        Logbook.addLocation(aLocation);

        Catch aCatch = new Catch(new Date());
        aCatch.setSpecies(aSpecies);
        aCatch.setBait(aBait);
        aCatch.setFishingSpot(aFishingSpot);
        aCatch.setQuantity(50);
        Logbook.addCatch(aCatch);

        ArrayList<Stats.Quantity> baitQuantities = Logbook.getBaitUsedCount();
        assertTrue(baitQuantities.size() == 1);
        assertTrue(baitQuantities.get(0).getQuantity() == 50);

        ArrayList<Stats.Quantity> speciesQuantities = Logbook.getSpeciesCaughtCount();
        assertTrue(speciesQuantities.size() == 1);
        assertTrue(speciesQuantities.get(0).getQuantity() == 50);

        ArrayList<Stats.Quantity> locationQuantities = Logbook.getLocationCatchCount();
        assertTrue(locationQuantities.size() == 1);
        assertTrue(locationQuantities.get(0).getQuantity() == 50);

        aCatch = new Catch(new Date(10000000));
        aCatch.setSpecies(aSpecies);
        aCatch.setBait(aBait);
        aCatch.setFishingSpot(aFishingSpot);
        aCatch.setQuantity(20);
        Logbook.addCatch(aCatch);

        baitQuantities = Logbook.getBaitUsedCount();
        assertTrue(baitQuantities.get(0).getQuantity() == 70);

        speciesQuantities = Logbook.getSpeciesCaughtCount();
        assertTrue(speciesQuantities.get(0).getQuantity() == 70);

        locationQuantities = Logbook.getLocationCatchCount();
        assertTrue(locationQuantities.get(0).getQuantity() == 70);
    }

    @Test
    public void testStats() {
        Species s1 = new Species("Bass");
        Species s2 = new Species("Pike");
        Logbook.addSpecies(s1);
        Logbook.addSpecies(s2);

        Catch c1 = new Catch(new Date(1000000));
        c1.setSpecies(s1);
        c1.setLength(15);
        c1.setWeight(4);

        Catch c2 = new Catch(new Date(2000000));
        c2.setSpecies(s1);
        c2.setLength(20);
        c2.setWeight(2);

        Catch c3 = new Catch(new Date(3000000));
        c3.setSpecies(s2);
        c3.setLength(33);
        c3.setWeight(12);

        Catch c4 = new Catch(new Date(4000000));
        c4.setSpecies(s2);
        c4.setLength(24);
        c4.setWeight(16);

        Logbook.addCatch(c1);
        Logbook.addCatch(c2);
        Logbook.addCatch(c3);
        Logbook.addCatch(c4);

        // longest
        assertTrue(Logbook.getLongestCatch().getId().equals(c3.getId()));

        // heaviest
        assertTrue(Logbook.getHeaviestCatch().getId().equals(c4.getId()));

        // heaviest by species
        assertTrue(Logbook.getHeaviestCatch(s1).getId().equals(c1.getId()));
        assertTrue(Logbook.getHeaviestCatch(s2).getId().equals(c4.getId()));

        // longest by species
        assertTrue(Logbook.getLongestCatch(s1).getId().equals(c2.getId()));
        assertTrue(Logbook.getLongestCatch(s2).getId().equals(c3.getId()));
    }
}