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

        Logbook.getInstance().addCatch(testCatch);
        assertTrue(Logbook.getInstance().catchCount() == 1);

        // a Catch with a duplicate date shouldn't be added
        Logbook.getInstance().addCatch(testCatch2);
        assertTrue(Logbook.getInstance().catchCount() == 1);

        Logbook.getInstance().removeCatch(testCatch);
        assertTrue(Logbook.getInstance().catchCount() == 0);
    }

    @Test
    public void testCatchDated() {
        Catch testCatch = new Catch(new Date());
        Date testDate = new Date(testCatch.getDate().getTime());

        Logbook.getInstance().addCatch(testCatch);

        assertFalse(testDate == testCatch.getDate()); // date references are different
        assertTrue(Logbook.getInstance().catchDated(testDate) != null); // date values are the same

        Logbook.getInstance().removeCatch(testCatch);
    }
    //endregion

    //region Trip Tests
    @Test
    public void testAddRemoveTrip() {
        Trip testTrip = new Trip("Example Trip");

        Logbook.getInstance().addTrip(testTrip);
        assertTrue(Logbook.getInstance().tripCount() == 1);

        Logbook.getInstance().removeTrip(testTrip);
        assertTrue(Logbook.getInstance().tripCount() == 0);
    }
    //endregion

    //region Species Tests
    @Test
    public void testAddRemoveSpecies() {
        Species testSpecies = new Species("Example Species");
        Species testSpecies2 = new Species(testSpecies.getName());

        Logbook.getInstance().addSpecies(testSpecies);
        assertTrue(Logbook.getInstance().speciesCount() == 1);

        // a Species with a duplicate name shouldn't be added
        Logbook.getInstance().addSpecies(testSpecies2);
        assertTrue(Logbook.getInstance().speciesCount() == 1);

        Logbook.getInstance().removeSpecies(0);
        assertTrue(Logbook.getInstance().speciesCount() == 0);
    }

    @Test
    public void testEditSpecies() {
        Species species1 = new Species("Bass");
        Species species2 = new Species("Largemouth Bass");

        // references aren't equal
        assertFalse(species1 == species2);

        Logbook.getInstance().addSpecies(species1);
        Logbook.getInstance().editSpecies(0, species2.getName());

        // names are equal
        assertTrue(species1.getName().equals(species2.getName()));
    }
    //endregion

}