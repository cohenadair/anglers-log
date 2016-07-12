package com.cohenadair.anglerslog.model;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.FishingMethod;
import com.cohenadair.anglerslog.model.user_defines.Species;
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
 * Tests for the {@link Catch} class.
 * Created by Cohen Adair on 2015-11-04.
 */
@RunWith(AndroidJUnit4.class)
public class CatchTest {

    private SQLiteDatabase mDatabase;
    private Catch mTestCatch;

    @Before
    public void setUp() throws Exception {
        RenamingDelegatingContext context = new RenamingDelegatingContext(getTargetContext(), "test_");
        context.deleteDatabase(LogbookHelper.DATABASE_NAME);
        mDatabase = new LogbookHelper(context).getWritableDatabase();
        Logbook.init(context, mDatabase);

        Species testSpecies = new Species("Pike");
        mTestCatch = new Catch(new Date());
        mTestCatch.setSpecies(testSpecies);
        Logbook.addSpecies(testSpecies);
        Logbook.addCatch(mTestCatch);
    }

    @After
    public void tearDown() throws Exception {
        mDatabase.close();
    }

    @Test
    public void testFishingMethods() {
        ArrayList<FishingMethod> methods0 = new ArrayList<>();
        methods0.add(new FishingMethod("Trolling"));
        methods0.add(new FishingMethod("Casting"));
        methods0.add(new FishingMethod("Fly"));
        methods0.add(new FishingMethod("Ice"));
        methods0.add(new FishingMethod("Jig"));
        methods0.add(new FishingMethod("Drifting"));
        methods0.add(new FishingMethod("Dipsy"));

        // add all test FishingMethod objects to the Logbook
        for (FishingMethod m : methods0)
            Logbook.addFishingMethod(m);

        // initial methods
        ArrayList<UserDefineObject> methods1 = new ArrayList<>();
        methods1.add(methods0.get(0));
        methods1.add(methods0.get(1));
        methods1.add(methods0.get(2));

        // replacement methods for editing/resetting
        ArrayList<UserDefineObject> methods2 = new ArrayList<>();
        methods2.add(methods0.get(3));
        methods2.add(methods0.get(4));
        methods2.add(methods0.get(5));
        methods2.add(methods0.get(6));

        // get and set
        mTestCatch.setFishingMethods(methods1);
        assertTrue(mTestCatch.getFishingMethods().size() == 3);

        // reset
        mTestCatch.setFishingMethods(methods2);
        assertTrue(mTestCatch.getFishingMethods().size() == 4);
    }

    @Test
    public void testWeather() {
        Weather weather0 = new Weather(15, 10, "Cloudy");
        Weather weather1 = new Weather(0, 50, "Snow");

        // setting from null
        mTestCatch.setWeather(weather0);
        assertTrue(mTestCatch.getWeather() != null);
        assertTrue(mTestCatch.getWeather().getTemperature() == 15);

        // replacing
        mTestCatch.setWeather(weather1);
        assertTrue(mTestCatch.getWeather().getTemperature() == 0);

        // deleting
        mTestCatch.removeWeather();
        assertTrue(mTestCatch.getWeather() == null);

        // deleting via setting
        mTestCatch.setWeather(weather0);
        mTestCatch.setWeather(null);
        assertTrue(mTestCatch.getWeather() == null);
    }
}
