package com.cohenadair.anglerslog.model;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;
import android.util.Log;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

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
        Logbook.init(context, mDatabase);
        Log.d("", "Setup");
    }

    @After
    public void tearDown() throws Exception {
        mDatabase.close();
        Log.d("", "TearDown");
    }

    //region Catch Tests
    @Test
    public void testAddRemoveCatch() {
        Catch testCatch = new Catch(new Date());
        Catch testCatch2 = new Catch(testCatch.getDate()); // equal dates

        Logbook.addCatch(testCatch);
        assertTrue(Logbook.getCatchCount() == 1);

        // a Catch with a duplicate date shouldn't be added
        assertFalse(Logbook.addCatch(testCatch2));

        assertTrue(Logbook.removeCatch(testCatch.getId()));
        assertTrue(Logbook.getCatchCount() == 0);
    }

    @Test
    public void testCatchExists() {
        Catch testCatch = new Catch(new Date());
        Date testDate = new Date(testCatch.getDate().getTime());

        Logbook.addCatch(testCatch);
        assertTrue(Logbook.catchExists(testDate));
    }

    @Test
    public void testCloneCatch() {
        Catch testCatch = new Catch(new Date());
        Catch clonedCatch = new Catch(testCatch);

        assertTrue(testCatch.getDate().equals(clonedCatch.getDate())); // equal dates
        assertFalse(testCatch.getId().equals(clonedCatch.getId()));

        testCatch.addPhoto("test.jpg");
        assertFalse(testCatch.getPhotoCount() == clonedCatch.getPhotoCount());
    }

    @Test
    public void testAddRemovePhoto() {
        Catch testCatch = new Catch(new Date());

        String fileName1 = testCatch.getNextPhotoName();
        testCatch.addPhoto(fileName1);
        assertTrue(testCatch.getPhotoCount() == 1);

        String fileName2 = testCatch.getNextPhotoName();
        testCatch.addPhoto(fileName2);
        assertTrue(testCatch.getPhotoCount() == 2);

        testCatch.removePhoto(fileName1);
        assertTrue(testCatch.getPhotoCount() == 1);

        testCatch.removePhoto(fileName2);
        assertTrue(testCatch.getPhotoCount() == 0);
    }
    //endregion

    //region Species Tests
    @Test
    public void testAddRemoveSpecies() {
        Species testSpecies = new Species("Example Species");
        Species testSpecies2 = new Species(testSpecies.getName());

        Logbook.addSpecies(testSpecies);
        assertTrue(Logbook.getSpeciesCount() == 1);

        assertTrue(Logbook.getSpecies(testSpecies.getId()) != null);

        // a Species with a duplicate name shouldn't be added
        assertFalse(Logbook.addSpecies(testSpecies2));

        Logbook.removeSpecies(testSpecies.getId());
        assertTrue(Logbook.getSpeciesCount() == 0);
    }

    @Test
    public void testEditSpecies() {
        Species species1 = new Species("Bass");
        Species species2 = new Species("Largemouth Bass");

        // references aren't equal
        assertFalse(species1 == species2);

        Logbook.addSpecies(species1);
        Logbook.editSpecies(species1.getId(), species2);

        // names are equal
        assertTrue(Logbook.getSpecies(species1.getId()).getName().equals(species2.getName()));
    }
    //endregion

}