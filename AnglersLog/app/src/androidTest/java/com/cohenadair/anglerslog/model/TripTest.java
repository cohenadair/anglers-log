package com.cohenadair.anglerslog.model;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.model.user_defines.Angler;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Location;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;
import com.cohenadair.anglerslog.model.user_defines.UserDefineObject;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.ArrayList;
import java.util.Date;

import static android.support.test.InstrumentationRegistry.getTargetContext;
import static org.junit.Assert.assertTrue;

/**
 * Tests for the {@link com.cohenadair.anglerslog.model.user_defines.Trip} class.
 * Created by Cohen Adair on 2016-01-20.
 */
@RunWith(AndroidJUnit4.class)
public class TripTest {

    private SQLiteDatabase mDatabase;
    private Trip mTestTrip;

    @Before
    public void setUp() throws Exception {
        RenamingDelegatingContext context = new RenamingDelegatingContext(getTargetContext(), "test_");
        context.deleteDatabase(LogbookHelper.DATABASE_NAME);
        mDatabase = new LogbookHelper(context).getWritableDatabase();
        Logbook.init(context, mDatabase);

        mTestTrip = new Trip("Test Trip");
        Logbook.addTrip(mTestTrip);
    }

    @After
    public void tearDown() throws Exception {
        mDatabase.close();
    }

    @Test
    public void testAnglers() {
        ArrayList<Angler> objects0 = new ArrayList<>();
        objects0.add(new Angler("Jack Johnson"));
        objects0.add(new Angler("John Jackson"));
        objects0.add(new Angler("Leela"));
        objects0.add(new Angler("Fry"));
        objects0.add(new Angler("Professor"));
        objects0.add(new Angler("Zoidberg"));
        objects0.add(new Angler("Bender"));

        // add all test objects to the Logbook
        for (Angler o : objects0)
            Logbook.addAngler(o);

        // initial
        ArrayList<UserDefineObject> objects1 = new ArrayList<>();
        objects1.add(objects0.get(0));
        objects1.add(objects0.get(1));
        objects1.add(objects0.get(2));

        // replacement
        ArrayList<UserDefineObject> objects2 = new ArrayList<>();
        objects2.add(objects0.get(3));
        objects2.add(objects0.get(4));
        objects2.add(objects0.get(5));
        objects2.add(objects0.get(6));

        // get and set
        mTestTrip.setAnglers(objects1);
        assertTrue(mTestTrip.getAnglers().size() == 3);

        // reset
        mTestTrip.setAnglers(objects2);
        assertTrue(mTestTrip.getAnglers().size() == 4);
    }

    @Test
    public void testLocations() {
        ArrayList<Location> objects0 = new ArrayList<>();
        objects0.add(new Location("Lake Huron"));
        objects0.add(new Location("Lake Erie"));
        objects0.add(new Location("Lake Ontario"));
        objects0.add(new Location("Lake Michigan"));
        objects0.add(new Location("Lake Superior"));
        objects0.add(new Location("Lake Simcoe"));
        objects0.add(new Location("Lake St. Clair"));

        // add all test objects to the Logbook
        for (Location o : objects0)
            Logbook.addLocation(o);

        // initial
        ArrayList<UserDefineObject> objects1 = new ArrayList<>();
        objects1.add(objects0.get(0));
        objects1.add(objects0.get(1));
        objects1.add(objects0.get(2));

        // replacement
        ArrayList<UserDefineObject> objects2 = new ArrayList<>();
        objects2.add(objects0.get(3));
        objects2.add(objects0.get(4));
        objects2.add(objects0.get(5));
        objects2.add(objects0.get(6));

        // get and set
        mTestTrip.setLocations(objects1);
        assertTrue(mTestTrip.getLocations().size() == 3);

        // reset
        mTestTrip.setLocations(objects2);
        assertTrue(mTestTrip.getLocations().size() == 4);
    }

    @Test
    public void testCatches() {
        ArrayList<Catch> objects0 = new ArrayList<>();
        objects0.add(new Catch(new Date(1000000)));
        objects0.add(new Catch(new Date(2000000)));
        objects0.add(new Catch(new Date(3000000)));
        objects0.add(new Catch(new Date(4000000)));
        objects0.add(new Catch(new Date(5000000)));
        objects0.add(new Catch(new Date(6000000)));
        objects0.add(new Catch(new Date(7000000)));

        // add all test objects to the Logbook
        for (Catch o : objects0) {
            Species species = new Species(o.getDate().toString());
            Logbook.addSpecies(species);

            o.setSpecies(species);
            Logbook.addCatch(o);
        }

        // initial
        ArrayList<UserDefineObject> objects1 = new ArrayList<>();
        objects1.add(objects0.get(0));
        objects1.add(objects0.get(1));
        objects1.add(objects0.get(2));

        // replacement
        ArrayList<UserDefineObject> objects2 = new ArrayList<>();
        objects2.add(objects0.get(3));
        objects2.add(objects0.get(4));
        objects2.add(objects0.get(5));
        objects2.add(objects0.get(6));

        // get and set
        mTestTrip.setCatches(objects1);
        assertTrue(mTestTrip.getCatches().size() == 3);

        // reset
        mTestTrip.setCatches(objects2);
        assertTrue(mTestTrip.getCatches().size() == 4);
    }
}
