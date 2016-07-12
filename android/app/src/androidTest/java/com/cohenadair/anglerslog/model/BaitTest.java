package com.cohenadair.anglerslog.model;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.model.user_defines.Bait;
import com.cohenadair.anglerslog.model.user_defines.BaitCategory;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.ArrayList;
import java.util.Date;

import static android.support.test.InstrumentationRegistry.getTargetContext;
import static org.junit.Assert.assertTrue;

/**
 * Tests for the {@link com.cohenadair.anglerslog.model.user_defines.Bait} class.
 * Created by Cohen Adair on 2016-01-24
 */
@RunWith(AndroidJUnit4.class)
public class BaitTest {

    private SQLiteDatabase mDatabase;
    private Bait mTestBait;

    @Before
    public void setUp() throws Exception {
        RenamingDelegatingContext context = new RenamingDelegatingContext(getTargetContext(), "test_");
        context.deleteDatabase(LogbookHelper.DATABASE_NAME);
        mDatabase = new LogbookHelper(context).getWritableDatabase();
        Logbook.init(context, mDatabase);

        BaitCategory category = new BaitCategory("Bugger");
        Logbook.addBaitCategory(category);
        
        mTestBait = new Bait("Olive", category);
        Logbook.addBait(mTestBait);
    }

    @After
    public void tearDown() throws Exception {
        mDatabase.close();
    }

    @Test
    public void testBaitCatches() {
        // setup catches
        Species species = new Species("Steelhead");
        Logbook.addSpecies(species);

        ArrayList<Catch> catches = new ArrayList<>();
        catches.add(new Catch(new Date(10000000)));
        catches.add(new Catch(new Date(20000000)));
        catches.add(new Catch(new Date(30000000)));
        catches.add(new Catch(new Date(40000000)));
        catches.add(new Catch(new Date(50000000)));
        catches.add(new Catch(new Date(60000000)));
        catches.add(new Catch(new Date(70000000)));

        // no catches
        assertTrue(mTestBait.getFishCaughtCount() == 0);

        for (Catch c : catches) {
            c.setSpecies(species);
            c.setBait(mTestBait);
            Logbook.addCatch(c);
        }

        // bunch of catches
        assertTrue(mTestBait.getFishCaughtCount() == 7);
    }
}
