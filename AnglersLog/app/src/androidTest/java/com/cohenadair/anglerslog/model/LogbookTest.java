package com.cohenadair.anglerslog.model;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

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

        // random photo
        assertTrue(Logbook.getRandomCatchPhoto() == null);
        catch0.addPhoto("Test.jpg");
        assertTrue(Logbook.getRandomCatchPhoto() != null);
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
}