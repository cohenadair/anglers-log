package com.cohenadair.anglerslog.model;

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

        Logbook.getInstance().addCatch(testCatch);
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

}