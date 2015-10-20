package com.cohenadair.anglerslog.model;

import com.cohenadair.anglerslog.model.user_defines.Catch;
import com.cohenadair.anglerslog.model.user_defines.Species;
import com.cohenadair.anglerslog.model.user_defines.Trip;

import org.junit.Test;

import java.util.Date;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * Tests for the Logbook (top level) class.
 * @author Cohen Adair
 */
public class LogbookTest {

    //region Catch Tests
    @Test
    public void testAddRemoveCatch() {
        Catch testCatch = new Catch(new Date());
        Catch testCatch2 = new Catch(testCatch.getDate()); // equal dates

        Logbook.addCatch(testCatch);
        assertTrue(Logbook.catchCount() == 1);

        // a Catch with a duplicate date shouldn't be added
        Logbook.addCatch(testCatch2);
        assertTrue(Logbook.catchCount() == 1);

        Logbook.removeCatch(testCatch);
        assertTrue(Logbook.catchCount() == 0);

        Logbook.addCatch(testCatch);
        Logbook.removeCatchAtPos(0);
        assertTrue(Logbook.catchCount() == 0);
    }

    @Test
    public void testCatchDated() {
        Catch testCatch = new Catch(new Date());
        Date testDate = new Date(testCatch.getDate().getTime());

        Logbook.addCatch(testCatch);

        assertFalse(testDate == testCatch.getDate()); // date references are different
        assertTrue(Logbook.catchDated(testDate) != null); // date values are the same

        Logbook.removeCatch(testCatch);
    }

    @Test
    public void testCloneCatch() {
        Catch testCatch = new Catch(new Date());
        Catch clonedCatch = new Catch(testCatch);

        assertFalse(testCatch == clonedCatch); // different references
        assertTrue(testCatch.getDate().equals(clonedCatch.getDate())); // equal dates

        testCatch.addPhoto();
        assertFalse(testCatch.photoCount() == clonedCatch.photoCount());
    }

    @Test
    public void testNextCatchPhotoName() {
        Catch testCatch = new Catch(new Date());

        testCatch.addPhoto();
        assertTrue(testCatch.photoCount() == 1);

        testCatch.addPhoto();
        assertTrue(testCatch.photoCount() == 2);

        // references should be different
        String strCopy = new String(testCatch.getPhotoFileNames().get(0));
        assertTrue(strCopy != testCatch.getPhotoFileNames().get(0));

        testCatch.removePhoto(strCopy);
        assertTrue(testCatch.photoCount() == 1);

        // should end in ...0.png now that the original 0th index was removed
        testCatch.addPhoto();
        String s = testCatch.getPhotoFileNames().get(1);
        assertTrue(s.substring(s.length() - 5, s.length()).equals("0.jpg"));

        testCatch.addPhoto();
        assertTrue(testCatch.photoCount() == 3);
    }
    //endregion

    //region Trip Tests
    @Test
    public void testAddRemoveTrip() {
        Trip testTrip = new Trip("Example Trip");

        Logbook.addTrip(testTrip);
        assertTrue(Logbook.tripCount() == 1);

        Logbook.removeTrip(testTrip);
        assertTrue(Logbook.tripCount() == 0);
    }
    //endregion

    //region Species Tests
    @Test
    public void testAddRemoveSpecies() {
        Species testSpecies = new Species("Example Species");
        Species testSpecies2 = new Species(testSpecies.getName());

        Logbook.addSpecies(testSpecies);
        assertTrue(Logbook.speciesCount() == 1);

        // a Species with a duplicate name shouldn't be added
        Logbook.addSpecies(testSpecies2);
        assertTrue(Logbook.speciesCount() == 1);

        Logbook.removeSpecies(0);
        assertTrue(Logbook.speciesCount() == 0);
    }

    @Test
    public void testEditSpecies() {
        Species species1 = new Species("Bass");
        Species species2 = new Species("Largemouth Bass");

        // references aren't equal
        assertFalse(species1 == species2);

        Logbook.addSpecies(species1);
        Logbook.editSpecies(0, species2.getName());

        // names are equal
        assertTrue(species1.getName().equals(species2.getName()));
    }
    //endregion

}