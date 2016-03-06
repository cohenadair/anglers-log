package com.cohenadair.anglerslog.backup;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.model.Logbook;
import com.cohenadair.anglerslog.model.backup.JsonImporter;

import org.json.JSONException;
import org.json.JSONObject;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import static android.support.test.InstrumentationRegistry.getTargetContext;
import static org.junit.Assert.assertTrue;

/**
 * Tests importing from an iOS export.
 * @author Cohen Adair
 */
@RunWith(AndroidJUnit4.class)
public class iOSImportTest {

    // JSON String exported from an iOS device
    private static final String JSON = "{\"journal\":{\"name\":\"Log_1\",\"entries\":[{\"date\":\"03-06-2016_1-42_PM\",\"images\":[],\"fishSpecies\":\"Walleye\",\"fishLength\":-1,\"fishWeight\":0,\"fishOunces\":0,\"fishQuantity\":-1,\"fishResult\":0,\"baitUsed\":\"\",\"fishingMethodNames\":[],\"location\":\"\",\"fishingSpot\":\"\",\"weatherData\":{},\"waterTemperature\":-1,\"waterClarity\":\"\",\"waterDepth\":-1,\"notes\":\"\",\"journal\":\"Log_1\"},{\"date\":\"03-06-2016_1-40_PM\",\"images\":[],\"fishSpecies\":\"Salmon - King\",\"fishLength\":25,\"fishWeight\":22,\"fishOunces\":6,\"fishQuantity\":5,\"fishResult\":1,\"baitUsed\":\"Rippin' Rap\",\"fishingMethodNames\":[\"Boat\",\"Trolling\"],\"location\":\"Lake Ontario\",\"fishingSpot\":\"Mouth\",\"weatherData\":{\"entry\":\"03-06-2016_1-40_PM\",\"temperature\":37,\"windSpeed\":\"10.8\",\"skyConditions\":\"Clear\",\"imageURL\":\"https://openweathermap.org/img/w/02d.png\"},\"waterTemperature\":23,\"waterClarity\":\"Clear\",\"waterDepth\":25,\"notes\":\"Monster!\",\"journal\":\"Log_1\"}],\"userDefines\":[{\"name\":\"Baits\",\"journal\":\"Log_1\",\"baits\":[{\"name\":\"Rippin' Rap\",\"baitDescription\":\"\",\"image\":{\"imagePath\":\"Images/06272016132742777_0.png\",\"entryDate\":\"\",\"baitName\":\"Rippin' Rap\"},\"fishCaught\":5,\"size\":\"2\",\"color\":\"Blue Chrome\",\"baitType\":0},{\"name\":\"Spinner - Blue Fox\",\"baitDescription\":\"\",\"image\":{\"imagePath\":\"Images/06272016132742896_1.png\",\"entryDate\":\"\",\"baitName\":\"Spinner - Blue Fox\"},\"fishCaught\":0,\"size\":\"6\",\"color\":\"Silver\",\"baitType\":0}],\"fishingMethods\":[],\"locations\":[],\"species\":[],\"waterClarities\":[]},{\"name\":\"Locations\",\"journal\":\"Log_1\",\"baits\":[],\"fishingMethods\":[],\"locations\":[{\"name\":\"Lake Ontario\",\"fishingSpots\":[{\"name\":\"Mouth\",\"fishCaught\":5,\"coordinates\":{\"latitude\":\"46.555428\",\"longitude\":\"-87.394272\"},\"location\":\"Lake Ontario\"}]}],\"species\":[],\"waterClarities\":[]},{\"name\":\"Fishing Methods\",\"journal\":\"Log_1\",\"baits\":[],\"fishingMethods\":[{\"name\":\"Boat\"},{\"name\":\"Casting\"},{\"name\":\"Fly\"},{\"name\":\"Ice\"},{\"name\":\"Shore\"},{\"name\":\"Trolling\"}],\"locations\":[],\"species\":[],\"waterClarities\":[]},{\"name\":\"Species\",\"journal\":\"Log_1\",\"baits\":[],\"fishingMethods\":[],\"locations\":[],\"species\":[{\"name\":\"Bass - Largemouth\",\"numberCaught\":0,\"weightCaught\":0,\"ouncesCaught\":0},{\"name\":\"Bass - Smallmouth\",\"numberCaught\":0,\"weightCaught\":0,\"ouncesCaught\":0},{\"name\":\"Salmon - King\",\"numberCaught\":5,\"weightCaught\":22,\"ouncesCaught\":6},{\"name\":\"Trout - Rainbow\",\"numberCaught\":0,\"weightCaught\":0,\"ouncesCaught\":0},{\"name\":\"Walleye\",\"numberCaught\":1,\"weightCaught\":0,\"ouncesCaught\":0}],\"waterClarities\":[]},{\"name\":\"Water Clarities\",\"journal\":\"Log_1\",\"baits\":[],\"fishingMethods\":[],\"locations\":[],\"species\":[],\"waterClarities\":[{\"name\":\"3 Feet\"},{\"name\":\"Clear\"},{\"name\":\"Cloudy\"},{\"name\":\"Crystal\"},{\"name\":\"Dirty\"}]}],\"measurementSystem\":0,\"entrySortMethod\":0,\"entrySortOrder\":1}}";

    private SQLiteDatabase mDatabase;

    @Before
    public void setUp() throws Exception {
        RenamingDelegatingContext context = new RenamingDelegatingContext(getTargetContext(), "test_");
        context.deleteDatabase(LogbookHelper.DATABASE_NAME);
        mDatabase = new LogbookHelper(context).getWritableDatabase();
        Logbook.init(context, mDatabase);
    }

    @After
    public void tearDown() throws Exception {
        mDatabase.close();
    }

    @Test
    public void testImport() {
        try {
            JsonImporter.parse(new JSONObject(JSON));
        } catch (JSONException e) {
            e.printStackTrace();
        }

        assertTrue(Logbook.getCatchCount() == 2);
        assertTrue(Logbook.getBaitCount() == 2);
        assertTrue(Logbook.getLocationCount() == 1);
        assertTrue(Logbook.getFishingMethodCount() == 6);
        assertTrue(Logbook.getSpeciesCount() == 5);
        assertTrue(Logbook.getWaterClarityCount() == 5);
    }
}
