package com.cohenadair.anglerslog.model;

import android.database.sqlite.SQLiteDatabase;
import android.support.test.runner.AndroidJUnit4;
import android.test.RenamingDelegatingContext;

import com.cohenadair.anglerslog.database.LogbookHelper;
import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import static android.support.test.InstrumentationRegistry.getTargetContext;
import static org.junit.Assert.assertTrue;

/**
 * Tests for the {@link PhotoUserDefineTest} class.
 * Created by Cohen Adair on 2015-11-04.
 */
@RunWith(AndroidJUnit4.class)
public class PhotoUserDefineTest {

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
    public void testPhotos() {
        String photo0 = "test0.jpg";
        String photo1 = "test1.jpg";
        String photo2 = "test2.jpg";
        ArrayList<String> photos = new ArrayList<>();
        photos.add(photo0);
        photos.add(photo1);
        photos.add(photo2);

        // add
        mTestCatch.addPhoto(photo0);
        assertTrue(mTestCatch.getPhotoCount() == 1);

        // remove
        mTestCatch.removePhoto(photo0);
        assertTrue(mTestCatch.getPhotoCount() == 0);
        assertTrue(mTestCatch.getRandomPhoto() == null);

        // setPhotos
        mTestCatch.addPhoto(photo0);
        mTestCatch.addPhoto(photo1);
        mTestCatch.setPhotos(photos);
        assertTrue(mTestCatch.getPhotoCount() == 3);

        // getPhotos
        assertTrue(mTestCatch.getPhotos().size() == 3);

        // getRandomPhoto
        assertTrue(mTestCatch.getRandomPhoto() != null);
        assertTrue(photos.indexOf(mTestCatch.getRandomPhoto()) >= 0);

        // getNextPhotoName
        ArrayList<String> testNames = new ArrayList<>();
        for (int i = 0; i < 10000; i++)
            testNames.add(mTestCatch.getNextPhotoName());

        Set<String> testSet = new HashSet<>(testNames);
        assertTrue(testSet.size() == testNames.size());
    }
}
