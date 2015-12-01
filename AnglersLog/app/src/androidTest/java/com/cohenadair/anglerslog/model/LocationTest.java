package com.cohenadair.anglerslog.model;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.model.user_defines.FishingSpot;
import com.cohenadair.anglerslog.model.user_defines.Location;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.ArrayList;

import static android.support.test.InstrumentationRegistry.getTargetContext;
import static org.junit.Assert.assertTrue;

/**
 * Tests for the {@link Location} class.
 * Created by Cohen Adair on 2015-11-30.
 */
@RunWith(AndroidJUnit4.class)
public class LocationTest {

    private SQLiteDatabase mDatabase;
    private Location mTestLocation, mTestLocation2;

    @Before
    public void setUp() throws Exception {
        RenamingDelegatingContext context = new RenamingDelegatingContext(getTargetContext(), "test_");
        context.deleteDatabase(LogbookHelper.DATABASE_NAME);
        mDatabase = new LogbookHelper(context).getWritableDatabase();
        Logbook.init(context, mDatabase);

        mTestLocation = new Location("Port Albert");
        mTestLocation2 = new Location("Goderich");
        Logbook.addLocation(mTestLocation);
        Logbook.addLocation(mTestLocation2);
    }

    @After
    public void tearDown() throws Exception {
        mDatabase.close();
    }

    @Test
    public void testFishingSpots() {
        FishingSpot spot0 = new FishingSpot("Mouth");
        FishingSpot spot1 = new FishingSpot("Baskets");
        FishingSpot spot2 = new FishingSpot("Beaver Dam");
        ArrayList<FishingSpot> spots = new ArrayList<>();
        spots.add(spot0);
        spots.add(spot1);
        spots.add(spot2);

        // add
        mTestLocation.addFishingSpot(spot0);
        assertTrue(mTestLocation.getFishingSpotCount() == 1);

        // add same fishing spot, different locations
        mTestLocation2.addFishingSpot(new FishingSpot(spot0, false));
        assertTrue(mTestLocation2.getFishingSpotCount() == 1);

        // remove
        mTestLocation.removeFishingSpot(spot0.getId());
        assertTrue(mTestLocation.getFishingSpotCount() == 0);

        // setPhotos
        mTestLocation.addFishingSpot(spot0);
        mTestLocation.addFishingSpot(spot1);
        mTestLocation.setFishingSpots(spots);
        assertTrue(mTestLocation.getFishingSpotCount() == 3);

        // getPhotos
        assertTrue(mTestLocation.getFishingSpots().size() == 3);
    }
}
